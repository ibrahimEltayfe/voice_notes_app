import 'dart:developer';

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

class _AudioPlayerViewState extends State<AudioPlayerView>{
  late final Future loadData;
  final audioPlayerController = AudioPlayerController();

  @override
  void initState() {
    loadData = audioPlayerController.loadAudio(widget.path);
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
      future: loadData,
      builder: (context, snapshot) {
        final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        final audioDuration = audioPlayerController.duration.toDouble();

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: StreamBuilder(
              stream: audioPlayerController.progressStream,
              builder: (context, snapshot) {
                double progress = (snapshot.data ?? 0).toDouble();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Slider(
                        value: progress.clamp(0, audioDuration),
                        onChanged: (value) {
                          audioPlayerController.seek(value.toInt());
                        },
                        max: audioDuration,
                        activeColor: AppColors.primary,
                      ),
                    ),

                    isLoading
                      ? const SizedBox(width: 15,height: 15,child: CircularProgressIndicator(color: AppColors.primary,))
                      : Text(
                          convertDurationToTime(Duration(milliseconds: progress.toInt())),
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
                          onTap: (){
                            if (isPlaying) {
                              audioPlayerController.pause();
                            }else {
                              audioPlayerController.play();
                            }
                          },
                          isPlaying: isPlaying,
                        );
                      },
                    ),

                  ],
                );
              },
            ),
          ),
        );

   });
  }

  String convertDurationToTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (twoDigits(duration.inHours) != '00') {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }
}

