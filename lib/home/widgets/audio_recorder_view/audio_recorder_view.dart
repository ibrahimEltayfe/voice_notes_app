import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import 'package:voice_notes/core/utils/constants/app_colors.dart';
import 'package:voice_notes/core/utils/constants/app_styles.dart';
import 'package:voice_notes/home/manager/audio_recorder_manager/audio_recorder_controller.dart';
import 'package:voice_notes/home/manager/audio_recorder_manager/audio_recorder_file_helper.dart';
import 'package:voice_notes/home/widgets/play_pause_button.dart';

import 'audio_waves_view.dart';

class AudioRecorderView extends StatelessWidget {
  const AudioRecorderView({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AudioRecorderController>(
      create: (context) => AudioRecorderController(
        AudioRecorderFileHelper(),
        (message) {
          print(message);
        },
      ),
      child: const _AudioRecorderViewBody(),
    );
  }
}

class _AudioRecorderViewBody extends StatefulWidget {
  const _AudioRecorderViewBody({super.key});

  @override
  State<_AudioRecorderViewBody> createState() => _AudioRecorderViewBodyState();
}

class _AudioRecorderViewBodyState extends State<_AudioRecorderViewBody> {
  late final AudioRecorderController audioRecorderService;

  @override
  void initState() {
    audioRecorderService = context.read<AudioRecorderController>();
    audioRecorderService.start();
    super.initState();
  }

  @override
  void dispose() {
    audioRecorderService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          const AudioWavesView(),

          const SizedBox(height: 16),

          const _TimerText(),

          Row(
            textDirection: TextDirection.rtl,
            children: [
              GestureDetector(
                onTap: (){
                  context.read<AudioRecorderController>().stop((voiceNoteModel){
                    Navigator.pop(context,voiceNoteModel);
                  });
                },
                child: Text(
                  "Save note",
                  style: AppTextStyles.medium(
                    color: AppColors.background,
                    fontSize: 18
                  ),
                ),
              ),

              const Spacer(),

              StreamBuilder(
                stream: audioRecorderService.recordStateStream,
                builder: (context, snapshot) {
                  return PlayPauseButton(
                    isPlaying: snapshot.data == RecordState.record,
                    onTap: () {
                      if(snapshot.data == RecordState.pause){
                        audioRecorderService.resume();
                      }else{
                        audioRecorderService.pause();
                      }
                    },
                  );
                },
              ),

              const Spacer(),

              GestureDetector(
                onTap: (){
                  context.read<AudioRecorderController>().stop((voiceNoteModel){
                    if(voiceNoteModel == null){
                      Navigator.pop(context);
                    }else{
                      context.read<AudioRecorderController>().delete(voiceNoteModel.path).then((value){
                        Navigator.pop(context);
                      });
                    }

                  });
                },
                child: Text(
                  "Dismiss",
                  style: AppTextStyles.medium(
                    color: AppColors.red,
                    fontSize: 18
                  ),
                ),
              )
            ],
          )
        ],
      )
    );
  }
}
class _TimerText extends StatelessWidget {
  const _TimerText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder(
        initialData: 0,
        stream: context.read<AudioRecorderController>().recordDurationOutput,
        builder: (context, snapshot) {
          final durationInSec = snapshot.data ?? 0;

          final int minutes = durationInSec ~/ 60;
          final int seconds = durationInSec % 60;

          return Text(
            '${minutes.toString().padLeft(2,'0')} : ${seconds.toString().padLeft(2,'0')}',
            style: AppTextStyles.medium(
                color: AppColors.background
            ),
          );
        },
      ),
    );
  }
}
