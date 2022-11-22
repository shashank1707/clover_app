import 'package:clover_app/constants.dart';
import 'package:clover_app/helpers/shared_preferences.dart';
import 'package:clover_app/screens/auth_screens/login.dart';
import 'package:clover_app/screens/home.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    redirect();
  }

  Future<bool> isLoggedIn() async {
    final userId = await SPServices().getUserId();
    return userId != '';
  }

  void redirect() {
    Future.delayed(const Duration(seconds: 1)).then((value) async {
      if (await isLoggedIn()) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Home()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Login()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return const Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
          child: Text(
        'c l o v e r',
        style: TextStyle(color: primaryTextColor, fontSize: 32),
      )),
    );
  }
}
