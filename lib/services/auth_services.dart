import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clover_app/helpers/encryption.dart';
import 'package:clover_app/helpers/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<bool> doesUserExist(String email) async {
    final userList = (await firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get())
        .docs;
    
    return userList.isNotEmpty;
  }

  Future<bool> signup(
      String name, String email, String password, String walletAddress) async {
    String encryptedPassword = Encryption().encrypt(password);

    if (await doesUserExist(email)) {
      Fluttertoast.showToast(msg: 'User already registered');
      return false;
    }

    final docRef = firestore.collection('users').doc();
    await docRef.set({
      'name': name,
      'email': email,
      'password': encryptedPassword,
      'walletAddress': walletAddress,
      'deliveryAddress': {}
    });
    await SPServices().setUserId(docRef.id);
    return true;
  }

  Future<bool> login(String email, String password) async {
    String encryptedPassword = Encryption().encrypt(password);
    final userList = (await firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get())
        .docs;

    if (userList.isEmpty) {
      return false;
    }

    final user = userList[0];

    if (user['password'] != encryptedPassword) {
      return false;
    }

    await SPServices().setUserId(user.id);
    await SPServices().setWalletAddress(user['walletAddress']);
    return true;
  }
}
