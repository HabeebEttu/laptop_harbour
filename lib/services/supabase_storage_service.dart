import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucketName =
      'laptops'; 

  /// function to upload image to Supabase Storage
  Future<String> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    required String folder,
    Duration signedUrlDuration = const Duration(hours: 100000), // default expiry
  }) async {
    try {
      final filePath = '$folder/$fileName';

      // upload the image to Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            filePath,
            imageBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final response = await _supabase.storage
          .from(_bucketName)
          .createSignedUrl(filePath, signedUrlDuration.inSeconds);

      if (response.isEmpty) {
        throw Exception('Failed to generate signed URL');
      }

      return response;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteImage({
    required String fileName,
    required String folder,
  }) async {
    try {
      final filePath = '$folder/$fileName';

      await _supabase.storage.from(_bucketName).remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages({
    required List<Uint8List> imageBytesList,
    required List<String> fileNames,
    required String folder,
  }) async {
    if (imageBytesList.length != fileNames.length) {
      throw Exception(
        'Image bytes list and file names list must have the same length',
      );
    }

    final List<String> uploadedUrls = [];

    for (int i = 0; i < imageBytesList.length; i++) {
      try {
        final url = await uploadImage(
          imageBytes: imageBytesList[i],
          fileName: fileNames[i],
          folder: folder,
        );
        uploadedUrls.add(url);
      } catch (e) {
        // If one upload fails, delete previously uploaded images
        for (int j = 0; j < uploadedUrls.length; j++) {
          try {
            await deleteImage(fileName: fileNames[j], folder: folder);
          } catch (deleteError) {
            // Log delete error but don't throw
            print('Failed to delete image during cleanup: $deleteError');
          }
        }
        throw Exception('Failed to upload image ${fileNames[i]}: $e');
      }
    }

    return uploadedUrls;
  }

  /// Get public URL for an existing file
  String getPublicUrl({required String fileName, required String folder}) {
    final filePath = '$folder/$fileName';
    return _supabase.storage.from(_bucketName).getPublicUrl(filePath);
  }

  /// Check if file exists
  Future<bool> fileExists({
    required String fileName,
    required String folder,
  }) async {
    try {
      final filePath = '$folder/$fileName';
      final files = await _supabase.storage
          .from(_bucketName)
          .list(path: folder);

      return files.any((file) => file.name == fileName);
    } catch (e) {
      return false;
    }
  }

  /// Replace existing image with new one
  Future<String> replaceImage({
    required Uint8List imageBytes,
    required String fileName,
    required String folder,
  }) async {
    try {
      final filePath = '$folder/$fileName';

      // Upload with upsert: true to replace existing file
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            filePath,
            imageBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, // This will replace the existing file
            ),
          );

      // Get the public URL
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to replace image: $e');
    }
  }

  /// List all files in a folder
  Future<List<FileObject>> listFiles({
    required String folder,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final files = await _supabase.storage
          .from(_bucketName)
          .list(
            path: folder,
            searchOptions: SearchOptions(limit: limit, offset: offset),
          );

      return files;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  /// Get file metadata
  Future<FileObject?> getFileInfo({
    required String fileName,
    required String folder,
  }) async {
    try {
      final files = await listFiles(folder: folder);
      return files.firstWhere(
        (file) => file.name == fileName,
        orElse: () => throw Exception('File not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Create a signed URL for private access (if bucket is private)
  Future<String> createSignedUrl({
    required String fileName,
    required String folder,
    int expiresIn = 3600, // 1 hour by default
  }) async {
    try {
      final filePath = '$folder/$fileName';

      final signedUrl = await _supabase.storage
          .from(_bucketName)
          .createSignedUrl(filePath, expiresIn);

      return signedUrl;
    } catch (e) {
      throw Exception('Failed to create signed URL: $e');
    }
  }

  /// Download file as bytes
  Future<Uint8List> downloadFile({
    required String fileName,
    required String folder,
  }) async {
    try {
      final filePath = '$folder/$fileName';

      final bytes = await _supabase.storage
          .from(_bucketName)
          .download(filePath);

      return bytes;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }
}
