import 'dart:async';
import 'package:just_audio/just_audio.dart';

class AudioPlayerController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  int get duration => _audioPlayer.duration?.inMilliseconds ?? 0;
  int get currentPosition => _audioPlayer.position.inMilliseconds;

  Stream<int> get progressStream => _audioPlayer.positionStream.map((duration) => duration.inMilliseconds);

  Stream<bool> get playStatusStream => _audioPlayer.playingStream;

  Future<void> loadAudio(String path) async {
    await _audioPlayer.setFilePath(path);
    await _audioPlayer.load();
    _audioPlayer.play();
  }

  void play() async {
    _audioPlayer.play();
  }

  void pause() async {
    _audioPlayer.pause();
  }

  void dispose() async {
    await _audioPlayer.stop();
    _audioPlayer.dispose();
  }

  void seek(int durationInMill) {
    _audioPlayer.seek(Duration(milliseconds: durationInMill));
  }

}
