
import 'package:shared_preferences/shared_preferences.dart';

class SPServices {

  static const String walletAddressKey = 'WALLET_ADDRESS_KEY';
  static const String userIdKey = 'USER_ID_KEY';
  static const String privateKeyKey = 'PRIVATE_KEY_KEY';

  Future<void> setWalletAddress(String walletAddress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(walletAddressKey, walletAddress);
  }

  Future<String> getWalletAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(walletAddressKey) ?? '';
  }

  Future<void> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userIdKey, userId);
  }

  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey) ?? '';
  }

  Future<void> setPrivateKey(String privateKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(privateKeyKey, privateKey);
  }

  Future<String> getPrivateKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(privateKeyKey) ?? '';
  }

  Future<bool> removeData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }


}