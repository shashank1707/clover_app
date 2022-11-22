import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clover_app/components/loading.dart';
import 'package:clover_app/constants.dart';
import 'package:clover_app/screens/add_product.dart';
import 'package:clover_app/screens/sold_product.dart';
import 'package:clover_app/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Sell extends StatefulWidget {
  final Map user;
  const Sell({required this.user, Key? key}) : super(key: key);

  @override
  State<Sell> createState() => _SellState();
}

class _SellState extends State<Sell> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => AddProduct(user: widget.user))));
        },
        backgroundColor: buttonColor,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
          child: Column(
            children: [
              const Align(alignment: Alignment.centerLeft, child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Your Products', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),),
              )),
              Expanded(child: productBuilder(width)),
            ],
          )),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> productBuilder(double width) {
    return StreamBuilder(
      stream: DatabaseServices().getOwnProducts(widget.user['userId']),
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.65),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final Map product = snapshot.data.docs[index].data();
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SoldProduct(
                                  user: widget.user, product: product, productId: snapshot.data.docs[index].id,)));
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
                              product['image'],
                              height: width / 2.5,
                              width: width / 2.5,
                              fit: BoxFit.cover,
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              '${product['name']}',
                              style: const TextStyle(color: primaryTextColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '@${product['sellerName']}',
                              style: const TextStyle(color: secondaryTextColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: product['sold']
                                  ? Text('SOLD',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold))
                                  :  Text('${product['price']} CT',
                                style: const TextStyle(
                                    color: buttonColor,
                                    fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  );
                })
            : Center(
                child: Column(
                  children: const [Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(Icons.sell_outlined, size: 48, color: secondaryTextColor,),
                  ), Text('Add products to sell', style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.bold),)],
                ),
              );
      },
    );
  }
}
