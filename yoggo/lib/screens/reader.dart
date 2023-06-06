import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FairytalePage extends StatefulWidget {
  final int voiceId;
  const FairytalePage({super.key, required this.voiceId});

  @override
  _FairytalePageState createState() => _FairytalePageState();
}

class _FairytalePageState extends State<FairytalePage> {
  int currentPage = 1;
  String text = '';
  String bookImage = '';
  int? position;
  // current page 와 last page의 숫자가 같으면 체크표시로 아이콘 변경
  // 체크표시로 변경되면 home screen으로 넘어감

  Future<void> fetchPageData() async {
    final url =
        'https://yoggo-server.fly.dev/content/page?contentVoiceId=${widget.voiceId}&order=$currentPage';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      //List<dynamic> responseData = jsonDecode(response.body);
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print(responseData);
      //Map<String, dynamic> data = responseData[0];

      final contentText = responseData['text'];
      print("position의 값");
      print(responseData['position']);

      setState(() {
        text = contentText;
      });
    } else {
      // Handle error case
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPageData();
  }

  void nextPage() {
    setState(() {
      currentPage++;
      fetchPageData();
    });
  }

  void previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        fetchPageData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.orange,
                alignment: Alignment.topLeft,
                //color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Positioned(
                      child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 40,
                    ),
                  )),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              // 본문 글자
              child: Container(
                color: Colors.yellow,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.blue,
                child: Row(
                  // 화살표
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: previousPage,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: nextPage,
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
}
