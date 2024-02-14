import 'package:flutter/material.dart';
import 'package:voice_notes/core/utils/constants/app_colors.dart';
import 'package:voice_notes/core/utils/constants/app_styles.dart';
import 'package:voice_notes/home/manager/audio_player_controller/audio_player_controller.dart';
import 'package:voice_notes/home/widgets/play_pause_button.dart';

class AudioPlayerView extends StatefulWidget {
  final String path;
  const AudioPlayerView({Key? key, required this.path,}) : super(key: key);

  @override
  State<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView> {
  final audioPlayerController = AudioPlayerController();
  late final Future loadAudio;
  double? sliderTempValue;

  @override
  void initState() {
    loadAudio = audioPlayerController.loadAudio(widget.path);
    super.initState();
  }

  @override
  void dispose() {
    audioPlayerController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadAudio,
      builder: (context, snapshot) {
        final audioDuration = audioPlayerController.duration.toDouble();

        return StreamBuilder(
          stream: audioPlayerController.progressStream,
          builder: (context, snapshot) {
            double progress = (snapshot.data ?? 0).toDouble();

            return Column(
              children: [
                Slider(
                  value: sliderTempValue ?? progress.clamp(0, audioDuration),
                  min: 0,
                  max: audioDuration,
                  onChanged: (value) {
                    setState(() {
                      sliderTempValue = value;
                    });
                  },
                  onChangeStart: (value) {
                    audioPlayerController.pause();
                  },
                  onChangeEnd: (value){
                    audioPlayerController.seek(value.toInt());
                    sliderTempValue = null;
                    audioPlayerController.play();
                  },
                  activeColor: AppColors.primary,
                ),

                Text(
                  _formatToDateTime(progress.toInt()),
                  style: AppTextStyles.medium(
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(height: 12,),

                StreamBuilder(
                  stream: audioPlayerController.playStatusStream,
                  builder: (context, snapshot) {
                    final bool isPlaying = snapshot.data ?? false;
                    return PlayPauseButton(
                      isPlaying: isPlaying,
                      onTap: () {
                        if (isPlaying) {
                          audioPlayerController.pause();
                        }else {
                          audioPlayerController.play();
                        }
                      },
                    );
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  String _formatToDateTime(int durationInMill){
    //2000 / (1000 * 60) = 00 minutes
    final int minutes = durationInMill ~/ Duration.millisecondsPerMinute;

    //(2000 % 60000) / 1000 = 02 sec
    final int seconds = (durationInMill % Duration.millisecondsPerMinute) ~/ Duration.millisecondsPerSecond;

    return '${minutes.toString().padLeft(2,'0')} : ${seconds.toString().padLeft(2,'0')}';
  }
}
