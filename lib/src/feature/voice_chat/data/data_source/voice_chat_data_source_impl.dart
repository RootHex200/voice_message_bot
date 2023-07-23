



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/data/data_source/voice_chat_data_source.dart';

class VoiceChatDataSourceImpl extends VoiceChatDataSource{  

  @override
  CollectionReference voiceChats() {
    return FirebaseFirestore.instance.collection('users');
  }
  

}