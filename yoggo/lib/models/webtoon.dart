class WebtoonModel {
  final String title, thumb, id;

//service에서 넘겨준 webtoon을 받는다
// WebtoonModel.fromJson(webtoon)
// webtoon의 형식: {id: 602916, title: 칼부림, thumb: https://image-comic.pstatic.net/webtoon/602916/thumbnail/thumbnail_IMAG21_43cf1d1e-d265-464d-83db-f92dbc3fcf43.jpg}
// named structrue 만들기
  WebtoonModel.fromJson(Map<String, dynamic> webtoon)
      : title = webtoon['title'], //json으로 초기화시켜주기
        thumb = webtoon['thumb'],
        id = webtoon['id'];
}
