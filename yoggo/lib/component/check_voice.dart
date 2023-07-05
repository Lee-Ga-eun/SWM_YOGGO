import 'package:flutter/material.dart';
import 'package:yoggo/size_config.dart';
import '../component/home_screen.dart';

class checkVoice extends StatefulWidget {
  const checkVoice({super.key});

  @override
  _checkVoiceState createState() => _checkVoiceState();
}

class _checkVoiceState extends State<checkVoice> {
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
        ],
      ),
    ));
  }
}
