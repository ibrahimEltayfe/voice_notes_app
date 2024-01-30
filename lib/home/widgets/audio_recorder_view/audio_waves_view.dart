import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_notes/core/utils/constants/app_colors.dart';
import 'package:voice_notes/home/manager/audio_recorder_controller/audio_recorder_controller.dart';

class AudioWavesView extends StatefulWidget {
  const AudioWavesView({super.key});

  @override
  State<AudioWavesView> createState() => _AudioWavesViewState();
}

class _AudioWavesViewState extends State<AudioWavesView> {
  final ScrollController scrollController = ScrollController();
  late StreamSubscription amplitudeSubscription;
  List<double> amplitudes = [];
  double wavesMaxHeight = 45;

  @override
  void initState() {
    amplitudeSubscription = context.read<AudioRecorderController>().amplitudeStream.listen(_amplitudeListener);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    amplitudeSubscription.cancel();
    super.dispose();
  }

  void _amplitudeListener(double ampl){
    setState(() {
      amplitudes.add(ampl);
    });

    if(scrollController.positions.isNotEmpty){
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 175)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: wavesMaxHeight,
        child: ListView.builder(
          controller: scrollController,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: amplitudes.length,
          shrinkWrap: true,
          itemExtent: 6,
          itemBuilder: (context, index) {
            double paddingValue;

            if(amplitudes[index] >= 0){
              //if amplifier is positive or 0 (very high volume)
              paddingValue = 0;
            }else{
              paddingValue = wavesMaxHeight * (amplitudes[index].abs() / wavesMaxHeight);
              if(paddingValue >= wavesMaxHeight){
                //if the value is very low
                paddingValue = wavesMaxHeight *0.99;
              }
            }

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: wavesMaxHeight,end: paddingValue/2),
              duration: const Duration(milliseconds: 500),
              curve: Curves.decelerate,
              builder: (context, value, child) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: value,
                    bottom: value,
                    left: 1,
                    right: 1,
                  ),

                  child: child,
                );
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8)
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
