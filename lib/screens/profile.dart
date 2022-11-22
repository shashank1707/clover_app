import 'package:clover_app/components/custom_button.dart';
import 'package:clover_app/components/custom_input.dart';
import 'package:clover_app/components/loading.dart';
import 'package:clover_app/constants.dart';
import 'package:clover_app/helpers/shared_preferences.dart';
import 'package:clover_app/screens/auth_screens/login.dart';
import 'package:clover_app/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_avatar/random_avatar.dart';

class Profile extends StatefulWidget {
  final Map user;
  final dynamic balance;
  const Profile({required this.user, required this.balance, Key? key})
      : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isAddress = false;
  bool isLoading = true;
  Map address = {};

  TextEditingController phoneController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  bool buttonLoading = false;

  @override
  void initState() {
    setState(() {
      isAddress = widget.user['deliveryAddress'].isNotEmpty;
      isLoading = false;
    });
    if (widget.user['deliveryAddress'].isNotEmpty) {
      phoneController.text = widget.user['deliveryAddress']['phone'];
      pincodeController.text = widget.user['deliveryAddress']['pincode'];
      addressController.text = widget.user['deliveryAddress']['address'];
      setState(() {
        address = widget.user['deliveryAddress'];
      });
    }
    super.initState();
  }

  saveAddress() async {
    address = {
      'phone': phoneController.text,
      'pincode': pincodeController.text,
      'address': addressController.text
    };
    await DatabaseServices().saveAddress(widget.user['userId'], address);
    setState((){
      isAddress = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return isLoading
        ? const Loading()
        : Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                    onPressed: () {
                      SPServices().removeData();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                          (route) => false);
                    },
                    icon: const Icon(Icons.logout)),
              ],
            ),
            body: SafeArea(
                child: SizedBox(
              width: width,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 2, color: buttonColor),
                                shape: BoxShape.circle),
                            child: randomAvatar(widget.user['userId'],
                                height: width / 4, width: width / 4)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.user['name'],
                                style: const TextStyle(
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${widget.balance} CT',
                                style: const TextStyle(
                                    color: buttonColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 32,
                          ),
                          const Text(
                            'Email',
                            style: TextStyle(
                                color: secondaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            widget.user['email'],
                            style: const TextStyle(
                                color: primaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          const Text(
                            'Wallet',
                            style: TextStyle(
                                color: secondaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            widget.user['walletAddress'],
                            style: const TextStyle(
                                color: primaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          Row(
                            children: [
                              const Text(
                                'Address',
                                style: TextStyle(
                                    color: secondaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              IconButton(
                                  onPressed: () {
                                    addressDialog(width);
                                  },
                                  icon: Icon(
                                    !isAddress ? Icons.add_circle : Icons.edit,
                                    color: buttonColor,
                                    size: 16,
                                  )),
                            ],
                          ),
                          isAddress ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                address['phone'],
                                style: const TextStyle(
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              
                              Text(
                                address['address'],
                                style: const TextStyle(
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Text(
                                address['pincode'],
                                style: const TextStyle(
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ],
                          ) : const Text(
                                'Add a new address',
                                style: TextStyle(
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )),
          );
  }

  addressDialog(width) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Address', style: TextStyle(color: primaryTextColor),),
            backgroundColor: const Color.fromARGB(255, 16, 16, 16),
            children: [
              CustomInput(
                  hintText: 'Phone',
                  controller: phoneController,
                  icon: Icons.phone),
              CustomInput(
                  hintText: 'Pincode',
                  controller: pincodeController,
                  icon: Icons.code),
              addressInput(),
              CustomButton(
                  buttonLoading: buttonLoading, onTap: () {
                    if(phoneController.text.isNotEmpty && pincodeController.text.isNotEmpty && addressController.text.isNotEmpty){
                      saveAddress();
                      Navigator.pop(context);
                    }else{
                      Fluttertoast.showToast(msg: 'Enter required details');
                    }
                  }, title: 'Save')
            ],
          );
        });
  }

  addressInput() {
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
              Icons.location_on,
              color: primaryTextColor,
            ),
          ),
          Expanded(
              child: TextField(
            controller: addressController,
            style: const TextStyle(color: primaryTextColor),
            maxLines: 4,
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Complete address',
                hintStyle: TextStyle(
                    color: secondaryTextColor, fontWeight: FontWeight.bold)),
          ))
        ],
      ),
    );
  }
}
