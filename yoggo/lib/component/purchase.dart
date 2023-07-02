import 'package:flutter/material.dart';
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
    // TODO: Add initialization code
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
              flex: 2,
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
                Navigator.push(
                  context,
                  //결제가 끝나면 RecordInfo로 가야 함
                  MaterialPageRoute(
                    builder: (context) => const RecordInfo(),
                  ),
                );
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
