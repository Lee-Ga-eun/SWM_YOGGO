import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoggo/component/bookIntro/viewModel/book_intro_model.dart';
import '../../../repositories/Repository.dart';

class BookIntroCubit extends Cubit<List<BookIntroModel>> {
  final DataRepository repository = DataRepository();
  static final Map<int, List<BookIntroModel>> _dataMap = {}; // Map으로 변경

  BookIntroCubit() : super([]);

  void loadBookIntroData(int? contentId) async {
    if (contentId == null) {
      return;
    }
    // if (_dataMap.containsKey(contentId)) {
    if (_dataMap[contentId] != null) {
      // 이미 데이터가 로드되어 있다면, 저장된 데이터를 사용하여 emit합니다.
      emit(_dataMap[contentId]!);
      return;
    }

    // 현재 contentId에 대한 데이터가 없으면, 다른 contentId로 저장된 데이터가 있는지 확인합니다.

    // 캐시된 데이터가 하나도 없으면, 레포지토리에서 데이터를 가져옵니다.
    final data = await DataRepository.bookIntroRepository(contentId);
    _dataMap[contentId] = data; // 가져온 데이터를 Map에 저장합니다.
    emit(data);
  }
}
