import 'package:clover_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomButton extends StatelessWidget {
  final bool buttonLoading;
  final dynamic onTap;
  final String title;
  const CustomButton(
      {required this.buttonLoading, required this.onTap, required this.title, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MaterialButton(
        onPressed: buttonLoading ? () {} : onTap,
        color: buttonColor,
        padding: const EdgeInsets.all(16),
        minWidth: width,
        child: buttonLoading
            ? LoadingAnimationWidget.twoRotatingArc(
                color: primaryTextColor, size: 17)
            : Text(
                title,
                style: const TextStyle(
                    color: primaryTextColor, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
