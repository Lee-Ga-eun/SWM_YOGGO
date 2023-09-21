import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_voice_model.g.dart';

@JsonSerializable()
class BookVoiceModel extends Equatable {
  final int contentVoiceId;
  final int voiceId;
  final String voiceName;
  //final bool able;

  const BookVoiceModel({
    required this.contentVoiceId,
    required this.voiceId,
    required this.voiceName,
    //required this.able,
  });

  factory BookVoiceModel.fromJson(Map<String, dynamic> json) =>
      _$BookVoiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookVoiceModelToJson(this);

  @override
  List<Object?> get props => [contentVoiceId, voiceId, voiceName]; //, able];
}
