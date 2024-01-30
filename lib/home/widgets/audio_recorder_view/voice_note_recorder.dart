import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import 'package:voice_notes/core/utils/constants/app_colors.dart';
import 'package:voice_notes/core/utils/constants/app_styles.dart';
import 'package:voice_notes/home/manager/audio_recorder_controller/audio_recorder_file_helper.dart';
import 'package:voice_notes/home/manager/audio_recorder_controller/audio_recorder_controller.dart';
import 'package:voice_notes/home/widgets/play_pause_button.dart';

import 'audio_waves_view.dart';

class VoiceNoteRecorder extends StatelessWidget {
  const VoiceNoteRecorder({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AudioRecorderController>(
      create: (_) => AudioRecorderController(AudioRecorderFileHelper()),
      child: const _VoiceNoteRecorderBody(),
    );
  }
}

class _VoiceNoteRecorderBody extends StatefulWidget{
  const _VoiceNoteRecorderBody({Key? key}) : super(key: key);

  @override
  State<_VoiceNoteRecorderBody> createState() => _VoiceNoteRecorderBodyState();
}

class _VoiceNoteRecorderBodyState extends State<_VoiceNoteRecorderBody> {
  late final AudioRecorderController audioRecorderService;

  @override
  void initState() {
    audioRecorderService = context.read<AudioRecorderController>();
    audioRecorderService.start();
    super.initState();
  }

  @override
  void deactivate() {
    audioRecorderService.dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,

      child: StreamBuilder(
        stream: context.read<AudioRecorderController>().recordStateOutput,
        builder: (context, snapshot) {
          if(snapshot.error != null){
            return Text(snapshot.error.toString());
          }

          return Column(
            children: [
              const AudioWavesView(),

              const SizedBox(height: 16),

              const _TimerText(),

              const SizedBox(height: 12),

              Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      audioRecorderService.stop((voiceNoteModel){
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
                    stream: audioRecorderService.recordStateOutput,
                    builder: (context, snapshot) {
                      return PlayPauseButton(
                          isPlaying: snapshot.data == RecordState.record,
                          onTap: (){
                            if(snapshot.data == RecordState.pause){
                              audioRecorderService.resume();
                            }else{
                              audioRecorderService.pause();
                            }
                          }
                      );
                    },
                  ),

                  const Spacer(),

                  GestureDetector(
                    onTap: (){
                      audioRecorderService.stop((voiceNoteModel){
                        audioRecorderService.delete(voiceNoteModel.path).then((value){
                          Navigator.pop(context);
                        });
                      });
                    },
                    child: Text(
                      "Dismiss",
                      style: AppTextStyles.medium(
                          color: AppColors.red,
                          fontSize: 18
                      ),
                    ),
                  ),

                ],
              )

            ],
          );
        },
      ),
    );

  }
}

class _TimerText extends StatelessWidget {
  const _TimerText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: StreamBuilder<int>(
        initialData: 0,
        stream: context.read<AudioRecorderController>().recordDurationOutput,
        builder: (context, snapshot) {
          final String minutes = _formatNumber((snapshot.data??0) ~/ 60);
          final String seconds = _formatNumber((snapshot.data??0) % 60);

          return Text(
            '$minutes : $seconds',
            style: AppTextStyles.medium(
              color: AppColors.background
            ),
          );
        }
      ),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }
}
