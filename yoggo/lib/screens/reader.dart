import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../main.dart';

//import 'package:audioplayers/audioplayers.dart';

class FairytalePage extends StatefulWidget {
  final int voiceId; //detail_screen에서 받아오는 것들
  final bool isSelected;
  final int lastPage;
  const FairytalePage({
    super.key,
    required this.voiceId, // detail_screen에서 받아오는 것들 초기화
    required this.isSelected,
    required this.lastPage,
  });

  @override
  _FairyTalePageState createState() => _FairyTalePageState();
}

class _FairyTalePageState extends State<FairytalePage> {
  // List<BookPage> pages = []; // 책 페이지 데이터 리스트
  List<Map<String, dynamic>> pages = [];

  int currentPageIndex = 0; // 현재 페이지 인덱스

  @override
  void initState() {
    super.initState();
    // 책 페이지 데이터 미리 불러오기
    fetchAllBookPages();
  }

  Future<void> fetchAllBookPages() async {
    // API에서 모든 책 페이지 데이터를 불러와 pages 리스트에 저장
    final response = await http.get(Uri.parse(
        'https://yoggo-server.fly.dev/content/page?contentVoiceId=${widget.voiceId}'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData is List<dynamic>) {
        setState(() {
          pages = List<Map<String, dynamic>>.from(jsonData);
          // print(pages);
        });
      }
    } else {
      // 에러 처리
    }
  }

  void nextPage() {
    setState(() {
      if (currentPageIndex < widget.lastPage) {
        currentPageIndex++;
        if (currentPageIndex == widget.lastPage) {
          currentPageIndex -= 1;
        }
      }
    });
  }

  void previousPage() {
    setState(() {
      if (currentPageIndex > 0) {
        currentPageIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(currentPageIndex);
    print(widget.lastPage);
    if (pages.isEmpty) {
      // 데이터가 아직 불러와지지 않았을 경우 로딩 화면 등을 표시
      return const CircularProgressIndicator();
    }
    return Scaffold(
      body: Stack(
        children: [
          // 현재 페이지 위젯
          Visibility(
            visible: true,
            child: PageWidget(
                page: currentPageIndex < widget.lastPage
                    ? pages[currentPageIndex]
                    : pages[widget.lastPage - 1]),
          ),
          // 다음 페이지 위젯
          Visibility(
            visible: false,
            child: //PageWidget(page: pages[currentPageIndex + 1]),
                PageWidget(
                    page: currentPageIndex < widget.lastPage
                        ? currentPageIndex == widget.lastPage - 1
                            ? pages[currentPageIndex]
                            : pages[currentPageIndex + 1]
                        : pages[widget.lastPage - 1]),
          ),
          // 이전 페이지 위젯
          Visibility(
            visible: false,
            child: PageWidget(
                page: currentPageIndex != 0
                    ? pages[currentPageIndex - 1]
                    : pages[0]),
            // page: currentPageIndex > 0
            //     ? pages[currentPageIndex - 1]
            //     : pages[0]),
          ),
          // 오른쪽 화살표 버튼
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: nextPage,
            ),
          ),
          // 왼쪽 화살표 버튼
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: previousPage,
            ),
          ),
        ],
      ),
    );
  }
}

class PageWidget extends StatefulWidget {
  final Map<String, dynamic> page;

  const PageWidget({Key? key, required this.page}) : super(key: key);

  @override
  _PageWidgetState createState() => _PageWidgetState();
}

class _PageWidgetState extends State<PageWidget> {
  @override
  Widget build(BuildContext context) {
    //   final pageNum = widget.page['pageNum'] as int;
    final text = widget.page['text'] as String;
    final imageUrl = contentUrl + widget.page['imageUrl'];
    print(widget.page);
    return Container(
      child: Column(
        children: [
          Image.network(
            imageUrl,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
