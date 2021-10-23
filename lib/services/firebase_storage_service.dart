import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/services/storage_base.dart';
import 'package:path/path.dart';

class FirebaseStorageService implements StorageBase {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  late Reference _storageReference;

  @override
  Future<String> uploadFile(
      String userID, String fileType, File yuklenecekDosya) async {
    _storageReference = _firebaseStorage
        .ref()
        .child(userID)
        .child(fileType)
        .child(basename(yuklenecekDosya.path));
    UploadTask uploadTask = _storageReference.putFile(yuklenecekDosya);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      debugPrint(
          'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (e) {
      if (e.code == 'permission-denied') {
        debugPrint(
            'User does not have permission to upload to this reference.');
      }
    });
    await uploadTask;
    return await _storageReference.getDownloadURL();
  }
}
