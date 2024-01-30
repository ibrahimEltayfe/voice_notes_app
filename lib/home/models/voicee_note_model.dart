import 'package:equatable/equatable.dart';

class VoiceNoteModel extends Equatable{
  final String name;
  final DateTime createAt;
  final String path;

  const VoiceNoteModel({required this.name, required this.createAt, required this.path});

  @override
  List<Object?> get props => [name,createAt,path];
}