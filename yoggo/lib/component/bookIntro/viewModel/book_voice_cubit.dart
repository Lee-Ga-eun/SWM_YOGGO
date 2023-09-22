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

  Future<void> loadBookVoiceData(int? contentId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (contentId == null) {
      return;
    }
    final data = await dataRepository.bookVoiceRepository(contentId);
    // final serializedData =
    //     data.map((item) => json.encode(item.toJson())).toList();
    // _dataMap[contentId] = data; // 가져온 데이터를 Map에 저장합니다.
    print("📚 load voice: $data");
    emit(data);
  }

//voice 클릭 시
  Future<BookVoiceModel?> clickBookVoiceData(
      int contentId, int clickedId) async {
    List<BookVoiceModel> data = state;
    BookVoiceModel? clickedVoice;
    data.forEach((item) {
      if (item.voiceId == clickedId) {
        item.clicked = true;
        clickedVoice = item;
      } else {
        item.clicked = false;
      }
    });
    print("📌 click voice: $data");
    emit(data);
    return clickedVoice;
  }

//my Voice 다시 받아올 때!
  Future<void> changeBookVoiceData(int contentId) async {
    //final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (contentId == null) {
      return;
    }
    final data = await dataRepository.changeBookVoiceRepository(contentId);
    // final serializedData =
    //     data.map((item) => json.encode(item.toJson())).toList();
    // _dataMap[contentId] = data; // 가져온 데이터를 Map에 저장합니다.
    print("🔄 change voice: $data");
    emit(data);
  }
}
