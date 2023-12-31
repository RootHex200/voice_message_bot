
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/data/model/voice_chat_data_model.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/domain/use_cases/voice_chat_use_case.dart';

final voicechatmessageProvider = StreamProvider<List<VoicechatModel>>((ref)async* {
  Stream<Either<Exception,List<VoicechatModel>>> voicechatmessage = ref.watch(voicechatusecaseProvider).voiceChats();
  
  yield* voicechatmessage.map((event) {
    return event.fold((l) {
    log('voicechatmessageProvider',error: l);
    return [];
  }, (r) => r);
  });
});
