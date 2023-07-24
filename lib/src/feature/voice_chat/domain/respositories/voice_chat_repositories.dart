





import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/data/data_source/voice_chat_data_source.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/data/model/voice_chat_data_model.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/data/reppsitories/voice_chat_repository_imp.dart';


final voicechatRepositoryProvider = Provider<VoiceChatRepository>((ref) {
  return VoiceChatRepositoryImp(voiceChatDataSource: ref.watch(voicechatDataSourceProvider));
});


abstract class VoiceChatRepository{

  Stream<Either<Exception,List<VoicechatModel>>> getVoiceChats();
  void startRecordAudio();
  Future<Either<Exception,String>> stoptRecordAudio();

  //store user aduio file to database

  Future<Either<Exception,String>> saveUserAudioFileToDatabase(String useraudiopath);

  // store botgenerate audio file to database

  Future<Either<Exception,String>> generateBotAudioFileandSaveToDatabase(String userAudiopath);
}