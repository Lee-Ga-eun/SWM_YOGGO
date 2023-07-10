import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/size_config.dart';
import './record_info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import './waiting_voice.dart';
import 'package:http_parser/http_parser.dart';

class AudioRecorder extends StatefulWidget {
  final void Function(String path)? onStop;

  const AudioRecorder({Key? key, this.onStop}) : super(key: key);

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  late String token;
  bool stopped = false;
  String path_copy = '';
  int _recordDuration = 0;
  Timer? _timer;
  final _audioRecorder = Record();
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  //StreamSubscription<Amplitude>? _amplitudeSub;
  //Amplitude? _amplitude;
  AudioPlayer audioPlayer = AudioPlayer();

  static const platformChannel = MethodChannel('com.sayit.yoggo/channel');

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token')!;
    });
  }

  // void sendPathToKotlin(path) async {
  //   try {
  //     await platformChannel.invokeMethod('setPath', {'path': path});
  //   } catch (e) {
  //     print('Error sending path to Kotlin: $e');
  //   }
  // }

  // Future<void> stopRecording() async {
  //   try {
  //     await platformChannel.invokeMethod('stopRecording');
  //     print('Recording stopped.'); // 녹음이 정상적으로 중지되었음을 출력합니다.
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  @override
  void initState() {
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      setState(() => _recordState = recordState);
    });

    // _amplitudeSub = _audioRecorder
    //     .onAmplitudeChanged(const Duration(milliseconds: 300))
    //     .listen((amp) => setState(() => _amplitude = amp));

    getToken();
    super.initState();
  }

  Future<int> getId() async {
    var url = Uri.parse('https://yoggo-server.fly.dev/user/id');
    var response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var responseData = json.decode(response.body);
    var id = responseData[0];
    return id;
  }

  Future<void> sendRecord(audioUrl, recordName) async {
    var url = Uri.parse('https://yoggo-server.fly.dev/producer/record');

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath('recordUrl', audioUrl,
          contentType: MediaType('audio', 'x-wav')),
    );
    request.fields['recordName'] = recordName;
    var response = await request.send();
    if (response.statusCode == 200) {
      print('Record sent successfully');
    } else {
      print('Failed to send record. Status code: ${response.statusCode}');
    }
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        var myAppDir = await getAppDirectory();
        var id = await getId();
        var playerExtension = Platform.isAndroid ? '$id.wav' : '$id.flac';
        await _audioRecorder.start(
          path: '$myAppDir/$playerExtension',
          encoder: Platform.isAndroid
              ? AudioEncoder.wav
              : AudioEncoder.flac, // by default
        );

        if (Platform.isAndroid) ('$myAppDir/$playerExtension');
        _recordState = RecordState.record;
        _recordDuration = 0;

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  Future<String> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> _stop() async {
    setState(() {
      stopped = true;
    });
    _timer?.cancel();
    _recordDuration = 0;
    //  if (Platform.isAndroid) stopRecording();
    final path = await _audioRecorder.stop();
    //  sendPathToKotlin(path);
    if (path != null) {
      widget.onStop?.call(path);
      path_copy = path.split('/').last;
      sendRecord(path, path_copy);
    }
  }

  Future<void> _pause() async {
    playAudio();
    _timer?.cancel();
    await _audioRecorder.pause();
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();
  }

  void playAudio() async {
    await audioPlayer.play(DeviceFileSource(path_copy));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Container(
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
                                fontFamily: 'Modak',
                                fontSize: SizeConfig.defaultSize! * 5,
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
                                  builder: (context) => const RecordInfo(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
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
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    'voice is gone, but she still recognizes its immeasurable beauty and\n',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    'preciousness. She expresses it in the following way:\n ',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    '"Voice is an ineffable beauty. It is the purest and most precious gift.\n',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    'Though I have lost this cherished gift, I will embark on a journey to find\n',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    'true love through other means. Even without my voice, the emotions\n',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    'and passions within me will not easily fade away. Love transcends\n',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    'language. In this quest to reclaim my precious voice, I will discover my\n',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    'true self and learn the ways of love and freedom."',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _buildRecordStopControl(),
                          const SizedBox(width: 20),
                          // _buildPauseResumeControl(),
                          // const SizedBox(width: 20),
                          _buildText(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Visibility(
                visible: stopped,
                child: AlertDialog(
                  title: const Text('Record Complete'),
                  content: const Text('Your recording has been completed.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // 1초 후에 다음 페이지로 이동
                        Future.delayed(const Duration(seconds: 3), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const WaitingVoicePage()),
                          );
                        });
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    // _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    if (_recordState != RecordState.stop) {
      icon = const Icon(Icons.stop, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      //   _stopRecording();
      final theme = Theme.of(context);
      icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            (_recordState != RecordState.stop) ? _stop() : _start();
          },
        ),
      ),
    );
  }

  // Widget _buildPauseResumeControl() {
  //   if (_recordState == RecordState.stop) {
  //     return const SizedBox.shrink();
  //   }

  //   late Icon icon;
  //   late Color color;

  //   if (_recordState == RecordState.record) {
  //     icon = const Icon(Icons.pause, color: Colors.red, size: 30);
  //     color = Colors.red.withOpacity(0.1);
  //   } else {
  //     _stopRecording();
  //     // final theme = Theme.of(context);
  //     // icon = const Icon(Icons.play_arrow, color: Colors.red, size: 30);
  //     // color = theme.primaryColor.withOpacity(0.1);
  //   }

  //   return ClipOval(
  //     child: Material(
  //       color: color,
  //       child: InkWell(
  //         child: SizedBox(width: 56, height: 56, child: icon),
  //         onTap: () {
  //           (_recordState == RecordState.pause) ? _resume() : _pause();
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildText() {
    if (_recordState != RecordState.stop) {
      return _buildTimer();
    }

    return const Text("Waiting to record");
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.red),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}
