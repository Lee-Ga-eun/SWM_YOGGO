import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yoggo/models/webtoon.dart';

class ApiService {
  static const String baseUrl =
      //    'http://webtoon-crawler.nomadcoders.workers.dev/';
      'https://yoggo-server.fly.dev/';
  static const String today = 'content';
  //'today';

  static Future<List<bookModel>> getTodaysToons() async {
    // 반환타입 지정
    List<bookModel> bookInstances = []; //여러 WebtoonModel로 구성된 리스트 만들기
    final url = Uri.parse('$baseUrl$today'); //url: 데이터가 있는 부분(api)
    //Future<Response> get(Uri url, {Map<String, String>? headers})
    final response = await http.get(url); // http.get이 처리될 때까지 기다리기

    if (response.statusCode == 200) {
      print('부르는 덴 성공함');
      print("확인");
      print(response.body.runtimeType);

      //print(response.body);
      //string형식임: json으로 반환 필요
      // dynamic: 어떤 타입이든 수용 가능
      final List<dynamic> books = jsonDecode(response.body);
      print(books[0]);
      for (var book in books[0]) {
        // webtoon을 넘겨줘서 webtoonModel을 만들자
        final bkmodel = bookModel.fromJson(book); //json넘겨주기
        print(bkmodel.title); //WebtoonModel 타입
        bookInstances.add(bkmodel);
        //print(webtoon);
        //{id: 602916, title: 칼부림, thumb: https://image-comic.pstatic.net/webtoon/602916/thumbnail/thumbnail_IMAG21_43cf1d1e-d265-464d-83db-f92dbc3fcf43.jpg}
      }

      return bookInstances;
    }
    throw Error();
  }
}
