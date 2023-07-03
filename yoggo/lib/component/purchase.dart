import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:yoggo/component/home_screen.dart';
import 'package:yoggo/component/record_info.dart';
import 'package:yoggo/size_config.dart';

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  _PurchaseState createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {
  @override
  void initState() {
    super.initState();
    initInAppPurchases();
    // TODO: Add initialization code
  }

  Future<void> initInAppPurchases() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (available) {
      // 제품 정보를 로드
      const Set<String> _products = <String>{'product1'};

      await InAppPurchase.instance.restorePurchases();
      await InAppPurchase.instance.queryProductDetails(_products);
    }
  }

  void _handlePurchaseSuccess() {
    // 결제 성공 시 페이지 전환을 처리하는 코드를 추가하세요.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordInfo(), // 전환할 페이지로 변경해주세요.
      ),
    );
  }

  void _handlePurchaseError() {
    // 결제 실패 시 처리하는 코드를 추가하세요.
    // 예: 에러 메시지 표시, 다시 시도 유도 등
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Purchase(), // 전환할 페이지로 변경해주세요.
      ),
    );
  }

  Future<void> startPurchase() async {
    const Set<String> _products = <String>{'product1'};
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_products);
    if (response.notFoundIDs.isNotEmpty) {
      // 제품 정보를 찾을 수 없음
      return;
    }

    final ProductDetails productDetails = response.productDetails.first;

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
      applicationUserName: null, // optional
    );

    InAppPurchase.instance
        .buyNonConsumable(
      purchaseParam: purchaseParam,
    )
        .then((bool success) {
      if (success) {
        // 결제 성공 시 처리
        _handlePurchaseSuccess();
      } else {
        _handlePurchaseError();
      }
    }).catchError((error) {
      _handlePurchaseError();
    });
  }

  @override
  void dispose() {
    // TODO: Add cleanup code
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
              onPressed: () {
                startPurchase();
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
