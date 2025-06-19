import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_two/models/petModel.dart';
import '../models/postModel.dart';
import '../widgets/petcard.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference postCollection = FirebaseFirestore.instance
      .collection('posts');

  Future<bool> userExists(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking if user exists: $e");
      return false;
    }
  }

  // Future<void> addPost(PostModel post) async {
  //   return await postCollection.doc(post.id).set(post.toMap());
  // }

  void uploadMockProducts() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final products = [
      {"name": "Pedigree Adult Dog Food", "price": 58.6, "category": "Food"},
      {"name": "Whiskas Chicken Flavour", "price": 158.5, "category": "Food"},
      {"name": "Drools Puppy Food", "price": 39.1, "category": "Food"},
      {"name": "Royal Canin Medium Puppy", "price": 59.7, "category": "Food"},
      {"name": "Purepet Chicken and Veg", "price": 73.7, "category": "Food"},
      {"name": "Me-O Cat Food Tuna", "price": 190.2, "category": "Food"},
      {"name": "Farmina N&D Low Grain", "price": 129.1, "category": "Food"},
      {"name": "Purina Supercoat", "price": 88.1, "category": "Food"},
      {"name": "Canine Creek Puppy", "price": 106.4, "category": "Food"},
      {"name": "Orijen Original Dog Food", "price": 197.6, "category": "Food"},

      {"name": "Rubber Chew Ball", "price": 123.2, "category": "Toys"},
      {"name": "Squeaky Bone Toy", "price": 42.6, "category": "Toys"},
      {"name": "Tug Rope Toy", "price": 53.4, "category": "Toys"},
      {"name": "Cat Teaser Wand", "price": 68.9, "category": "Toys"},
      {"name": "Dog Frisbee", "price": 91.3, "category": "Toys"},
      {"name": "Interactive Puzzle Toy", "price": 112.8, "category": "Toys"},
      {"name": "Stuffed Squeaky Toy", "price": 73.5, "category": "Toys"},
      {"name": "Treat Dispensing Ball", "price": 83.4, "category": "Toys"},
      {"name": "Catnip Toy Mouse", "price": 51.9, "category": "Toys"},
      {"name": "Rope Knot Ball", "price": 44.8, "category": "Toys"},

      {"name": "Adjustable Dog Collar", "price": 59.3, "category": "Accessories"},
      {"name": "Cat Harness with Leash", "price": 77.9, "category": "Accessories"},
      {"name": "Pet Nail Clipper", "price": 31.5, "category": "Accessories"},
      {"name": "Pet Grooming Brush", "price": 49.7, "category": "Accessories"},
      {"name": "Dog Winter Jacket", "price": 159.3, "category": "Accessories"},
      {"name": "Cat Litter Mat", "price": 89.9, "category": "Accessories"},
      {"name": "Dog Raincoat", "price": 137.0, "category": "Accessories"},
      {"name": "Pet Travel Bag", "price": 172.6, "category": "Accessories"},
      {"name": "LED Dog Collar", "price": 98.1, "category": "Accessories"},
      {"name": "Pet Feeding Bowl Set", "price": 64.4, "category": "Accessories"},
    ];

    for (var product in products) {
      await db.collection('products').add(product);
    }

    print("Mock products uploaded successfully!");
  }



  Stream<List<PostModel>> getPosts() {
    return postCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) =>
            PostModel.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  Future<void> updateUserDocument(String userId,
      Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users').doc(userId).update(updatedData);
    } catch (e) {
      print("Error updating user: $e");
      rethrow;
    }
  }

  

  Future<DocumentSnapshot> getUserDocument(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      print("Error fetching user document: $e");
      rethrow;
    }
  }

  Future<void> addPet(PetModel pet) async {
    await _firestore.collection('pets').doc(pet.id).set(pet.toMap());
  }

  Stream<List<PetModel>> getPets(String userId) {
    return _firestore
        .collection('pets')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => PetModel.fromMap(doc.data())).toList());
  }

  // Fetch pets from Firestore (optional filtering by type)
  Stream<List<PetModel>> getAdoptionPets({String? petType}) {
    Query query = _firestore.collection('pets');

    if (petType != null && petType.isNotEmpty) {
      query = query.where('type', isEqualTo: petType);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();
      });
    }

  // Stream<List<PetModel>> getAdoptionPets() {
  //   return _firestore
  //       .collection('adopted_pets')
  //       .orderBy('timestamp', descending: true)
  //       .snapshots()
  //       .map((snapshot) {
  //     return snapshot.docs.map((doc) => PetModel.fromDoc(doc)).toList();
  //   });
  // }

  Future<PetModel?> fetchPet(String petId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('pets')
        .doc(petId)
        .get();

    if (!docSnapshot.exists) {
      // The document does not exist in Firestore
      return null;
    }

    // If the document does exist, construct a PetModel
    return PetModel.fromFirestore(docSnapshot);
  }


  Stream<List<PetModel>> getFilteredPets(
      {String? city, String? gender, String? type}) {
    Query query = _firestore.collection('pets');

    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }
    if (gender != null && gender.isNotEmpty) {
      query = query.where('gender', isEqualTo: gender);
    }
    if (type != null && type.isNotEmpty) {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Use doc.data() to retrieve the Map<String, dynamic>
        return PetModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }


  Future<void> createMockPets() async {
    final pets = [
      {
        'name': 'Buddy',
        'breed': 'Golden Retriever',
        'photoUrl': 'assets/images/petlogo.png', // Use asset path
        'ownerId': 'owner_123'
      },
      {
        'name': 'Luna',
        'breed': 'Labrador',
        'photoUrl': 'assets/images/petlogo.png', // Use asset path
        'ownerId': 'owner_124'
      },
    ];

    for (var pet in pets) {
      await FirebaseFirestore.instance.collection('pet_profiles').add(pet);
    }
  }
}
