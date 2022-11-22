import 'package:clover_app/components/custom_button.dart';
import 'package:clover_app/components/custom_input.dart';
import 'package:clover_app/constants.dart';
import 'package:clover_app/screens/auth_screens/connect_wallet.dart';
import 'package:clover_app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  bool validateEmail() {
    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailController.text);
    return emailValid;
  }

  bool validatePassword() {
    return passwordController.text.length >= 6;
  }

  bool validateName() {
    return nameController.text.length >= 3;
  }

  void validateAndRedirect() async {
    if (!validateName()) {
      Fluttertoast.showToast(msg: 'Name should contain at least 3 characters.');
      return;
    }

    if (!validateEmail()) {
      Fluttertoast.showToast(msg: 'Invalid email format.');
      return;
    }

    if (!validatePassword()) {
      Fluttertoast.showToast(
          msg: 'Password should contain at least 6 characters.');
      return;
    }

    if(await AuthServices().doesUserExist(emailController.text)){
      Fluttertoast.showToast(msg: 'Email already registered.');
      return;
    }

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ConnectWallet(
                  name: nameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                )));
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
                    "Let's sign you up",
                    style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  CustomInput(
                      hintText: 'Name',
                      controller: nameController,
                      icon: Icons.person),
                  CustomInput(
                      hintText: 'Email',
                      controller: emailController,
                      icon: Icons.email),
                  passwordField(),
                  CustomButton(buttonLoading: false, onTap: () {
                        validateAndRedirect();
                      }, title: 'Sign up')
                ],
              ),
              Column(
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Sign in',
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
