import 'package:clover_app/components/custom_button.dart';
import 'package:clover_app/constants.dart';
import 'package:clover_app/helpers/shared_preferences.dart';
import 'package:clover_app/screens/home.dart';
import 'package:clover_app/screens/profile.dart';
import 'package:clover_app/services/contract_services.dart';
import 'package:clover_app/services/database_services.dart';
import 'package:clover_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class Product extends StatefulWidget {
  final Map user;
  final Map product;
  final String productId;
  const Product({required this.user, required this.product, required this.productId, Key? key})
      : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  Client? httpClient;
  Web3Client? ethClient;
  bool buttonLoading = false;
  late dynamic balance;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(node_url, httpClient!);
    getBalance();
  }

  getBalance() async {
    String address = widget.user['walletAddress'];
    balance =
        ((await ContractServices().balanceOf(address, ethClient!))[0].toInt());
        setState(() {
          
        });
  }

  void buy() async {
    setState(() {
      buttonLoading = true;
    });
    String address = widget.user['walletAddress'];
    String sellerWalletAddress = await DatabaseServices()
        .getSellerWalletAddress(widget.product['sellerId']);
    int price = widget.product['price'];
    balance =
        ((await ContractServices().balanceOf(address, ethClient!))[0].toInt());
    if (balance < price) {
      Fluttertoast.showToast(msg: 'Low balance');
      setState(() {
        buttonLoading = false;
      });
      return;
    }
    final res = await ContractServices()
        .transfer(sellerWalletAddress, ethClient!, price);
    await DatabaseServices().placeOrder(widget.user['userId'], widget.product['sellerId'], res.toString(), widget.productId, price, widget.product['name'], widget.user['deliveryAddress'], widget.user['name']).then((_){
      Fluttertoast.showToast(msg: 'Order placed');
      Navigator.pop(context);
    });
    setState(() {
      buttonLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.product['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Visibility(
        visible: !widget.product['sold'],
        child: CustomButton(
            buttonLoading: buttonLoading,
            onTap: () {
              if(widget.user['deliveryAddress'].isNotEmpty){
                buy();
              }else{
                showDialog(context: context, builder: (context){
                  return AlertDialog(
                    backgroundColor: const Color.fromARGB(255, 16, 16, 16),
                    title: const Text('Address not found', style: TextStyle(color: primaryTextColor),),
                    actions: [
                      TextButton(onPressed: (){
                        Navigator.pop(context);
                      }, child: const Text('Cancel', style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.bold),)),
                      TextButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (conetxt) => Profile(user: widget.user, balance: balance)));
                      }, child: const Text('Okay', style: TextStyle(color: buttonColor, fontWeight: FontWeight.bold),)),
                    ],
                    content: const Text('Add address to continue.', style: TextStyle(color: secondaryTextColor),),
                  );
                });
              }
              
            },
            title: 'Place Order'),
      ),
      body: SafeArea(
          child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    widget.product['image'],
                    height: width / 1.5,
                    width: width,
                    fit: BoxFit.cover,
                  )),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 32),
              title: Text(
                '${widget.product['name']}',
                style: const TextStyle(
                    color: primaryTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '@${widget.product['sellerName']}',
                style: const TextStyle(color: secondaryTextColor, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: widget.product['sold']
                  ? Text('SOLD',
                      style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 24))
                  : Text('${widget.product['price']} CT',
                      style: const TextStyle(
                          color: buttonColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 24)),
            ),
            Container(
                width: width,
                height: width / 2,
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: fillColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5)),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('@description\n',
                          style: TextStyle(
                            color: secondaryTextColor,
                          )),
                      Text(
                        widget.product['description'],
                        style: TextStyle(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      )),
    );
  }
}
