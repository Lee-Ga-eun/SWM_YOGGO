import 'dart:async';
import 'package:yoggo/size_config.dart';
import './record_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../main.dart';
import 'dart:io';
import 'package:storage_client/storage_client.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioRecorder extends StatefulWidget {
  final void Function(String path)? onStop;

  const AudioRecorder({Key? key, this.onStop}) : super(key: key);

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  String path_copy = '';
  int _recordDuration = 0;
  Timer? _timer;
  final _audioRecorder = Record();
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;
  String supabasePath = '';
  AudioPlayer audioPlayer = AudioPlayer();

  static const platformChannel = MethodChannel('com.sayit.yoggo/channel');

  void sendPathToKotlin(path) async {
    try {
      await platformChannel.invokeMethod('setPath', {'path': path});
    } catch (e) {
      print('Error sending path to Kotlin: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      await platformChannel.invokeMethod('stopRecording');
      print('Recording stopped.'); // 녹음이 정상적으로 중지되었음을 출력합니다.
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      setState(() => _recordState = recordState);
    });

    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) => setState(() => _amplitude = amp));

    super.initState();
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // We don't do anything with this but printing
        final isSupported =
            await _audioRecorder.isEncoderSupported(AudioEncoder.aacLc);
        if (kDebugMode) {
          print('${AudioEncoder.aacLc.name} supported: $isSupported');
        }
        // final devs = await _audioRecorder.listInputDevices();
        // final isRecording = await _audioRecorder.isRecording();
        var myAppDir = await getAppDirectory();
        var playerExtension =
            Platform.isAndroid ? 'android_1.wav' : 'ios_1.flac';
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
      if (kDebugMode) {
        //print(e);
      }
      // print('에러');
    }
  }

  Future<String> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    print("getApplicationDocumentDirectory");
    print(directory.path);
    return directory.path;
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _recordDuration = 0;
    print("종료함수 호출됨");
    if (Platform.isAndroid) stopRecording();
    final path = await _audioRecorder.stop();
    //  sendPathToKotlin(path);

    print(path);
    if (path != null) {
      File fileCheck = Platform.isAndroid
          ? File(path.replaceFirst('file://', ''))
          : File(path.replaceFirst('file:///', ''));
      if (fileCheck.existsSync()) {
        print('File exists');
      } else {
        print('File does not exist');
      }
    }
    // await _audioRecorder
    //     .setAudioSource(MediaRecorder.AudioSource.MIC); // 마이크 오디오 소스 설정
    // await _audioRecorder.setAudioEncoder(AudioEncoder.aacLc); // AAC LC 코덱 설정
    if (path != null) {
      widget.onStop?.call(path);
      path_copy = path.split('/').last;
      await supabase.storage.from('yoggo-storage').upload(
            'record/$path_copy',
            //File(path),
            File(Platform.isIOS ? path.replaceFirst('file://', '') : path),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
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
    // playAudio(
    //     '/Users/lucy/Library/Developer/CoreSimulator/Devices/777C9185-3249-4F70-B639-1F94CA8542B6/data/Containers/Data/Application/D680BA0A-DE2E-49A2-A99C-A89F36566717/tmp/71C617B0-6CFA-491B-A18F-5F5B0F19B341.m4a');
    return MaterialApp(
        home: Scaffold(
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
                        'YOGGO',
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
                          // 설득 & 광고 페이지로 가야하는데 일단은 홈으로 빠지게 하겠음
                          MaterialPageRoute(
                            builder: (context) => const RecordInfo(),
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
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'As she emerges from the sea onto the shore, she realizes that her \n',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                          TextSpan(
                            text:
                                'voice is gone, but she still recognizes its immeasurable beauty and\n',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                          TextSpan(
                            text:
                                'preciousness. She expresses it in the following way:\n ',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                          TextSpan(
                            text:
                                '"Voice is an ineffable beauty. It is the purest and most precious gift.\n',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                          TextSpan(
                            text:
                                'Though I have lost this cherished gift, I will embark on a journey to find\n',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                          TextSpan(
                            text:
                                'true love through other means. Even without my voice, the emotions\n',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                          TextSpan(
                            text:
                                'and passions within me will not easily fade away. Love transcends\n',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                          TextSpan(
                            text:
                                'language. In this quest to reclaim my precious voice, I will discover my\n',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                          TextSpan(
                            text:
                                'true self and learn the ways of love and freedom."',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildRecordStopControl(),
                    const SizedBox(width: 20),
                    _buildPauseResumeControl(),
                    // const SizedBox(width: 20),
                    // _buildText(),
                  ],
                ),
                if (_amplitude != null) ...[
                  // const SizedBox(height: 40),
                  Text('Current: ${_amplitude?.current ?? 0.0}'),
                  Text('Max: ${_amplitude?.max ?? 0.0}'),
                ],
              ],
            ),
          ],
        ),
      ),
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
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

  Widget _buildPauseResumeControl() {
    if (_recordState == RecordState.stop) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;

    if (_recordState == RecordState.record) {
      icon = const Icon(Icons.pause, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = const Icon(Icons.play_arrow, color: Colors.red, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            (_recordState == RecordState.pause) ? _resume() : _pause();
          },
        ),
      ),
    );
  }

  // Widget _buildText() {
  //   if (_recordState != RecordState.stop) {
  //     return _buildTimer();
  //   }

  //   return const Text("Waiting to record");
  // }

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

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   bool showPlayer = false;
//   String? audioPath;

//   @override
//   void initState() {
//     showPlayer = false;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: showPlayer
//               ? Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 25),
//                   child: AudioPlayer(
//                     source: audioPath!,
//                     onDelete: () {
//                       setState(() => showPlayer = false);
//                     },
//                   ),
//                 )
//               : AudioRecorder(
//                   onStop: (path) {
//                     if (kDebugMode) print('Recorded file path: $path');
//                     setState(() {
//                       audioPath = path;
//                       showPlayer = true;
//                     });
//                   },
//                 ),
//         ),
//       ),
//     );
//   }
// }
