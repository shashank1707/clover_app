import 'dart:io';

import 'package:clover_app/components/custom_button.dart';
import 'package:clover_app/components/custom_input.dart';
import 'package:clover_app/constants.dart';
import 'package:clover_app/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddProduct extends StatefulWidget {
  final Map user;
  const AddProduct({required this.user, Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  late File imageFile;
  bool filePicked = false;

  bool buttonLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 20);
    if (image != null) {
      setState(() {
        imageFile = File(image.path);
        filePicked = true;
      });
    } else {
      Fluttertoast.showToast(msg: 'No file selected!');
    }
  }

  Future<void> upload() async {

    if(!filePicked){
      Fluttertoast.showToast(msg: 'Choose a product image');
      return;
    }

    if (nameController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Enter valid name');
      return;
    }

    if (descriptionController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Enter description');
      return;
    }
    int price = 0;
    try {
      price = int.parse(priceController.text);
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Enter a valid price without any decimal unit.');
      return;
    }
    if (price <= 0) {
      Fluttertoast.showToast(msg: 'Enter a valid price');
      return;
    }
    setState(() {
      buttonLoading = true;
    });
    await DatabaseServices().addProduct(nameController.text, descriptionController.text, price, imageFile, widget.user['name'], widget.user['userId']).then((_){
      Fluttertoast.showToast(msg: 'Product added successfully');
      Navigator.pop(context);
    }).catchError((e){
      Fluttertoast.showToast(msg: 'Something went wrong');
    });
    setState(() {
      buttonLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Add Product',
          style: TextStyle(color: primaryTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
          child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                uploadWidget(width),
                CustomInput(
                    hintText: 'Product name',
                    controller: nameController,
                    icon: Icons.edit),
                priceInput(),
                descriptionInput(),
              ],
            ),
            CustomButton(buttonLoading: buttonLoading, onTap: (){upload();}, title: 'Upload')
          ],
        ),
      )),
    );
  }

  GestureDetector uploadWidget(double width) {
    return GestureDetector(
      onTap: () {
        pickImage();
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        height: width / 2,
        width: width / 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: secondaryTextColor),
            borderRadius: BorderRadius.circular(5)),
        child: filePicked
            ? ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.file(imageFile,
                    fit: BoxFit.cover, height: width / 2, width: width / 2))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: secondaryTextColor,
                    size: 48,
                  ),
                  Text(
                    'Upload product image',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                ],
              ),
      ),
    );
  }

  descriptionInput() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: fillColor, borderRadius: BorderRadius.circular(5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, right: 16, top: 8),
            child: Icon(
              Icons.notes,
              color: primaryTextColor,
            ),
          ),
          Expanded(
              child: TextField(
            controller: descriptionController,
            style: const TextStyle(color: primaryTextColor),
            maxLines: 4,
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Product description',
                hintStyle: TextStyle(
                    color: secondaryTextColor, fontWeight: FontWeight.bold)),
          ))
        ],
      ),
    );
  }

  priceInput() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: fillColor, borderRadius: BorderRadius.circular(5)),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, right: 16),
            child: Text(
              'CT',
              style: TextStyle(color: buttonColor, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
              child: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: primaryTextColor),
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Product price',
                hintStyle: TextStyle(
                    color: secondaryTextColor, fontWeight: FontWeight.bold)),
          ))
        ],
      ),
    );
  }
}
