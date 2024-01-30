import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:voice_notes/home/models/voicee_note_model.dart';

class AudioRecorderFileHelper{
  final String _recordsDirectoryName = "audio_records";
  String? _appDirPath;
  final int _fetchLimit = 15;

  //Path managers
  FutureOr<String> get _getAppDirPath async{
    _appDirPath ??= (await getApplicationDocumentsDirectory()).path;
    return _appDirPath!;
  }

  Future<Directory> get getRecordsDirectory async{
    Directory directory = Directory(path.join((await _getAppDirPath),_recordsDirectoryName));

    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    return directory;
  }

  //Fetch all records
  Future<List<VoiceNoteModel>> fetchVoiceNotes(int pageKey) async{
    int skipItems = (pageKey-1).clamp(0, pageKey) * _fetchLimit;
    int takeItems = (pageKey * _fetchLimit).clamp(_fetchLimit, pageKey * _fetchLimit);

    print(pageKey);
    List<VoiceNoteModel> voiceNotes = [];

    var files = await (await getRecordsDirectory).list().skip(skipItems).take(takeItems).toList();

    for (var file in files) {
      voiceNotes.add(generateVoiceNoteModel(file.path, (await file.stat()).modified));
    }

    voiceNotes.sort((a, b) => b.createAt.compareTo(a.createAt));

    print(voiceNotes.length);
    return voiceNotes;
  }

  //Delete record
  Future<void> deleteRecord(String filePath) async{
    final File file = File(filePath);

    try{
      await file.delete();
      log('file deleted');
    }catch(e){
      throw "File does not exist";
    }
  }

  VoiceNoteModel generateVoiceNoteModel(String recordPath,DateTime createdData){
    return VoiceNoteModel(
      path: recordPath,
      name: path.basename(recordPath),
      createAt: createdData
    );
  }
}