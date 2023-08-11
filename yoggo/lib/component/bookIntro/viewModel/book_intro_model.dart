import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_intro_model.g.dart';

@JsonSerializable()
class BookIntroModel extends Equatable {
  final int contentId;
  final String title;
  final String thumbUrl;
  final String summary;
  final int last;
  final List voice;

  const BookIntroModel({
    required this.contentId,
    required this.title,
    required this.thumbUrl,
    required this.summary,
    required this.last,
    required this.voice,
  });

  factory BookIntroModel.fromJson(Map<String, dynamic> json) =>
      _$BookIntroModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookIntroModelToJson(this);

  @override
  List<Object?> get props => [contentId, title, thumbUrl, summary, last, voice];
}
