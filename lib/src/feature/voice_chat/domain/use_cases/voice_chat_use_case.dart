




import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/data/model/voice_chat_data_model.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/domain/respositories/voice_chat_repositories.dart';

final voicechatusecaseProvider = Provider<VoiceChatUseCase>((ref) {
  return VoiceChatUseCase(repository: ref.watch(voicechatRepositoryProvider));
});


class VoiceChatUseCase {
  final VoiceChatRepository repository;

  VoiceChatUseCase({required this.repository});

  Stream<Either<Exception,List<VoicechatModel>>> voiceChats()async*  {
    yield* repository.getVoiceChats();
  }
  void startRecordAudio()async {
    repository.startRecordAudio();
  }
  void stoptRecordAudio()async {
    repository.stoptRecordAudioAndUploadFile();
  }
}