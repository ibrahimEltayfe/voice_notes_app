import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:voice_notes/home/models/voicee_note_model.dart';
import 'audio_recorder_file_helper.dart';

class AudioRecorderController{
  final AudioRecorderFileHelper _fileHelper;
  AudioRecorderController(this._fileHelper);

  //variables
  final AudioRecorder _audioRecorder = AudioRecorder();

  Timer? _timer;
  int recordDuration = 0;

  //stream controllers
  final StreamController<int> _recordDurationController = StreamController<int>.broadcast();
  final StreamController<RecordState> _recordStateController = StreamController<RecordState>.broadcast();

  //inputs
  Sink<int> get recordDurationInput => _recordDurationController.sink;
  Sink<RecordState> get recordStateInput => _recordStateController.sink;

  //outputs
  Stream<int> get recordDurationOutput => _recordDurationController.stream;
  Stream<RecordState> get recordStateOutput => _recordStateController.stream;
  Stream<double> get amplitudeStream => _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 420)).map((e) => e.current);

  //config methods
  void init(){
    recordDurationInput.add(0);
    recordStateInput.add(RecordState.stop);
  }

  dispose(){
    _timer?.cancel();
    _recordStateController.close();
    _recordDurationController.close();
    _audioRecorder.dispose();
  }
  
  void _reset(){
    recordDuration = 0;
    recordDurationInput.add(0);
    _timer?.cancel();
  }

  //helper methods
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      recordDuration++;
      recordDurationInput.add(recordDuration);
    });
  }

  String get _getAudioExtension => 'm4a';

  //core methods
  Future<void> start() async {
    final isMicPermissionGranted = await _checkMicPermissions();

    if (!isMicPermissionGranted) {
      _recordStateController.addError('Could not grant mic permission');
      return;
    }

    try{
      await handleFileFailures(() async{
        //audio path
        final String recordPath = path.join(
          (await _fileHelper.getRecordsDirectory).path,
          "${DateTime.now().millisecondsSinceEpoch}.$_getAudioExtension",
        );

        //start recording
        await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc),path: recordPath,);
        _reset();
        _startTimer();
        recordStateInput.add(RecordState.record);
      },
      onError: (message) {
        if(message != null) {
          _recordStateController.addError(message);
        }else{
          _recordStateController.addError("App needs a permission to access microphone");
        }
      },

     );

    }catch(e){
      log(e.toString());
      _recordStateController.addError("error, can not start recording.");
    }

    }

  Future<void> stop(Function(VoiceNoteModel voiceNoteModel) onStop) async {
    final path = await _audioRecorder.stop();
    recordStateInput.add(RecordState.stop);

    if (path != null) {
      onStop(_fileHelper.generateVoiceNoteModel(path, DateTime.now()));
    }else{
      _recordStateController.addError("Could not save the file");
    }

    _reset();
  }

  Future<void> pause() async {
    _timer?.cancel();
    await _audioRecorder.pause();
    recordStateInput.add(RecordState.pause);
  }

  Future<void> resume() async {
    _startTimer();
    await _audioRecorder.resume();
    recordStateInput.add(RecordState.record);
  }

  Future<void> delete(String filePath) async{
    await pause();
    await handleFileFailures(
      () async{
        return await _fileHelper.deleteRecord(filePath);
      },
      onError: (message){
        if(message != null){
          _recordStateController.addError(message);
        }
      }
    );
  }

  Future<bool> _checkMicPermissions() async{
    const micPermission = Permission.microphone;

    if (await micPermission.isGranted) {
      return true;
    } else {
      final permissionStatus = await micPermission.request();

      if (permissionStatus.isGranted || permissionStatus.isLimited) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<void> handleFileFailures(
      Future<void> Function() task, {
        required Function(String?) onError,
      }
      ) async{
    try{
      await task();
    }catch(error){
      log(error.toString());

      if(error is FileSystemException){
        onError(error.message);
      }

      //todo:check write/read permissions. if not granted, ask for them.
      //else: do nothing

    }
  }
}

