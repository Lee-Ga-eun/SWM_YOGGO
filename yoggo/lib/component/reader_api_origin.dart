// // 원래 reader.dart에 있던 파일 내용들

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:async';
// import 'package:yoggo/size_config.dart';
// import '../main.dart';

// //import 'package:audioplayers/audioplayers.dart';
// import 'package:audioplayers/audioplayers.dart';

// class FairytalePage extends StatefulWidget {
//   final int voiceId; //detail_screen에서 받아오는 것들
//   final bool isSelected; 
//   final int lastPage;
//   const FairytalePage({
//     super.key,
//     required this.voiceId, // detail_screen에서 받아오는 것들 초기화
//     required this.isSelected,
//     required this.lastPage,
//   });

//   @override
//   _FairytalePageState createState() => _FairytalePageState();
// }

// class _FairytalePageState extends State<FairytalePage> {
//   int currentPage = 1;
//   String text = '';
//   String bookImage = '';
//   int? position;
//   int? last;
//   bool isPlaying = true;
//   // current page 와 last page의 숫자가 같으면 체크표시로 아이콘 변경
//   // 체크표시로 변경되면 home screen으로 넘어감

//   AudioPlayer audioPlayer = AudioPlayer();
//   Source audioUrl = UrlSource('');

//   Future<void> fetchPageData() async {
//     final url =
//         'https://yoggo-server.fly.dev/content/page?contentVoiceId=${widget.voiceId}&order=$currentPage';
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       Map<String, dynamic> responseData = jsonDecode(response.body);
//       print(responseData);

//       final contentText = responseData['text'];
//       audioUrl = UrlSource(supabaseAudioUrl + responseData['audioUrl']);
//       last = responseData['last'];
//       bookImage = contentUrl + responseData['imageUrl'];
//       position = responseData['position'];

//       for (int i = 1; i <= 100; i++) {
//         final url =
//             'https://yoggo-server.fly.dev/content/page?contentVoiceId=${widget.voiceId}&order=$i';
//         // print('for문 확인');
//         // print(url);
//         final response = await http.get(Uri.parse(url));
//         if (response.statusCode == 200) {
//           Map<String, dynamic> responseData = jsonDecode(response.body);
//           final imageUrl = contentUrl + responseData['imageUrl'];
//           print(imageUrl);

//           // 텍스트 받기, 이미지 url받기, 오디오 url 받기

//           if (responseData['last'] == i) {
//             print('break from');
//             print(i);
//             break;
//           }
//         }
//       }

//       setState(() {
//         text = contentText;
//         audioUrl = audioUrl;
//         playAudio();
//         isPlaying = true;
//       });
//     } else {}
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchPageData();
//   }

//   void nextPage() {
//     setState(() {
//       isPlaying = false;
//       stopAudio();
//       currentPage++;
//       fetchPageData();
//     });
//   }

//   void previousPage() {
//     if (currentPage > 1) {
//       setState(() {
//         isPlaying = false;
//         stopAudio();
//         currentPage--;
//         fetchPageData();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     // audioPlayer.stop();
//     super.dispose();
//   }

//   // void playAudio() async {
//   //   stopAudio();
//   //   void result = await audioPlayer.play(audioUrl);

//   //   audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
//   //     if (state == PlayerState.stopped) {
//   //       isPlaying = false;
//   //     } else {
//   //       setState(() {
//   //         isPlaying = true;
//   //       });
//   //     }
//   //   });
//   // }
//   void playAudio() async {
//     stopAudio();
//     audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
//       if (state == PlayerState.stopped) {
//         setState(() {
//           isPlaying = false;
//         });
//       }
//     });
//     await audioPlayer.play(audioUrl);
//     setState(() {
//       isPlaying = true;
//     });
//   }

//   void stopAudio() async {
//     await audioPlayer.stop();
//   }

//   void pauseAudio() async {
//     await audioPlayer.pause();
//     setState(() {
//       isPlaying = false;
//     });
//   }

//   void resumeAudio() async {
//     await audioPlayer.resume();
//     setState(() {
//       isPlaying = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     print(isPlaying);
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('lib/images/bkground.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(SizeConfig.defaultSize!),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Expanded(
//                 flex: 1,
//                 child: Container(
//                     //color: Colors.orange,
//                     alignment: Alignment.topLeft,
//                     //color: Colors.red,

//                     //child: Positioned(
//                     //  left: 1.0,
//                     child: IconButton(
//                       onPressed: () {
//                         stopAudio();
//                         Navigator.of(context).pop();
//                       },
//                       icon: Icon(
//                         Icons.cancel,
//                         color: Colors.white,
//                         size: SizeConfig.defaultSize! * 4,
//                       ),
//                     )),
//               ),
//               //),

//               Expanded(
//                 flex: 6,
//                 // 본문 글자
//                 child: Row(
//                   children: [
//                     Expanded(
//                       flex: position == 1 ? 1 : 2,
//                       child: Container(
//                         //color: position == 1 ? Colors.red : Colors.white,
//                         child: position == 1
//                             ? Padding(
//                                 padding: EdgeInsets.only(
//                                     left: SizeConfig.defaultSize! * 2),
//                                 child: ClipRRect(
//                                   borderRadius:
//                                       BorderRadius.circular(20), // 모서리를 원형으로 설정
//                                   child: Image.network(
//                                     bookImage,
//                                     //fit: BoxFit.cover,
//                                     // 이미지를 컨테이너에 맞게 조정
//                                   ),
//                                 ),
//                               ) // // 그림을 1번 화면에 배치
//                             : Padding(
//                                 padding: EdgeInsets.only(
//                                     left: SizeConfig.defaultSize! * 5,
//                                     right: SizeConfig.defaultSize!),
//                                 child: SingleChildScrollView(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         // textAlign: TextAlign.center,
//                                         text,
//                                         style: TextStyle(
//                                             fontSize:
//                                                 SizeConfig.defaultSize! * 2,
//                                             fontFamily: 'BreeSerif'),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ), // 글자를 2번 화면에 배치
//                       ),
//                     ),
//                     Expanded(
//                       flex: position == 0 ? 1 : 2,
//                       child: Container(
//                         //color: position == 2 ? Colors.red : Colors.white,
//                         child: position == 0
//                             ? ClipRRect(
//                                 borderRadius:
//                                     BorderRadius.circular(20), // 모서리를 원형으로 설정
//                                 child: Image.network(
//                                   bookImage,
//                                   // fit: BoxFit.cover, // 이미지를 컨테이너에 맞게 조정
//                                 ),
//                               ) // 그림을 2번 화면에 배치
//                             : Padding(
//                                 padding: EdgeInsets.only(
//                                     right: SizeConfig.defaultSize! * 2,
//                                     left: SizeConfig.defaultSize! * 2),
//                                 child: SingleChildScrollView(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         // textAlign: TextAlign.center,
//                                         text,
//                                         style: TextStyle(
//                                             fontSize:
//                                                 SizeConfig.defaultSize! * 2,
//                                             fontFamily: 'BreeSerif'),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ), // 글자를 1번 화면에 배치
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 flex: 1,
//                 child: Container(
//                   // color: Colors.blue,
//                   child: Row(
//                     // 화살표
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.arrow_back),
//                         onPressed: previousPage,
//                       ),
//                       //const SizedBox (width: 7),
//                       isPlaying
//                           ? IconButton(
//                               icon: const Icon(Icons.pause),
//                               onPressed: pauseAudio)
//                           : IconButton(
//                               icon: const Icon(Icons.play_arrow),
//                               onPressed: resumeAudio),
//                       //const SizedBox(width: 7),*/
//                       currentPage != last
//                           ? IconButton(
//                               icon: const Icon(Icons.arrow_forward),
//                               onPressed: nextPage,
//                             )
//                           : (isPlaying != true
//                               ? IconButton(
//                                   icon: const Icon(Icons.arrow_forward),
//                                   onPressed: () => {},
//                                 )
//                               : IconButton(
//                                   icon: Icon(
//                                     Icons.check,
//                                     color: Colors.green,
//                                     size: SizeConfig.defaultSize! * 4,
//                                   ),
//                                   onPressed: () => {
//                                     stopAudio(),
//                                     Navigator.of(context).pop()
//                                   },
//                                 ))
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
