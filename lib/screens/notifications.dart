import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clover_app/constants.dart';
import 'package:clover_app/helpers/helper_functions.dart';
import 'package:clover_app/screens/order.dart';
import 'package:clover_app/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Notifications extends StatefulWidget {
  final Map user;
  const Notifications({required this.user, Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  bool seen = false;

  selectNotificationTypeButton(width) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: width / 8,
      width: width,
      decoration:
          BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                seen = false;
              });
            },
            child: Container(
              alignment: Alignment.center,
              height: width / 10,
              width: width / 3,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: !seen
                      ? backgroundColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'New',
                style: TextStyle(
                    color: !seen ? buttonColor : secondaryTextColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                seen = true;
              });
            },
            child: Container(
              alignment: Alignment.center,
              height: width / 10,
              width: width / 3,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: seen
                      ? backgroundColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Older',
                style: TextStyle(
                    color: seen ? buttonColor : secondaryTextColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }


  notificationBuilder(seen){
    return StreamBuilder(
      stream: DatabaseServices().getNotifications(widget.user['userId'], seen),
      builder: (context, AsyncSnapshot snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(color: buttonColor,),
            ),
          );
        }
        return snapshot.hasData && snapshot.data.docs.length > 0 ? ListView.builder(
        itemCount: snapshot.data.docs.length,
        shrinkWrap: true,
        itemBuilder: (context, index){
          final notification = snapshot.data.docs[index];
          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(10)
            ),
            child: ListTile(
              title: Text('${notification['buyerName']} has placed an order for ${notification['productName']}', style: const TextStyle(color: primaryTextColor)),
              trailing: Text(convertTimestamp(notification['timestamp']), textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, color: secondaryTextColor),),
              onTap: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Order(orderId: notification['orderId'])));
                await DatabaseServices().seeNotification(notification.id);
              },
            ),
          );
        },
      ): Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(seen ? 'No previous notifications.' : 'No new notifications.', style: const TextStyle(color: primaryTextColor),),
        ),
      );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: backgroundColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 8),
            child: Text('Notification Type', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),),
          ),
          selectNotificationTypeButton(width),
          Expanded(child: seen ? notificationBuilder(true) : notificationBuilder(false))
        ],
      )
    );
  }
}