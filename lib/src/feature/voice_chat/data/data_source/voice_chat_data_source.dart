




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/data/data_source/voice_chat_data_source_impl.dart';

final voicechatDataSourceProvider = Provider<VoiceChatDataSource>((ref) {
  return VoiceChatDataSourceImpl();
});


abstract class VoiceChatDataSource {
  CollectionReference voiceChats();
}