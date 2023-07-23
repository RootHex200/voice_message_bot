


import 'package:cloud_firestore/cloud_firestore.dart';

class VoicechatModel {

  String? voice_message_url;
  DateTime? createAt;
  bool? me;
  VoicechatModel({
    required this.voice_message_url,
    required this.createAt,
    required this.me,
  });
  

  VoicechatModel.fromJson(QueryDocumentSnapshot<Map<String, dynamic>> docsnapshot) {
    voice_message_url = docsnapshot['voice_message_url'];
    Timestamp timestamp = docsnapshot['createAt'];
    createAt =DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    me = docsnapshot['me'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['voice_message_url'] = voice_message_url;
    data['createAt'] = createAt;
    data['me'] = me;
    return data;
  }
}
