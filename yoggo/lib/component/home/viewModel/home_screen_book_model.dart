import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'home_screen_book_model.g.dart';

@JsonSerializable()
class HomeScreenBookModel extends Equatable {
  final int id;
  final String title;
  final String thumbUrl;
  final String summary;
  final String createdAt;
  final int last;
  final int age;
  final bool visible;

  const HomeScreenBookModel({
    required this.id,
    required this.title,
    required this.thumbUrl,
    required this.summary,
    required this.createdAt,
    required this.last,
    required this.age,
    required this.visible,
  });

  factory HomeScreenBookModel.fromJson(Map<String, dynamic> json) =>
      _$HomeScreenBookModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeScreenBookModelToJson(this);

  @override
  List<Object?> get props =>
      [id, title, thumbUrl, summary, createdAt, last, age, visible];
}
