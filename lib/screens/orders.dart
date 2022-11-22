import 'package:clover_app/components/loading.dart';
import 'package:clover_app/constants.dart';
import 'package:clover_app/helpers/helper_functions.dart';
import 'package:clover_app/screens/order.dart';
import 'package:clover_app/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Orders extends StatefulWidget {
  final Map user;
  const Orders({required this.user, Key? key}) : super(key: key);

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Orders',
                    style: TextStyle(
                        color: primaryTextColor, fontWeight: FontWeight.bold),
                  ),
                )),
            Expanded(child: orderBuilder(width)),
          ],
        ),
      ),
    );
  }

  Widget orderBuilder(width) {
    return FutureBuilder(
      future: DatabaseServices().getOrders(widget.user['userId']),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.twoRotatingArc(
                color: buttonColor, size: 34),
          );
        }
        return snapshot.hasData && snapshot.data.docs.length > 0
            ? GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.65),
                itemBuilder: (context, index) {
                  final Map order = snapshot.data.docs[index].data();
                  return FutureBuilder(
                    future: DatabaseServices()
                        .getProductDetails(order['productId']),
                    builder: (context, AsyncSnapshot snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: LoadingAnimationWidget.twoRotatingArc(
                              color: buttonColor, size: 34),
                        );
                      }
                      return snap.hasData
                          ? GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Order(orderId: snapshot.data.docs[index].id)));
                            },
                            child: Container(
                                width: width / 2,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: fillColor.withOpacity(0.5)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.network(
                                        snap.data['image'],
                                        height: width / 2.5,
                                        width: width / 2.5,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        '${snap.data['name']}',
                                        style: const TextStyle(
                                            color: primaryTextColor),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        convertTimestamp(order['timestamp']),
                                        style: const TextStyle(
                                            color: secondaryTextColor),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Text('${order['price']} CT',
                                          style: const TextStyle(
                                              color: buttonColor,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                              ),
                          )
                          : Center(
                              child: LoadingAnimationWidget.twoRotatingArc(
                                  color: buttonColor, size: 17),
                            );
                    },
                  );
                },
              )
            : Center(
                child: Column(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.notes,
                        size: 48,
                        color: secondaryTextColor,
                      ),
                    ),
                    Text(
                      'No recent orders',
                      style: TextStyle(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              );
      },
    );
  }
}
