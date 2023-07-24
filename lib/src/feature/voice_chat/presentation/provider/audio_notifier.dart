

import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_chat_bot/src/core/state/base_state.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/domain/use_cases/voice_chat_use_case.dart';


class AudioNotifier extends StateNotifier<BaseState> {
  
  AudioNotifier({required this.voiceChatUseCase}): super(const InitialState());
  final VoiceChatUseCase voiceChatUseCase;
  void startRecordAudio()async {
    voiceChatUseCase.startRecordAudio();
  }
  void stoptRecordAudio()async {
   final audioFilepath=await voiceChatUseCase.stoptRecordAudio();
   audioFilepath.fold((l) {
    log("audiofilepath:- ",error: l);
   }, (r) => saveUserAudioFileToDatabase(r));
  }

  void saveUserAudioFileToDatabase(String useraudiopath)async {
    state=const LoadingState();
    final result=await voiceChatUseCase.saveUserAudioFileToDatabase(useraudiopath);
    log(result.fold((l) {
       state=const ErrorState(data: "Error Try Again!");
      return "";
    }, (r) {
      generateBotAudioFileandSaveToDatabase(useraudiopath);
      return r;
    }));
  }

  void generateBotAudioFileandSaveToDatabase(String userAudiopath)async {
    final result=await voiceChatUseCase.generateBotAudioFileandSaveToDatabase(userAudiopath);
    log(result.fold((l) {
      state=const ErrorState(data: "Error Try Again!");
      return "";
    }, (r) {
      state=SuccessState(data: r);
      return r;
    }));
  }
}