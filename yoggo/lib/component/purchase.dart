import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:yoggo/component/home_screen.dart';
import 'package:yoggo/component/record_info.dart';
import 'package:yoggo/size_config.dart';

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

  Future fetch() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (available) {
      // 제품 정보를 로드
      const Set<String> ids = <String>{'product1'};
      ProductDetailsResponse res =
          await InAppPurchase.instance.queryProductDetails(ids);
      this.view = res.productDetails;

      _inAppPurchase.purchaseStream.listen((List<PurchaseDetails> event) {
        PurchaseDetails e = event[0];
        print(
            "📌 EVENT $e ${e.status} ${e.productID} ${e.pendingCompletePurchase}");

        /// 구매 여부 pendingCompletePurchase - 승인 true / 취소 false
        if (e.pendingCompletePurchase) {
          if (!mounted) return;

          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => RecordInfo()));
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
    Future(this.fetch);
    super.initState();
    // TODO: Add initialization code
  }

  // void purchaseUpdatedListener(List<PurchaseDetails> purchaseDetailsList) {
  //   // 결제 정보 업데이트 시 호출되는 콜백 함수
  //   for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
  //     if (purchaseDetails.status == PurchaseStatus.purchased) {
  //       // 결제 완료
  //       _handlePurchaseSuccess(purchaseDetails);
  //     } else if (purchaseDetails.status == PurchaseStatus.error) {
  //       // 결제 실패
  //       _handlePurchaseError();
  //     }
  //   }
  // }

  // void _handlePurchaseSuccess(PurchaseDetails purchaseDetails) {
  //   // 결제 성공 시 페이지 전환을 처리하는 코드를 추가하세요.
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => RecordInfo(), // 전환할 페이지로 변경해주세요.
  //     ),
  //   );
  // }

  // void _handlePurchaseError() {
  //   // 결제 실패 시 처리하는 코드를 추가하세요.
  //   // 예: 에러 메시지 표시, 다시 시도 유도 등
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Purchase(), // 전환할 페이지로 변경해주세요.
  //     ),
  //   );
  // }

  Future<void> startPurchase() async {
    const Set<String> _products = {'product1'};
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_products);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/bkground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: SizeConfig.defaultSize!,
            ),
            Expanded(
              flex: 1,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'LOVEL',
                        style: TextStyle(
                          fontFamily: 'BreeSerif',
                          fontSize: SizeConfig.defaultSize! * 4,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 20,
                    child: IconButton(
                      icon: const Icon(Icons.cancel),
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
            ),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'A fantastic experience of reading a storybook to your child with your voice\n\n',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    'Stimulate children\'s imaginations and create special moments together\n',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    'Unlimited provision of all fairy tales that are updated at all times!\n\n',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text: 'OPENING SPECIAL\n',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: '70% ',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'OFF + 1 ',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'FREE ',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'MONTH\n',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: '\$5.99/month\n',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: '\$19.99/month\n',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ),
            ),
            TextButton(
              onPressed: () async {
                await startPurchase();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 175, 101, 188),
                minimumSize: const Size(400, 40), // 버튼의 최소 크기를 지정
              ),
              child: const Text(
                "TRY IT FREE",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Expanded(
                child: Text(
                    'We’ll remind you 7 days before your trial ends · Cancel anytime'))
          ],
        ),
      ),
    );
  }
}
