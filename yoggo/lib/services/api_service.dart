import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yoggo/models/webtoon.dart';

class ApiService {
  static Future<List<bookModel>> getTodaysToons() async {
    // 반환타입 지정
    List<bookModel> bookInstances = []; //여러 WebtoonModel로 구성된 리스트 만들기
    final url = Uri.parse(
        'https://yoggo-server.fly.dev/content/all'); //url: 데이터가 있는 부분(api)
    final response = await http.get(url); // http.get이 처리될 때까지 기다리기

    if (response.statusCode == 200) {
      final List<dynamic> books = jsonDecode(response.body);
      for (var book in books) {
        final bkmodel = bookModel.fromJson(book); //json넘겨주기
        bookInstances.add(bkmodel);
      }
      return bookInstances;
    }
    throw Error();
  }
}
