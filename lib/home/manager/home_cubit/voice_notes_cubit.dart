import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:voice_notes/home/manager/audio_recorder_controller/audio_recorder_file_helper.dart';
import 'package:voice_notes/home/models/voicee_note_model.dart';

part 'voice_notes_state.dart';

class VoiceNotesCubit extends Cubit<VoiceNotesState> {
  final AudioRecorderFileHelper audioRecorderFileHelper;
  VoiceNotesCubit(this.audioRecorderFileHelper) : super(VoiceNotesInitial());
  
  void getAllVoiceNotes(int pageKey) async{
    emit(VoiceNotesLoading());
    
    try{
      final voiceNotes = await audioRecorderFileHelper.fetchVoiceNotes(pageKey);
      emit(VoiceNotesFetched(voiceNotes: voiceNotes));

    }catch(e){
      log(e.toString());
      //todo: handle errors
      emit(const VoiceNotesError(message: 'error'));
    }
  }

  void deleteRecordFile(VoiceNoteModel voiceNoteModel) async{
    try{
      await audioRecorderFileHelper.deleteRecord(voiceNoteModel.path);
      emit(VoiceNoteDeleted(voiceNoteModel: voiceNoteModel));

    }catch(e){
      print(e.toString());
    }
  }

  void addToNotes(VoiceNoteModel voiceNoteModel){
    emit(VoiceNoteAdded(voiceNoteModel: voiceNoteModel));
  }
}
