import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_voice_model.g.dart';

@JsonSerializable()
class BookVoiceModel extends Equatable {
  final int contentVoiceId;
  final int voiceId;
  final String voiceName;
  bool clicked;

  BookVoiceModel({
    required this.contentVoiceId,
    required this.voiceId,
    required this.voiceName,
    this.clicked = false,
  });

  factory BookVoiceModel.fromJson(Map<String, dynamic> json) =>
      _$BookVoiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookVoiceModelToJson(this);

  @override
  List<Object?> get props => [contentVoiceId, voiceId, voiceName, clicked];
}
