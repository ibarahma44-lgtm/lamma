import 'dart:typed_data';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'lamma-aq0sqq-knv7x',
  );

  // Upload profile picture with detailed logging and error handling
  static Future<String?> uploadProfilePicture(
      String userId, Uint8List imageBytes) async {
    try {
      print('------------- Starting Profile Picture Upload -------------');
      print('User ID: $userId');
      print('Image size: ${imageBytes.length} bytes');

      // Process and optimize the image
      final processedImage = await _processImage(imageBytes);
      if (processedImage == null) return null;

      // Basic reference
      final storageRef = _storage.ref().child('profile_pictures/$userId.jpg');
      print('Created reference: ${storageRef.fullPath}');

      // Basic metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadTime': DateTime.now().toIso8601String(),
        },
      );

      // Upload the image
      final uploadTask = storageRef.putData(processedImage, metadata);

      // Monitor progress
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print('Upload progress: ${progress.toStringAsFixed(1)}%');
        },
        onError: (error) => print('Upload error: $error'),
      );

      // Wait for completion
      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final url = await storageRef.getDownloadURL();
        print('Upload successful. URL: $url');
        return url;
      } else {
        print('Upload failed: ${snapshot.state}');
        return null;
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  // Upload family avatar
  static Future<String?> uploadFamilyAvatar(
      String familyId, Uint8List imageBytes) async {
    try {
      print('------------- Starting Family Avatar Upload -------------');
      print('Family ID: $familyId');
      print('Image size: ${imageBytes.length} bytes');

      // Create a fixed filename for the family avatar
      final filename = 'family_$familyId.jpg';
      final storageRef = _storage.ref().child('family_avatars/$filename');
      print('Created reference: ${storageRef.fullPath}');

      // Basic metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'no-cache',
        customMetadata: {
          'familyId': familyId,
          'uploadTime': DateTime.now().toIso8601String(),
        },
      );

      // Upload the image
      final uploadTask = storageRef.putData(imageBytes, metadata);

      // Monitor progress
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print('Upload progress: ${progress.toStringAsFixed(1)}%');
        },
        onError: (error) {
          print('Upload error: $error');
          if (error is FirebaseException) {
            print('Firebase error code: ${error.code}');
            print('Firebase error message: ${error.message}');
          }
        },
      );

      // Wait for completion
      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        // Get download URL
        final downloadUrl = await storageRef.getDownloadURL();
        print('Upload successful. URL: $downloadUrl');
        return downloadUrl;
      } else {
        print('Upload failed: ${snapshot.state}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Error uploading family avatar: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Helper method to detect content type from bytes
  static String? _detectContentType(Uint8List bytes) {
    if (bytes.length < 4) return null;

    // Check for JPEG
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    // Check for PNG
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }

    // Check for GIF
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
      return 'image/gif';
    }

    return null;
  }

  // Delete profile picture
  static Future<void> deleteProfilePicture(String userId) async {
    try {
      final storageRef = _storage.ref().child('profile_pictures/$userId.jpg');
      await storageRef.delete();
      print('Profile picture deleted successfully');
    } catch (e) {
      print('Error deleting profile picture: $e');
    }
  }

  // Delete family avatar
  static Future<void> deleteFamilyAvatar(String familyId) async {
    try {
      final storageRef = _storage.ref().child('family_avatars/$familyId.jpg');
      await storageRef.delete();
      print('Family avatar deleted successfully');
    } catch (e) {
      print('Error deleting family avatar: $e');
    }
  }

  // Process and optimize image for upload
  static Future<Uint8List?> _processImage(Uint8List bytes) async {
    try {
      print('Starting image processing...');

      // Try to identify and decode the image format
      img.Image? decodedImage;

      try {
        print('Attempting to decode image automatically...');
        decodedImage = img.decodeImage(bytes);
      } catch (e) {
        print('Auto decode failed: $e');
      }

      if (decodedImage == null) {
        try {
          print('Trying PNG decoder...');
          decodedImage = img.decodePng(bytes);
        } catch (e) {
          print('PNG decode failed: $e');
        }
      }

      if (decodedImage == null) {
        try {
          print('Trying JPEG decoder...');
          decodedImage = img.decodeJpg(bytes);
        } catch (e) {
          print('JPEG decode failed: $e');
        }
      }

      if (decodedImage == null) {
        print('Failed to decode image with any decoder');
        return null;
      }

      print(
          'Successfully decoded image: ${decodedImage.width}x${decodedImage.height}');

      // Ensure correct orientation
      decodedImage = img.bakeOrientation(decodedImage);

      // Resize if too large while maintaining aspect ratio
      if (decodedImage.width > 1000 || decodedImage.height > 1000) {
        double aspectRatio = decodedImage.width / decodedImage.height;
        int targetWidth, targetHeight;

        if (aspectRatio > 1) {
          targetWidth = 1000;
          targetHeight = (1000 / aspectRatio).round();
        } else {
          targetHeight = 1000;
          targetWidth = (1000 * aspectRatio).round();
        }

        print('Resizing image to $targetWidth x $targetHeight');
        decodedImage = img.copyResize(
          decodedImage,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.average,
        );
      }

      // Convert to JPEG with high quality
      print('Converting to JPEG format...');
      final jpegBytes = img.encodeJpg(decodedImage, quality: 90);
      print(
          'Image processed successfully. Final size: ${jpegBytes.length} bytes');

      if (jpegBytes.isEmpty) {
        print('Warning: Encoded JPEG is empty');
        return null;
      }

      return Uint8List.fromList(jpegBytes);
    } catch (e, stackTrace) {
      print('Error processing image: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}
