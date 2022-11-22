import 'dart:developer';

import 'package:clover_app/components/custom_button.dart';
import 'package:clover_app/components/custom_input.dart';
import 'package:clover_app/constants.dart';
import 'package:clover_app/helpers/shared_preferences.dart';
import 'package:clover_app/screens/auth_screens/signup.dart';
import 'package:clover_app/screens/home.dart';
import 'package:clover_app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController privateKeyController = TextEditingController();

  bool buttonLoading = false;

  bool validateEmail() {
    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailController.text);
    return emailValid;
  }

  bool validatePassword() {
    return passwordController.text.length >= 6;
  }

  void login() async {
    setState(() {
      buttonLoading = true;
    });
    if(privateKeyController.text.length != 64){
      Fluttertoast.showToast(msg: 'Invalid private key.');
        setState(() {
          buttonLoading = false;
        });
        return;
    }
    if (validateEmail() && validatePassword()) {
      await SPServices().setPrivateKey(privateKeyController.text);
      final loginStatus = await AuthServices()
          .login(emailController.text, passwordController.text);
      if (!loginStatus) {
        Fluttertoast.showToast(msg: 'Invalid email or password.');
        setState(() {
          buttonLoading = false;
        });
        return;
      }

      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false);

      Fluttertoast.showToast(msg: 'Login successful');
    } else {
      Fluttertoast.showToast(msg: 'Invalid email or password.');
    }
    setState(() {
      buttonLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
          child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Text(
                    "Let's sign you in",
                    style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  CustomInput(
                      hintText: 'Email',
                      controller: emailController,
                      icon: Icons.email),
                  passwordField(),
                  CustomInput(
                    hintText: 'Enter metamask private key',
                    controller: privateKeyController,
                    icon: Icons.key),
                  CustomButton(buttonLoading: buttonLoading, onTap: (){login();}, title: 'Sign in'),
                  TextButton(
                      onPressed: () async {
                        String a = '175128d30ea9f116b8c91426cc8412584a3ff3148397554554765c401316fe6a';
                        print(a.length);
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                            color: primaryTextColor,
                            fontWeight: FontWeight.bold),
                      )),
                ],
              ),
              Column(
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Signup()));
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                            color: buttonColor, fontWeight: FontWeight.bold),
                      )),
                ],
              )
            ]),
      )),
    );
  }

  Container passwordField() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: fillColor, borderRadius: BorderRadius.circular(5)),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, right: 16),
            child: Icon(
              Icons.lock,
              color: primaryTextColor,
            ),
          ),
          Expanded(
              child: TextField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(color: primaryTextColor),
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Password',
                hintStyle: TextStyle(
                    color: secondaryTextColor, fontWeight: FontWeight.bold)),
          ))
        ],
      ),
    );
  }
}
