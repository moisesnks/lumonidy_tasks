// Path: lib/services/storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File imageFile, String userId) async {
    try {
      String fileName = 'profile_images/$userId';
      String? mimeType = lookupMimeType(imageFile.path);
      if (mimeType == null) {
        throw Exception('File type not recognized');
      }

      Reference storageRef = _storage.ref().child(fileName);

      // Subir imagen al Storage
      await storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: mimeType),
      );

      // Obtener URL de la imagen
      String downloadURL = await storageRef.getDownloadURL();

      return downloadURL;
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir el archivo: $e');
      }
      rethrow; // Vuelve a lanzar el error para manejarlo en el nivel superior
    }
  }
}
