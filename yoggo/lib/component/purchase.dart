import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/component/home/view/home_screen.dart';
import 'package:yoggo/component/login_screen.dart';
import 'package:yoggo/component/record_info.dart';
import 'package:yoggo/size_config.dart';

import 'globalCubit/user/user_cubit.dart';

// final bool _kAutoConsume = Platform.isIOS || true;

// const String _kConsumableId = 'consumable';
// const String _kUpgradeId = 'upgrade';
// const String _kSilverSubscriptionId = 'subscription_silver';
// const String _kGoldSubscriptionId = 'subscription_gold';
// const List<String> _kProductIds = <String>[
//   _kConsumableId,
//   _kUpgradeId,
//   _kSilverSubscriptionId,
//   _kGoldSubscriptionId,
// ];

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  _PurchaseState createState() => _PurchaseState();
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
            "📌 EVENT $e ${e.status} ${e.productID} ${e.pendingCompletePurchase}");

        /// 구매 여부 pendingCompletePurchase - 승인 true / 취소 false
        if (e.pendingCompletePurchase) {
          if (!mounted) return;
          successPurchase();
          UserCubit().fetchUser();
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RecordInfo()));
        }
      });
    }
    if (!mounted) return;
    setState(() {});
  }
  //   final bool isAvailable = await _inAppPurchase.isAvailable();
  //   if (!isAvailable) {
  //     setState(() {
  //       _isAvailable = isAvailable;
  //       _products = <ProductDetails>[];
  //       _purchases = <PurchaseDetails>[];
  //       _notFoundIds = <String>[];
  //       _consumables = <String>[];
  //       _purchasePending = false;
  //       _loading = false;
  //     });
  //     return;
  //   }
  //   if (Platform.isIOS) {
  //     // final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
  //     //     _inAppPurchase
  //     //         .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
  //     // await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
  //   }
  //   final ProductDetailsResponse productDetailResponse =
  //       await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
  //   if (productDetailResponse.error != null) {
  //     setState(() {
  //       _queryProductError = productDetailResponse.error!.message;
  //       _isAvailable = isAvailable;
  //       _products = productDetailResponse.productDetails;
  //       _purchases = <PurchaseDetails>[];
  //       _notFoundIds = productDetailResponse.notFoundIDs;
  //       _consumables = <String>[];
  //       _purchasePending = false;
  //       _loading = false;
  //     });
  //     return;
  //   }

  // if (productDetailResponse.productDetails.isEmpty) {
  //   setState(() {
  //     _queryProductError = null;
  //     _isAvailable = isAvailable;
  //     _products = productDetailResponse.productDetails;
  //     _purchases = <PurchaseDetails>[];
  //     _notFoundIds = productDetailResponse.notFoundIDs;
  //     _consumables = <String>[];
  //     _purchasePending = false;
  //     _loading = false;
  //   });
  //   return;
  // }
  //}
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
    const Set<String> products = {'product1'};
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(products);
    if (response.notFoundIDs.isNotEmpty) {
      print('제품이 없어요');
      return;
    }

    final ProductDetails productDetails = response.productDetails.first;

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );
    try {
      final bool success = await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
    } catch (error) {
      // 결제 실패
      print('결제 실패했어요');
    }
  }

  @override
  void dispose() {
    // TODO: Add cleanup code
    //_subscription.cancel();
    super.dispose();
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    final userCubit = context.watch<UserCubit>();
    final userState = userCubit.state;
    SizeConfig().init(context);
    _sendSubViewEvent(userState.purchase, userState.record);
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
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  //color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.defaultSize! * 0.5),
          //),
          Container(
            width: 72 * SizeConfig.defaultSize!,
            height: 29.4 * SizeConfig.defaultSize!,
            decoration: BoxDecoration(
                color: Color.fromARGB(128, 255, 255, 255),
                borderRadius: BorderRadius.all(
                    Radius.circular(SizeConfig.defaultSize! * 3))),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/images/rocket.png',
                          width: SizeConfig.defaultSize! * 5,
                          alignment: Alignment.topCenter,
                        ),
                        SizedBox(
                          width: SizeConfig.defaultSize! * 5,
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
                          width: SizeConfig.defaultSize! * 5,
                        ),
                        Image.asset(
                          'lib/images/horse.png',
                          width: SizeConfig.defaultSize! * 5,
                          alignment: Alignment.topCenter,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 1.5 * SizeConfig.defaultSize!,
                    ),
                    GestureDetector(
                      onTap: () async {
                        _sendSubPayClickEvent(
                            userState.purchase, userState.record);
                        userState.login
                            ? await startPurchase()
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginScreen()), //HomeScreen()),
                              );
                        //await startPurchase();
                      },
                      child: Container(
                          width: 52 * SizeConfig.defaultSize!,
                          height: 4.5 * SizeConfig.defaultSize!,
                          decoration: BoxDecoration(
                              color: Color(0xFFFFA91A),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  SizeConfig.defaultSize! * 1.5))),
                          child: Center(
                              child: Text(
                            "Let's Invest in Recording UNDER ONE minute",
                            style: TextStyle(
                              fontFamily: 'Molengo',
                              fontSize: SizeConfig.defaultSize! * 2.2,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ))),
                    ),
                    SizedBox(
                      height: SizeConfig.defaultSize! * 0.7,
                    ),
                    // Padding(
                    //     padding: const EdgeInsets.only(),
                    //     child: Container(
                    //       width: SizeConfig.defaultSize! * 52.6,
                    //       height: SizeConfig.defaultSize! * 4.5,
                    //       decoration: BoxDecoration(
                    //         color: const Color.fromARGB(152, 97, 1, 152),
                    //         borderRadius: BorderRadius.all(
                    //             Radius.circular(SizeConfig.defaultSize!)),
                    //       ),
                    //       child: Padding(
                    //         padding: EdgeInsets.only(
                    //           left: SizeConfig.defaultSize! * 5,
                    //           right: SizeConfig.defaultSize! * 5,
                    //           // top: SizeConfig.defaultSize! * 0.2,
                    //           // bottom: SizeConfig.defaultSize! * 0.2,
                    //         ),
                    //         child: TextButton(
                    //           onPressed: () async {
                    //             _sendSubPayClickEvent(
                    //                 userState.purchase, userState.record);
                    //             await startPurchase();
                    //           },
                    //           child: Text(),
                    //         ),
                    //       ),
                    //)
                  ],
                )),
          ) //),
        ]),
      ),
    ));
  }

  Future<void> _sendSubViewEvent(purchase, record) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'sub_view',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendSubPayClickEvent(purchase, record) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'sub_pay_click',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }
}
