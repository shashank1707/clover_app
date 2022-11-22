import 'package:clover_app/constants.dart';
import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final IconData icon;
  const CustomInput(
      {required this.hintText,
      required this.controller,
      required this.icon,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: fillColor, borderRadius: BorderRadius.circular(5)),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 16),
            child: Icon(
              icon,
              color: primaryTextColor,
            ),
          ),
          Expanded(
              child: TextField(
            controller: controller,
            style: const TextStyle(color: primaryTextColor),
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(
                    color: secondaryTextColor, fontWeight: FontWeight.bold)),
          ))
        ],
      ),
    );
  }
}
