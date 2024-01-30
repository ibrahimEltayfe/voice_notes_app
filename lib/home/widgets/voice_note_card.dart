import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:intl/intl.dart';
import 'package:voice_notes/core/utils/app_bottom_sheet.dart';
import 'package:voice_notes/core/utils/constants/app_colors.dart';
import 'package:voice_notes/core/utils/constants/app_styles.dart';
import 'package:voice_notes/home/manager/home_cubit/voice_notes_cubit.dart';
import 'package:voice_notes/home/models/voicee_note_model.dart';

import 'audio_player_view/audio_player_view.dart';
import 'play_pause_button.dart';

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
      onLongPressStart: (details) {
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
                onTap: () {
                  context.read<VoiceNotesCubit>().deleteRecordFile(voiceNoteInfo);
                },
                child: Text("Delete",style: AppTextStyles.medium(),),
              ),
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        voiceNoteInfo.name,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColors.black900,
                          fontSize: 18,
                          fontFamily: 'Dubai',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatDate(voiceNoteInfo.createAt),//'11:59 . 13 Oct 2024',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 14,
                          fontFamily: 'Dubai',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              PlayPauseButton(
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
