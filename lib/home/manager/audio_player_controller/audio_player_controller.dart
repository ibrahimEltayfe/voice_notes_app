import 'package:just_audio/just_audio.dart';

class AudioPlayerController{
  final AudioPlayer _audioPlayer = AudioPlayer();

  Stream<int> get progressStream => _audioPlayer.positionStream.map((progress) {
    final currentProgress = progress.inMilliseconds;
    if(currentProgress == durationInMill){
      _audioPlayer.pause();
      _audioPlayer.seek(Duration.zero);
    }

    return currentProgress;
  });

  int get durationInMill => _audioPlayer.duration?.inMilliseconds ?? 0;
  Stream<bool> get playStatusStream => _audioPlayer.playingStream;

  Future<void> loadAudio(String filePath) async{
    await _audioPlayer.setFilePath(filePath);
    await _audioPlayer.load();
    _audioPlayer.play();
  }

  void play() async {
    _audioPlayer.play();
  }

  void pause() async {
    _audioPlayer.pause();
  }

  void seek(int durationInMill) {
    _audioPlayer.seek(Duration(milliseconds: durationInMill));
  }

  void dispose() async{
    await _audioPlayer.stop();
    _audioPlayer.dispose();
  }
}