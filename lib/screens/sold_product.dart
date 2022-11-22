import 'package:clover_app/components/custom_button.dart';
import 'package:clover_app/constants.dart';
import 'package:flutter/material.dart';

class SoldProduct extends StatefulWidget {
  final Map user;
  final Map product;
  final String productId;
  const SoldProduct({required this.user, required this.product, required this.productId, Key? key}) : super(key: key);

  @override
  State<SoldProduct> createState() => _SoldProductState();
}

class _SoldProductState extends State<SoldProduct> {
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