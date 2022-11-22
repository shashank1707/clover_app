import 'package:clover_app/constants.dart';
import 'package:clover_app/helpers/shared_preferences.dart';
import 'package:clover_app/services/contract_services.dart';
import 'package:clover_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  Client? httpClient;
  Web3Client? ethClient;

  String ok = "button";

  List productImages1 = [
    "https://www.mydesignation.com/wp-content/uploads/2019/08/malayali-tshirt-mydesignation-mockup-image-latest-golden-.jpg",
    "https://cdn.shopify.com/s/files/1/1002/7150/products/New-Mockups---no-hanger---TShirt-Yellow.jpg?v=1639657077",
  ];

  List productImages2 = [
    "https://www.mydesignation.com/wp-content/uploads/2019/06/kandaka-shani-tshirt-mydesignation-image-latest-500x500.jpg",
    "https://m.media-amazon.com/images/I/61gqx7hslmL._UX569_.jpg",
    "https://www.mydesignation.com/wp-content/uploads/2019/08/malayali-tshirt-mydesignation-mockup-image-latest-golden-.jpg",
    "https://www.mydesignation.com/wp-content/uploads/2019/06/but-why-tshirt-mydesignation-image-latest.jpg"
  ];

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(node_url, httpClient!);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   // actions: const [Icon(Icons.person)],
      //   title: const Text(
      //     'c l o v e r',
      //     style:
      //         TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
      //   ),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(child: ElevatedButton(child: Text('button'), onPressed: ()async{
            final address = await SPServices().getWalletAddress();
            final res = await ContractServices().transfer(address, ethClient!, 1000);
            print(res);
          },),),
        ),
      ),
    );
  }

  Container test1(double width) {
    return Container(
          margin: EdgeInsets.all(16),
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trending',
                style: TextStyle(
                    color: primaryTextColor, fontWeight: FontWeight.bold),
              ),
              Wrap(children: [
                ...(productImages1).map((e){
                  return Container(
                    width: width/2.5,
                    height: width/2,
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: secondaryTextColor.withOpacity(0.2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(child: Image.network(e), borderRadius: BorderRadius.circular(5),),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tshirt', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),),
                              Text('300 CT', style: TextStyle(color: buttonColor, fontWeight: FontWeight.bold),)
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                })
              ],),
              SizedBox(height: 30,),
              Text(
                'New Collection',
                style: TextStyle(
                    color: primaryTextColor, fontWeight: FontWeight.bold),
              ),
              Wrap(children: [
                ...(productImages2).map((e){
                  return Container(
                    width: width/2.5,
                    height: width/2,
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: secondaryTextColor.withOpacity(0.2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(child: Image.network(e), borderRadius: BorderRadius.circular(5),),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tshirt', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),),
                              Text('300 CT', style: TextStyle(color: buttonColor, fontWeight: FontWeight.bold),)
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                })
              ],)
            ],
          ),
        );
  }
}
