import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:voice_notes/core/utils/constants/app_colors.dart';

class PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final Function()? onTap;
  const PlayPauseButton({super.key, required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: AppColors.primary,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 54,
          height: 54,
          padding: EdgeInsets.only(
            left: isPlaying ? 0 : 4,
          ),
         // color: AppColors.primary,
          child: Icon(
            isPlaying ? FeatherIcons.pause : FeatherIcons.play,
            color: AppColors.background,
            size: 22,
          ),
        ),
      ),
    );
  }
}
