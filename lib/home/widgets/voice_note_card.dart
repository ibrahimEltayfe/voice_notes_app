import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:voice_notes/core/utils/app_bottom_sheet.dart';
import 'package:voice_notes/core/utils/constants/app_colors.dart';
import 'package:voice_notes/core/utils/constants/app_styles.dart';
import 'package:voice_notes/home/manager/voice_notes_cubit/voice_notes_cubit.dart';
import 'package:voice_notes/home/model/voice_note_model.dart';
import 'package:voice_notes/home/widgets/audio_player_view/audio_player_view.dart';
import 'package:voice_notes/home/widgets/play_pause_button.dart';

class VoiceNoteCard extends StatelessWidget {
  final VoiceNoteModel voiceNoteInfo;
  const VoiceNoteCard({super.key, required this.voiceNoteInfo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        showAppBottomSheet(
          context,
          showCloseButton: true,
          builder: (p0) {
            return AudioPlayerView(
              path: voiceNoteInfo.path,
            );
          },);
      },
      onLongPressStart: (details){
        final offset = details.globalPosition;

        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy,
            MediaQuery.of(context).size.width - offset.dx,
            MediaQuery.of(context).size.height - offset.dy,
          ),
          items: [
            PopupMenuItem(
              onTap: (){
               context.read<VoiceNotesCubit>().deleteRecordFile(voiceNoteInfo);
              },
              child: Text("Delete",style: AppTextStyles.medium(),),
            )
          ]
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          height: 90,
          padding: const EdgeInsets.all(18),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        voiceNoteInfo.name,
                        style: AppTextStyles.bold(
                          color: AppColors.black900,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Text(_formatDate(voiceNoteInfo.createAt),
                        style: AppTextStyles.regular(
                          color: AppColors.grey,
                          fontSize: 14,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const PlayPauseButton(
                isPlaying: false,
                onTap: null,
              )
            ],
          ),
        ),
      ),

    );
  }

  String _formatDate(DateTime dateTime){
    return DateFormat('HH:mm . dd MMM yyyy').format(dateTime);
  }
}
