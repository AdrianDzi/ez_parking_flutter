import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    final ref = FirebaseStorage.instance.ref(destination);
    return ref.putFile(file);
  }

  static Future<dynamic> loadImage(BuildContext context, String image) async {
    return await FirebaseStorage.instance.ref().child(image).getDownloadURL();
  }

  static Future<dynamic> loadImageWithoutContext(String image) async {
    return await FirebaseStorage.instance.ref().child(image).getDownloadURL();
  }

  static Future<dynamic> deleteFile(String image) {
    final ref = FirebaseStorage.instance.ref().child(image);
    return ref.delete();
  }
}
