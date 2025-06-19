import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/product.dart';

class EcommerceApiService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper to safely parse ratings from Firestore
  static double? _parseRating(dynamic rating) {
    if (rating == null) return null;
    if (rating is double) return rating;
    if (rating is int) return rating.toDouble();
    if (rating is String) return double.tryParse(rating);
    return null;
  }

  // Fetch all products with safe rating handling
  static Future<List<Product>> fetchProducts() async {
    try {
      final querySnapshot = await _firestore.collection('products').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] ?? 'Unnamed Product',
          description: data['description'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['imageUrl'] ?? '',
          category: data['category'] ?? 'Uncategorized',
          stock: (data['stock'] as num?)?.toInt() ?? 0,
          rating: _parseRating(data['rating']),
          reviews: List<Map<String, dynamic>>.from(data['reviews'] ?? []),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Fetch products by category
  static Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] ?? 'Unnamed Product',
          description: data['description'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['imageUrl'] ?? '',
          category: data['category'] ?? 'Uncategorized',
          stock: (data['stock'] as num?)?.toInt() ?? 0,
          rating: _parseRating(data['rating']),
          reviews: List<Map<String, dynamic>>.from(data['reviews'] ?? []),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch $category products: $e');
    }
  }

  // Get single product by ID
  static Future<Product> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) throw Exception('Product not found');

      final data = doc.data()!;
      return Product(
        id: doc.id,
        name: data['name'] ?? 'Unnamed Product',
        description: data['description'] ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: data['imageUrl'] ?? '',
        category: data['category'] ?? 'Uncategorized',
        stock: (data['stock'] as num?)?.toInt() ?? 0,
        rating: _parseRating(data['rating']),
        reviews: List<Map<String, dynamic>>.from(data['reviews'] ?? []),
      );
    } catch (e) {
      throw Exception('Failed to get product $productId: $e');
    }
  }

  // Cart Operations
  static Future<void> saveUserCart(String userId, List<CartItem> cartItems) async {
    try {
      final cartData = cartItems.map((item) => {
        'productId': item.product.id,
        'quantity': item.quantity,
        'addedAt': FieldValue.serverTimestamp(),
      }).toList();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc('current')
          .set({
        'items': cartData,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save cart: $e');
    }
  }

  static Future<List<CartItem>> loadUserCart(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc('current')
          .get();

      if (!doc.exists) return [];

      final itemsData = List<Map<String, dynamic>>.from(doc['items'] ?? []);
      final cartItems = <CartItem>[];

      for (final itemData in itemsData) {
        try {
          final product = await getProductById(itemData['productId']);
          cartItems.add(CartItem(
            product: product,
            quantity: (itemData['quantity'] as num).toInt(),
          ));
        } catch (e) {
          // Skip invalid products but continue loading others
          debugPrint('Error loading cart item: $e');
        }
      }

      return cartItems;
    } catch (e) {
      throw Exception('Failed to load cart: $e');
    }
  }

  // Order Operations
  static Future<void> createOrder({
    required String userId,
    required List<CartItem> items,
    required double totalAmount,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    try {
      final orderRef = _firestore.collection('orders').doc();

      await orderRef.set({
        'userId': userId,
        'items': items.map((item) => {
          'productId': item.product.id,
          'name': item.product.name,
          'quantity': item.quantity,
          'price': item.product.price,
        }).toList(),
        'totalAmount': totalAmount,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear cart after successful order
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc('current')
          .delete();
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Review Operations
  static Future<void> addProductReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    try {
      final reviewData = {
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('products').doc(productId).update({
        'reviews': FieldValue.arrayUnion([reviewData]),
      });

      await _updateProductRating(productId);
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  static Future<void> _updateProductRating(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) return;

      final reviews = List<Map<String, dynamic>>.from(doc['reviews'] ?? []);
      if (reviews.isEmpty) return;

      double total = 0;
      int count = 0;

      for (final review in reviews) {
        final rating = _parseRating(review['rating']);
        if (rating != null) {
          total += rating;
          count++;
        }
      }

      if (count > 0) {
        final averageRating = total / count;
        await _firestore.collection('products').doc(productId).update({
          'rating': averageRating,
        });
      }
    } catch (e) {
      throw Exception('Failed to update product rating: $e');
    }
  }
}