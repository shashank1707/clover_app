import 'package:appcheck/appcheck.dart';
import 'package:clover_app/components/custom_input.dart';
import 'package:clover_app/constants.dart';
import 'package:clover_app/helpers/shared_preferences.dart';
import 'package:clover_app/screens/home.dart';
import 'package:clover_app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class ConnectWallet extends StatefulWidget {
  final String name, email, password;
  const ConnectWallet(
      {required this.name,
      required this.email,
      required this.password,
      Key? key})
      : super(key: key);

  @override
  State<ConnectWallet> createState() => _ConnectWalletState();
}

class _ConnectWalletState extends State<ConnectWallet> {
  late SessionStatus sessionStatus;
  late WalletConnect connector;

  bool connected = false;
  String walletAddress = "";

  bool buttonLoading = false;

  TextEditingController privateKeyController = TextEditingController();
  TextEditingController walletController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // getWalletAddress();
  }

  // void getWalletAddress() async {
  //   await SPServices().getWalletAddress().then((value) {
  //     if (value != '') {
  //       setState(() {
  //         connected = true;
  //         walletAddress = value;
  //       });
  //     }
  //   });
  // }

  // void saveWalletAddress(address) async {
  //   await SPServices().setWalletAddress(address);
  // }

  // void openMetamask(uri) async {
  //   const appId = 'io.metamask';
  //   bool canLaunch = true;

  //   await AppCheck.checkAvailability(appId).catchError((onError) {
  //     canLaunch = false;
  //   });

  //   if (canLaunch) {
  //     launchUrlString(uri);
  //   } else {
  //     launchUrlString("market://details?id=$appId",
  //         mode: LaunchMode.externalApplication);
  //   }
  // }

  // void connectToMetamask() async {
  //   // Create a connector
  //   connector = WalletConnect(
  //     bridge: 'https://bridge.walletconnect.org',
  //     clientMeta: const PeerMeta(
  //       name: 'WalletConnect',
  //       description: 'WalletConnect Developer App',
  //       url: 'https://walletconnect.org',
  //       icons: [
  //         'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
  //       ],
  //     ),
  //   );

  //   // Subscribe to events
  //   connector.on('connect', (session) {
  //     debugPrint("connect: $session");

  //     final String address = sessionStatus.accounts[0];
  //     final int chainId = sessionStatus.chainId;

  //     print("Address: $address");
  //     print("Chain Id: $chainId");

  //     setState(() {
  //       connected = true;
  //       walletAddress = address;
  //     });

  //     saveWalletAddress(address);
  //     connector.killSession();
  //   });

  //   connector.on('session_request', (payload) {
  //     debugPrint("session request: $payload");
  //   });

  //   connector.on('disconnect', (session) {
  //     debugPrint("disconnect: $session");
  //   });

  //   // Create a new session
  //   if (!connector.connected) {
  //     sessionStatus = await connector.createSession(
  //       chainId: 80001, //pass the chain id of a network. 137 is Polygon
  //       onDisplayUri: (uri) {
  //         print(uri);
  //         openMetamask(uri); //call the l
  //       },
  //     );
  //   }
  // }

  void signup() async {
    setState(() {
      buttonLoading = true;
    });
    if(privateKeyController.text.isEmpty || walletController.text.isEmpty){
      Fluttertoast.showToast(msg: 'Enter required details.');
      return;
    }
    await SPServices().setPrivateKey(privateKeyController.text);
    final signupStatus = await AuthServices()
        .signup(widget.name, widget.email, widget.password, walletController.text);
    if (!signupStatus) {
      Fluttertoast.showToast(msg: 'Something went wrong.');
      await SPServices().removeData();
      setState(() {
        buttonLoading = false;
      });
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false);
    }
    setState(() {
      buttonLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
          child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Image.asset(
                  'assets/images/metamask_logo.png',
                  width: width / 3,
                ),
                const Text(
                  'Connect to Metamask wallet',
                  style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      const Text(
                        'By connecting wallet, you agree to our ',
                        style: TextStyle(
                          color: secondaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      GestureDetector(
                        child: const Text(
                          'Terms of Service',
                          style: TextStyle(
                              color: primaryTextColor,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {},
                      ),
                      const Text(
                        'and ',
                        style: TextStyle(color: secondaryTextColor),
                        textAlign: TextAlign.center,
                      ),
                      GestureDetector(
                        child: const Text(
                          'Privacy Policy.',
                          style: TextStyle(
                              color: primaryTextColor,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                // !connected
                //     ? MaterialButton(
                //         onPressed: () {
                //           connectToMetamask();
                //         },
                //         color: buttonColor,
                //         child: const Text(
                //           "Connect",
                //           style: TextStyle(
                //               color: primaryTextColor,
                //               fontWeight: FontWeight.bold),
                //         ),
                //       )
                //     : TextButton.icon(
                //         onPressed: () {},
                //         icon: const Icon(
                //           Icons.check,
                //           color: Colors.green,
                //         ),
                //         label: const Text(
                //           'Connected',
                //           style: TextStyle(
                //               color: buttonColor, fontWeight: FontWeight.bold),
                //         )),
                CustomInput(
                    hintText: 'Enter metamask wallet address',
                    controller: walletController,
                    icon: Icons.wallet),
                CustomInput(
                    hintText: 'Enter metamask private key',
                    controller: privateKeyController,
                    icon: Icons.key),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: MaterialButton(
                onPressed: (){signup();},
                color: buttonColor,
                padding: const EdgeInsets.all(16),
                minWidth: width,
                child: buttonLoading
                    ? LoadingAnimationWidget.twoRotatingArc(
                        color: primaryTextColor, size: 17)
                    : const Text(
                        'Sign in',
                        style: TextStyle(
                            color: primaryTextColor,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
