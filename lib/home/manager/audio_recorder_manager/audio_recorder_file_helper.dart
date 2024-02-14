import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:voice_notes/home/model/voice_note_model.dart';

class AudioRecorderFileHelper{
  final String _recordsDirectoryName = "audio_records";
  String? _appDirPath;
  final int fetchLimit = 15;

  Future<String> get _getAppDirPath async{
    _appDirPath ??= (await getApplicationDocumentsDirectory()).path;
    return _appDirPath!;
  }

  Future<Directory> get getRecordsDirectory async{
    Directory recordDir = Directory(path.join((await _getAppDirPath), _recordsDirectoryName));

    if(!(await recordDir.exists())){
      await recordDir.create();
    }

    return recordDir;
  }

  Future<List<VoiceNoteModel>> fetchVoiceNotes(int pageKey) async{
    int skipItems = (pageKey - 1).clamp(0, pageKey) * fetchLimit;
    int takeItems = (pageKey * fetchLimit).clamp(fetchLimit, pageKey * fetchLimit);

    List<VoiceNoteModel> voiceNotes = [];

    var files = await (await getRecordsDirectory).list().take(takeItems).skip(skipItems).toList();

    for (var file in files){
      voiceNotes.add(VoiceNoteModel(
        name: path.basename(file.path),
        createAt: file.statSync().modified,
        path: file.path
      ));
    }

    voiceNotes.sort((a, b) => b.createAt.compareTo(a.createAt),);

    return voiceNotes;
  }


  Future<void> deleteRecord(String filePath) async{
    final File file = File(filePath);

    try{
      await file.delete();
      log('file deleted');
    }catch(e){
      throw "File does not exist";
    }
  }


}