import 'package:clover_app/components/loading.dart';
import 'package:clover_app/constants.dart';
import 'package:clover_app/helpers/helper_functions.dart';
import 'package:clover_app/services/database_services.dart';
import 'package:flutter/material.dart';

class Order extends StatefulWidget {
  final String orderId;
  const Order({required this.orderId, Key? key}) : super(key: key);

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: DatabaseServices().getOrder(widget.orderId),
      builder: (context, AsyncSnapshot snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        }
        return snapshot.hasData ? Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            snapshot.data['productName'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        
        body: SafeArea(
            child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                title: Text(
                  '${snapshot.data['productName']}',
                  style: const TextStyle(
                      color: primaryTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  convertTimestamp(snapshot.data['timestamp']),
                  style: const TextStyle(color: secondaryTextColor, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing:Text('${snapshot.data['price']} CT',
                        style: const TextStyle(
                            color: buttonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24)),
              ),
              Container(
                  width: width,
                  height: width / 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: fillColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(5)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('@delivery address\n',
                            style: TextStyle(
                              color: secondaryTextColor,
                            )),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data['buyerName'],
                                style: const TextStyle(
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Text(
                                snapshot.data['deliveryAddress']['phone'],
                                style: const TextStyle(
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              SizedBox(height: 16,),
                              Text(
                                snapshot.data['deliveryAddress']['address'],
                                style: const TextStyle(
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Text(
                                snapshot.data['deliveryAddress']['pincode'],
                                style: const TextStyle(
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ],
                          )
                      ],
                    ),
                  )),
            ],
          ),
        )),
      ) : const Loading();
      },
      
    );
  }
}