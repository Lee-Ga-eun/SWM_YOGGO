import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FairytalePage extends StatefulWidget {
  const FairytalePage({super.key});

  @override
  _FairytalePageState createState() => _FairytalePageState();
}

class _FairytalePageState extends State<FairytalePage> {
  int currentPage = 1;
  String text = '';

  Future<void> fetchPageData() async {
    final url =
        'https://yoggo-server.fly.dev/content/page?contentVoiceId=1&order=$currentPage';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);
      print(responseData);
      Map<String, dynamic> data = responseData[0];

      final contentText = data['text'];

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
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
          ],
        ),
      ),
    );
  }
}
