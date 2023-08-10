import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yoggo/component/home/view/home.dart';
import 'package:yoggo/component/sign.dart';
import 'package:yoggo/component/rec_info.dart';
import 'package:yoggo/component/sign_and.dart';
import 'package:yoggo/size_config.dart';
import 'dart:io' show Platform;

import 'globalCubit/user/user_cubit.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  _PurchaseState createState() => _PurchaseState();
}

class AppData {
  static final AppData _appData = AppData._internal();

  bool entitlementIsActive = false;
  String appUserID = '';

  factory AppData() {
    return _appData;
  }
  AppData._internal();
}

class _PurchaseState extends State<Purchase> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> view = [];
  late String token;
  Future fetch() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (available) {
      // 제품 정보를 로드
      const Set<String> ids = <String>{'product1'};
      ProductDetailsResponse res =
          await InAppPurchase.instance.queryProductDetails(ids);
      view = res.productDetails;

      _inAppPurchase.purchaseStream.listen((List<PurchaseDetails> event) {
        PurchaseDetails e = event[0];
        print(
            "📌 EVENT $e - ${e.status} - ${e.productID} - ${e.pendingCompletePurchase}");

        /// 구매 여부 pendingCompletePurchase - 승인 true / 취소 false
        if (e.pendingCompletePurchase) {
          if (!mounted) return;
          _inAppPurchase.completePurchase(e);
          if (e.status == PurchaseStatus.error) return;
          successPurchase();
          UserCubit().fetchUser();
          amplitude.setUserProperties({'subscribe': true});
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const RecInfo()));
        }
      });
    }
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    Future(fetch);
    super.initState();
    getToken();
    // TODO: Add initialization code
  }

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token')!;
    });
  }

  Future<void> successPurchase() async {
    await getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('purchase', true);
    var url = Uri.parse('https://yoggo-server.fly.dev/user/successPurchase');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      print('정보 등록 완료');
    } else {
      throw Exception('Failed to start inference');
    }
  }

  Future<void> startPurchase() async {
    try {
      Offerings? offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        var myProductList = offerings.current!.availablePackages;
        CustomerInfo customerInfo =
            await Purchases.purchasePackage(myProductList[0]);
        EntitlementInfo? entitlement = customerInfo.entitlements.all['pro'];
        final appData = AppData();
        appData.entitlementIsActive = entitlement?.isActive ?? false;
        if (entitlement!.isActive) {
          successPurchase();
        }
        successPurchase();
        // Display packages for sale
      }
    } catch (e) {
      // optional error handling
    }

    // const Set<String> products = {'product1'};
    // final ProductDetailsResponse response =
    //     await InAppPurchase.instance.queryProductDetails(products);
    // if (response.notFoundIDs.isNotEmpty) {
    //   print('제품이 없어요');
    //   return;
    // }

    // final ProductDetails productDetails = response.productDetails.first;

    // final PurchaseParam purchaseParam = PurchaseParam(
    //   productDetails: productDetails,
    // );
    // try {
    //   final bool success = await InAppPurchase.instance.buyNonConsumable(
    //     purchaseParam: purchaseParam,
    //   );
    // } catch (error) {
    //   // 결제 실패
    //   print('결제 실패했어요');
    // }
  }

  @override
  void dispose() {
    // TODO: Add cleanup code
    //_subscription.cancel();
    super.dispose();
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final Amplitude amplitude = Amplitude.getInstance();

  @override
  Widget build(BuildContext context) {
    final userCubit = context.watch<UserCubit>();
    final userState = userCubit.state;
    SizeConfig().init(context);
    _sendSubViewEvent();
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/images/bkground.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Column(children: [
          //Expanded(
          //flex: 7,
          //child:
          SizedBox(height: SizeConfig.defaultSize! * 1),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'LOVEL',
                    style: TextStyle(
                      fontFamily: 'Modak',
                      fontSize: SizeConfig.defaultSize! * 5,
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 2 * SizeConfig.defaultSize!,
                child: IconButton(
                  icon: Icon(Icons.clear, size: 3 * SizeConfig.defaultSize!),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                ),
              ),
              // ios 앱 심사를 위한 restore 버튼
              Positioned(
                right: 3 * SizeConfig.defaultSize!,
                child: GestureDetector(
                    onTap: () async {
                      try {
                        if (userState.login == false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Platform.isIOS
                                    ? const Login()
                                    : const LoginAnd()), //HomeScreen()),
                          );
                        } else {
                          CustomerInfo customerInfo =
                              await Purchases.restorePurchases();
                          EntitlementInfo? entitlement =
                              customerInfo.entitlements.all['pro'];
                          if (entitlement != null) {
                            if (entitlement.isActive) {
                              successPurchase();
                            }
                          }
                        }

                        // ... check restored purchaserInfo to see if entitlement is now active
                      } on PlatformException {
                        // Error restoring purchases
                      }
                    },
                    child: Container(
                      width: 15 * SizeConfig.defaultSize!,
                      height: 3 * SizeConfig.defaultSize!,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(128, 255, 255, 255),
                          borderRadius: BorderRadius.all(
                              Radius.circular(SizeConfig.defaultSize! * 1))),
                      child: Center(
                          child: Text(
                        'Already Purchase?',
                        style: TextStyle(
                            fontFamily: 'Molengo',
                            fontSize: SizeConfig.defaultSize! * 1.5),
                      )),
                    )),
              ),
              // ios 앱 심사를 위한 restore 버튼
            ],
          ),
          SizedBox(height: SizeConfig.defaultSize! * 0.5),
          //),
          Container(
            //width: 72 * SizeConfig.defaultSize!,
            //height: 29.4 * SizeConfig.defaultSize!,
            //decoration: BoxDecoration(
            //color: const Color.fromARGB(128, 255, 255, 255),
            //borderRadius: BorderRadius.all(
            //Radius.circular(SizeConfig.defaultSize! * 3))),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Just hearing your voice activates children's brains.\nRead all upcoming books to your child with your own voice.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Molengo',
                          fontSize: SizeConfig.defaultSize! * 2.2),
                    ),
                    SizedBox(
                      height: SizeConfig.defaultSize! * 2.5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/images/rocket.png',
                          width: SizeConfig.defaultSize! * 5,
                          alignment: Alignment.topCenter,
                        ),
                        SizedBox(
                          width: SizeConfig.defaultSize! * 10,
                        ),
                        RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                text: '\$19.99/month\n',
                                style: TextStyle(
                                    fontSize: SizeConfig.defaultSize! * 1.8,
                                    fontFamily: 'Molengo',
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough),
                              ),
                              TextSpan(
                                text: '\$5.99/month',
                                style: TextStyle(
                                    fontSize: SizeConfig.defaultSize! * 2,
                                    color: Colors.black,
                                    fontFamily: 'Molengo'),
                              ),
                            ])),
                        SizedBox(
                          width: SizeConfig.defaultSize! * 10,
                        ),
                        Image.asset(
                          'lib/images/horse.png',
                          width: SizeConfig.defaultSize! * 5,
                          alignment: Alignment.topCenter,
                        )
                      ],
                    ),
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          TextSpan(
                            text: '70% ',
                            style: TextStyle(
                                height: 0,
                                fontSize: SizeConfig.defaultSize! * 2.3,
                                color: Colors.red,
                                fontFamily: 'Molengo'),
                          ),
                          TextSpan(
                            text: 'OFF + 1 ',
                            style: TextStyle(
                                height: 0,
                                fontSize: SizeConfig.defaultSize! * 2.3,
                                color: Colors.black,
                                fontFamily: 'Molengo'),
                          ),
                          TextSpan(
                            text: 'FREE ',
                            style: TextStyle(
                                height: 0,
                                fontSize: SizeConfig.defaultSize! * 2.3,
                                color: Colors.red,
                                fontFamily: 'Molengo'),
                          ),
                          TextSpan(
                            text: 'WEEK',
                            style: TextStyle(
                                height: 0,
                                fontSize: SizeConfig.defaultSize! * 2.3,
                                color: Colors.black,
                                fontFamily: 'Molengo'),
                          ),
                        ])),
                    SizedBox(
                      height: 0.2 * SizeConfig.defaultSize!,
                    ),
                    GestureDetector(
                        // -------------------------------------------------------------
                        onTap: () async {
                          _sendSubPayClickEvent();
                          userState.login
                              ? await startPurchase()
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Platform.isIOS
                                          ? const Login()
                                          : const LoginAnd()), //HomeScreen()),
                                );
                          //await startPurchase();
                        },
                        child: Stack(children: [
                          SizedBox(
                            width: 52 * SizeConfig.defaultSize!,
                            height: 8 * SizeConfig.defaultSize!,
                          ),
                          Positioned(
                              //left: 39 * SizeConfig.defaultSize!,
                              bottom: 1 * SizeConfig.defaultSize!,
                              child: Container(
                                  width: 52 * SizeConfig.defaultSize!,
                                  height: 4.5 * SizeConfig.defaultSize!,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFFFA91A),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              SizeConfig.defaultSize! * 1.5))),
                                  child: Center(
                                      child: Text(
                                    "CONTINUE with FREE Trial",
                                    style: TextStyle(
                                      fontFamily: 'Molengo',
                                      fontSize: SizeConfig.defaultSize! * 2.2,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  )))),
                          Positioned(
                            left: 39 * SizeConfig.defaultSize!,
                            bottom: 4.7 * SizeConfig.defaultSize!,
                            child: Container(
                                width: 12 * SizeConfig.defaultSize!,
                                height: 3 * SizeConfig.defaultSize!,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF1787FF),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            SizeConfig.defaultSize! * 1))),
                                child: Center(
                                    child: Text(
                                  "Try it FREE",
                                  style: TextStyle(
                                    fontFamily: 'Molengo',
                                    fontSize: SizeConfig.defaultSize! * 1.6,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ))),
                          ),
                          // Positioned(
                          //   bottom: 0 * SizeConfig.defaultSize!,
                          //   left: 10 * SizeConfig.defaultSize!,
                          //   child: Text(
                          //     "You can cancel this subscription at any time if you wish.",
                          //     style: TextStyle(
                          //       fontFamily: 'Molengo',
                          //       decoration: TextDecoration.underline,
                          //       fontSize: SizeConfig.defaultSize! * 1.5,
                          //       color: Colors.black,
                          //     ),
                          //     textAlign: TextAlign.center,
                          //   ),
                          //),
                        ])),
                    SizedBox(
                        width: 61 * SizeConfig.defaultSize!,
                        child: Column(children: [
                          Center(
                              child: Text(
                                  "Subscription Terms: After free trial, LOVEL monthly subscription is \$5.99, automatically renews unless turned off in Account Settings at least 24h before current period ends. Payment is charged ",
                                  style: TextStyle(
                                      fontSize: 1.5 * SizeConfig.defaultSize!,
                                      fontFamily: 'Molengo'))),
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                style: TextStyle(
                                    fontSize: 1.5 * SizeConfig.defaultSize!,
                                    fontFamily: 'Molengo',
                                    color: Colors.black),
                                text:
                                    "to your iTunes account. By tapping Continue, you agree to our "),
                            TextSpan(
                                text: "Terms",
                                style: TextStyle(
                                  fontSize: 1.5 * SizeConfig.defaultSize!,
                                  fontFamily: 'Molengo',
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launch(
                                        'http://www.apple.com/legal/itunes/appstore/dev/stdeula');
                                  }),
                            TextSpan(
                              text: " and ",
                              style: TextStyle(
                                  fontSize: 1.5 * SizeConfig.defaultSize!,
                                  fontFamily: 'Molengo',
                                  color: Colors.black),
                            ),
                            TextSpan(
                                text: "Privacy Policy.",
                                style: TextStyle(
                                  fontSize: 1.5 * SizeConfig.defaultSize!,
                                  fontFamily: 'Molengo',
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launch(
                                        'https://doc-hosting.flycricket.io/lovel-privacy-policy/f8c6f57c-dd5f-4b67-8859-bc4afe251396/privacy');
                                  })
                          ]))
                        ]))
                  ],
                )),
          ) //),
        ]),
      ),
    ));
  }

  Future<void> _sendSubViewEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'sub_view',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent('sub_view', eventProperties: {});
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendSubPayClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'sub_pay_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'sub_pay_click',
        eventProperties: {},
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }
}
