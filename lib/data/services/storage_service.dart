import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:recipe_app/core/constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload user profile photo
  Future<String> uploadUserProfilePhoto({
    required String userId,
    required File file,
  }) async {
    try {
      final path = '${StoragePaths.userProfile(userId)}/profile_photo.jpg';
      final ref = _storage.ref().child(path);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  // Upload recipe photo
  Future<String> uploadRecipePhoto({
    required String recipeId,
    required File file,
    String? fileName,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final name = fileName ?? 'photo_$timestamp.jpg';
      final path = '${StoragePaths.recipePhotos(recipeId)}/$name';
      final ref = _storage.ref().child(path);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload recipe photo: $e');
    }
  }

  // Upload event photo
  Future<String> uploadEventPhoto({
    required String eventId,
    required File file,
    String? fileName,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final name = fileName ?? 'photo_$timestamp.jpg';
      final path = '${StoragePaths.eventPhotos(eventId)}/$name';
      final ref = _storage.ref().child(path);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload event photo: $e');
    }
  }

  // Delete file
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Delete all recipe photos
  Future<void> deleteAllRecipePhotos(String recipeId) async {
    try {
      final ref = _storage.ref().child(StoragePaths.recipePhotos(recipeId));
      final listResult = await ref.listAll();

      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete recipe photos: $e');
    }
  }

  // Delete all event photos
  Future<void> deleteAllEventPhotos(String eventId) async {
    try {
      final ref = _storage.ref().child(StoragePaths.eventPhotos(eventId));
      final listResult = await ref.listAll();

      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete event photos: $e');
    }
  }

  // Upload multiple recipe photos
  Future<List<String>> uploadMultipleRecipePhotos({
    required String recipeId,
    required List<File> files,
  }) async {
    try {
      final uploadTasks = files.asMap().entries.map((entry) {
        return uploadRecipePhoto(
          recipeId: recipeId,
          file: entry.value,
          fileName: 'photo_${entry.key}.jpg',
        );
      });

      return await Future.wait(uploadTasks);
    } catch (e) {
      throw Exception('Failed to upload multiple recipe photos: $e');
    }
  }

  // Upload multiple event photos
  Future<List<String>> uploadMultipleEventPhotos({
    required String eventId,
    required List<File> files,
  }) async {
    try {
      final uploadTasks = files.asMap().entries.map((entry) {
        return uploadEventPhoto(
          eventId: eventId,
          file: entry.value,
          fileName: 'photo_${entry.key}.jpg',
        );
      });

      return await Future.wait(uploadTasks);
    } catch (e) {
      throw Exception('Failed to upload multiple event photos: $e');
    }
  }
}
