import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoggo/component/bookIntro/viewModel/book_intro_model.dart';
import '../../../Repositories/Repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../home/viewModel/home_screen_cubit.dart';
import 'book_voice_model.dart';

class BookVoiceCubit extends Cubit<List<BookVoiceModel>> {
  final DataRepository dataRepository;
  static final Map<int, List<BookVoiceModel>> _dataMap = {}; // Map으로 변경

  BookVoiceCubit(this.dataRepository) : super([]);

  void loadBookVoiceData(int? contentId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (contentId == null) {
      return;
    }

    // 여기 수정 필요!! 레포지토리 만들어야 합니당
    final data = await dataRepository.bookVoiceRepository(contentId);
    final serializedData =
        data.map((item) => json.encode(item.toJson())).toList();
    _dataMap[contentId] = data; // 가져온 데이터를 Map에 저장합니다.

    emit(data);
  }
}
