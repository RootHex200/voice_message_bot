


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<Either<Exception,String>> saveDataToFirestore(String docid, Map<String, dynamic> data) async {

  try{
    CollectionReference voicechatCollection = FirebaseFirestore.instance.collection("users");
    await voicechatCollection.doc(docid.toString()).collection("messages").add(data);
    return const Right("success");
  }catch (e){
    return Left(e as Exception);
  }
}


Future<Either<Exception,String>> saveDataToStorage(String filePath) async {
  var filename=filePath.split("/").last;
  try{
    final ref = FirebaseStorage.instance.ref().child(filename);
    await ref.putFile(File(filePath));
    return Right(await ref.getDownloadURL());
  }catch (e){
    return Left(e as Exception);
  }
}