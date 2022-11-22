import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clover_app/helpers/encryption.dart';
import 'package:clover_app/helpers/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DatabaseServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String userId) async {
    return await firestore.collection('users').doc(userId).get();
  }

  getUserSnapshots(String userId) {
    return firestore.collection('users').doc(userId).snapshots();
  }

  Future<void> addProduct(String name, String description, int price, File imageFile, String sellerName, String sellerId) async {
    final docRef = firestore.collection('products').doc();
    await docRef.set({
      'name': name,
      'price': price,
      'description': description,
      'sellerName': sellerName,
      'sellerId': sellerId,
      'timestamp': DateTime.now(),
      'image': '',
      'sold': false
    });
    await updateImage(docRef.id, imageFile, name);
  }

  Future<void> updateImage(String productId, File file, String fileName) async {
    final filePath = 'products/$productId/$fileName';

    await storage.ref(filePath).putFile(file);

    await storage.ref(filePath).getDownloadURL().then((value) async {
      await firestore.collection('products').doc(productId).update({'image': value});
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getOwnProducts(String userId) {
    return firestore.collection('products').where('sellerId', isEqualTo: userId).orderBy('timestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getOtherProducts(String userId) {
    return firestore.collection('products').where('sellerId', isNotEqualTo: userId).snapshots();
  }

  Future<String> getSellerWalletAddress(String sellerId) async {
    return (await firestore.collection('users').doc(sellerId).get())['walletAddress'];
  }

  Future<void> placeOrder(String buyerId, String sellerId, String transactionId, String productId, int price, String productName, deliveryAddress, String buyerName) async {
    final docRef = firestore.collection('orders').doc();
    await docRef.set({
      'buyerId': buyerId,
      'buyerName': buyerName,
      'sellerId': sellerId,
      'transactionId': transactionId,
      'productId': productId,
      'price': price,
      'productName': productName,
      'deliveryAddress': deliveryAddress,
      'timestamp': DateTime.now()
    });

    await firestore.collection('products').doc(productId).update({
      'sold': true
    });

    await sendNotification(buyerId, sellerId, productId, productName, docRef.id, buyerName);
  }

  Future<void> sendNotification(String buyerId, String sellerId, String productId, String productName, String orderId, String buyerName) async {
    await firestore.collection('notifications').doc().set({
      'sellerId': sellerId,
      'productId': productId,
      'buyerId': buyerId,
      'productName': productName,
      'orderId': orderId,
      'buyerName': buyerName,
      'seen': false,
      'timestamp': DateTime.now()
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getOrders(String userId) async {
    return await firestore.collection('orders').where('buyerId', isEqualTo: userId).get();
  }

  Future<Map<String, dynamic>?> getProductDetails(String productId) async {
    return (await firestore.collection('products').doc(productId).get()).data();
  }

  Future<String> getUsername(String userId) async {
    return (await firestore.collection('users').doc(userId).get())['name'];
  }

  saveAddress(String userId, Map address) async {
    await firestore.collection('users').doc(userId).update({
      'deliveryAddress': address 
    });
  }

  getNotifications(String userId, bool seen) {
    return firestore.collection('notifications').where('sellerId', isEqualTo: userId).where('seen', isEqualTo: seen).orderBy('timestamp').snapshots();
  }

  seeNotification(String notificationId) async {
    await firestore.collection('notifications').doc(notificationId).update({
      'seen': true 
    });
  }

  getOrder(String orderId) async {
    return (await firestore.collection('orders').doc(orderId).get()).data();
  }
}
