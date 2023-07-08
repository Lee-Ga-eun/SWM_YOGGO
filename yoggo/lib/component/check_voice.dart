import 'package:flutter/material.dart';
import 'package:yoggo/size_config.dart';
import '../component/home_screen.dart';
import './record_page2.dart';
import 'package:audioplayers/audioplayers.dart';

class CheckVoice extends StatefulWidget {
  // final String completeInferenced;

  const CheckVoice({
    super.key,
    //required this.completeInferenced,
  });

  @override
  _CheckVoiceState createState() => _CheckVoiceState();
}

class _CheckVoiceState extends State<CheckVoice> {
  AudioPlayer audioPlayer = AudioPlayer();

  void playAudio(String audioUrl) async {
    await audioPlayer.play(UrlSource(audioUrl));
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
          const Expanded(
            flex: 1,
            child: Text(
              'Complete! Here is your voice!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 194, 120, 209),
                fontFamily: 'BreeSerif',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'As she emerges from the sea onto the shore, she realizes that her \n',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'voice is gone, but she still recognizes its immeasurable beauty and\n',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'preciousness. She expresses it in the following way:\n ',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              '"Voice is an ineffable beauty. It is the purest and most precious gift.\n',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'Though I have lost this cherished gift, I will embark on a journey to find\n',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'true love through other means. Even without my voice, the emotions\n',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'and passions within me will not easily fade away. Love transcends\n',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'language. In this quest to reclaim my precious voice, I will discover my\n',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'true self and learn the ways of love and freedom."',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AudioRecorder(
                                // rerecord: true,
                                // mustDelete: widget.path,
                                ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8.0), // 원하는 모양의 네모 박스로 변경
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 194, 120, 209),
                      ),
                      child: const Text(
                        ' Record Again ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        size: 30,
                        color: Color.fromARGB(255, 194, 120, 209),
                      ),
                      onPressed: () {
                        playAudio('data');
                      },
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8.0), // 원하는 모양의 네모 박스로 변경
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 194, 120, 209),
                      ),
                      child: const Text(
                        '    I love it!    ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }
}
