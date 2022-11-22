import 'package:clover_app/components/loading.dart';
import 'package:clover_app/components/test.dart';
import 'package:clover_app/constants.dart';
import 'package:clover_app/helpers/shared_preferences.dart';
import 'package:clover_app/screens/auth_screens/login.dart';
import 'package:clover_app/screens/auth_screens/signup.dart';
import 'package:clover_app/screens/buy.dart';
import 'package:clover_app/screens/notifications.dart';
import 'package:clover_app/screens/orders.dart';
import 'package:clover_app/screens/profile.dart';
import 'package:clover_app/screens/sell.dart';
import 'package:clover_app/services/database_services.dart';
import 'package:clover_app/services/contract_services.dart';
import 'package:clover_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:web3dart/web3dart.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  Client? httpClient;
  Web3Client? ethClient;
  int navigationIndex = 0;
  late TabController tabController;
  late List<Widget> screens;
  bool isLoading = true;
  late dynamic balance;
  late Map<String, dynamic> user;
  bool refreshButtonLoading = false;

  @override
  void initState() {
    httpClient = Client();
    ethClient = Web3Client(node_url, httpClient!);
    tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    getUserData();
    super.initState();
  }

  getUserData() async {
    final uid = await SPServices().getUserId();
    await DatabaseServices().getUserData(uid).then((value) {
      setState(() {
        user = {...value.data()!, 'userId': uid};
        screens = [
          Buy(user: {...value.data()!, 'userId': uid}),
          Sell(user: {...value.data()!, 'userId': uid}),
          Orders(user: {...value.data()!, 'userId': uid},),
          const Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: Text('Settings', style: TextStyle(color: buttonColor),),
            ),
          )
        ];
      });
    });
    getBalance();
  }

  getBalance() async {
    setState(() {
      refreshButtonLoading = true;
    });
    final address = user['walletAddress'];
    final b = (await ContractServices().balanceOf(address, ethClient!))[0];
    setState(() {
      balance = b;
      isLoading = false;
      refreshButtonLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return isLoading
        ? const Loading()
        : Scaffold(
            backgroundColor: backgroundColor,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                 IconButton(
                    onPressed: () {
                      getBalance();
                      getUserData();
                    },
                    icon: refreshButtonLoading ? LoadingAnimationWidget.twoRotatingArc(color: buttonColor, size: 17) : const Icon(Icons.refresh)),
                IconButton(
                    onPressed: () {
                      
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Notifications(user: user,)));
                    },
                    icon: StreamBuilder(
                      stream: DatabaseServices().getNotifications(user['userId'], false),
                      builder: (context, AsyncSnapshot snapshot){
                        return snapshot.hasData && snapshot.data.docs.length > 0 ? const Icon(Icons.notifications_active, color: buttonColor,): const Icon(Icons.notifications, color: primaryTextColor,);
                      },
                    )),
              ],
              title: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(user: user, balance: balance)));
                },
                child: Row(
                  children: [
                    Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: buttonColor),
                            shape: BoxShape.circle),
                        child: randomAvatar(user['userId'],
                            height: width / 8, width: width / 8)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'],
                            style: const TextStyle(
                                color: primaryTextColor,
                                fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$balance CT',
                            style: const TextStyle(
                                color: buttonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SalomonBottomBar(
                currentIndex: navigationIndex,
                onTap: (index) {
                  setState(() {
                    navigationIndex = index;
                    tabController.index = index;
                  });
                },
                items: [
                  SalomonBottomBarItem(
                      icon: const Icon(Icons.shopping_cart),
                      title: const Text("Buy"),
                      selectedColor: buttonColor,
                      unselectedColor: primaryTextColor),

                  /// Likes
                  SalomonBottomBarItem(
                      icon: const Icon(Icons.sell),
                      title: const Text("Sell"),
                      selectedColor: buttonColor,
                      unselectedColor: primaryTextColor),

                  /// Search
                  SalomonBottomBarItem(
                      icon: const Icon(Icons.history),
                      title: const Text("Orders"),
                      selectedColor: buttonColor,
                      unselectedColor: primaryTextColor),

                  /// Profile
                  SalomonBottomBarItem(
                      icon: const Icon(Icons.settings),
                      title: const Text("Settings"),
                      selectedColor: buttonColor,
                      unselectedColor: primaryTextColor),
                ]),
            body: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: screens,
            ),
          );
  }
}
