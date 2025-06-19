// // cloudinary_service.dart
// import 'dart:io';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:mime/mime.dart';
// import 'package:http_parser/http_parser.dart';
//
// class CloudinaryService {
//   static const String cloudName = 'dqpy11qat';
//   static const String uploadPreset = 'image_upload';
//   static const int maxFileSize = 10 * 1024 * 1024; // 10MB
//
//   static Future<String> uploadImage(File imageFile) async {
//     try {
//       // Validate file exists
//       if (!await imageFile.exists()) {
//         throw Exception('Selected file does not exist');
//       }
//
//       // Validate file size
//       final fileSize = await imageFile.length();
//       if (fileSize == 0) throw Exception('File is empty');
//       if (fileSize > maxFileSize) throw Exception('File too large (max 10MB)');
//
//       // Validate MIME type
//       final mimeType = lookupMimeType(imageFile.path);
//       if (mimeType == null || !mimeType.startsWith('image/')) {
//         throw Exception('Selected file is not a valid image');
//       }
//
//       // Prepare upload
//       final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
//       final stream = http.ByteStream(imageFile.openRead());
//       final length = await imageFile.length();
//
//       final request = http.MultipartRequest('POST', uri)
//         ..fields['upload_preset'] = uploadPreset
//         ..files.add(http.MultipartFile(
//           'file',
//           stream,
//           length,
//           filename: 'img_${DateTime.now().millisecondsSinceEpoch}',
//           contentType: MediaType.parse(mimeType),
//         ));
//
//             // Execute upload
//             final response = await request.send();
//       final responseData = await response.stream.bytesToString();
//
//       if (response.statusCode != 200) {
//         throw _parseCloudinaryError(response.statusCode, responseData);
//       }
//
//       final jsonData = json.decode(responseData);
//       return jsonData['secure_url'] as String;
//     } catch (e) {
//       throw Exception('Cloudinary upload failed: ${e.toString()}');
//     }
//   }
//
//   static Exception _parseCloudinaryError(int statusCode, String response) {
//     try {
//       final error = json.decode(response)['error'];
//       return Exception('Cloudinary error: ${error['message']}');
//     } catch (_) {
//       return Exception('Upload failed with status $statusCode');
//     }
//   }
// }


// cloudinary_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class CloudinaryService {
  static const String cloudName = 'Your cloudname';
  static const String uploadPreset = 'image_upload';
  static const String apiKey = 'Your api key';
  static const String apiSecret = 'Your api secret';
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  static Future<String> uploadImage(File imageFile) async {
    try {
      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception('Selected file does not exist');
      }

      // Validate file size
      final fileSize = await imageFile.length();
      if (fileSize == 0) throw Exception('File is empty');
      if (fileSize > maxFileSize) throw Exception('File too large (max 10MB)');

      // Validate MIME type
      final mimeType = lookupMimeType(imageFile.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        throw Exception('Selected file is not a valid image');
      }

      // Prepare upload
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(http.MultipartFile(
          'file',
          stream,
          length,
          filename: 'img_${DateTime.now().millisecondsSinceEpoch}',
          contentType: MediaType.parse(mimeType),
        ));

            // Execute upload
            final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw _parseCloudinaryError(response.statusCode, responseData);
      }

      final jsonData = json.decode(responseData);
      return jsonData['secure_url'] as String;
    } catch (e) {
      throw Exception('Image upload failed: ${e.toString()}');
    }
  }

  static Exception _parseCloudinaryError(int statusCode, String response) {
    try {
      final error = json.decode(response)['error'];
      return Exception('Cloudinary error: ${error['message']}');
    } catch (_) {
      return Exception('Upload failed with status $statusCode');
    }
  }
}
