import 'dart:developer';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:voice_chat_bot/src/core/firebase/common_fun/common_fun_firebase.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/data/data_source/voice_chat_data_source.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/data/model/voice_chat_data_model.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/domain/respositories/voice_chat_repositories.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/service/audio_to_text_service.dart';

class VoiceChatRepositoryImp implements VoiceChatRepository {
  VoiceChatRepositoryImp({required this.voiceChatDataSource});
  final VoiceChatDataSource voiceChatDataSource;
  final record = Record();

  @override
  Stream<Either<Exception, List<VoicechatModel>>> getVoiceChats() async* {
    CollectionReference voicechatCollection = voiceChatDataSource.voiceChats();

    yield* voicechatCollection
        .doc("YfX9DwCBHGYb6hUKpInfQ7KhnPF2")
        .collection("messages")
        .orderBy("createAt", descending: true)
        .snapshots()
        .map((event) {
      try {
        final voicechats =
            event.docs.map((e) => VoicechatModel.fromJson(e)).toList();
        return Right(voicechats);
      } catch (e) {
        log("voicerepository", error: e);
        return Left(e as Exception);
      }
    });
  }

  Future<Either<Exception, String>> saveVoiceChatData(String path,bool me) async {
    try {
      final uploadfileTostorage = await saveDataToStorage(path);
      final filedownloadurl = uploadfileTostorage.fold((l) => null, (r) => r);

      if (filedownloadurl != null) {
        final uploadDataToFirestore =
            await saveDataToFirestore("YfX9DwCBHGYb6hUKpInfQ7KhnPF2", {
          "voice_message_url": filedownloadurl,
          "createAt": Timestamp.fromDate(DateTime.now()),
          "me": me
        });
        uploadDataToFirestore.fold((l) {
          log("sendvoicechatdata save firebase", error: l);
          return null;
        }, (r) => r);
      }
      return const Right("store data successfully");
    } catch (e) {
      log("sendvoicechatdata", error: e);
      return Left(e as Exception);
    }
  }

  Future<Either<Exception, String>> getTextfromAudio(path) async {
    final response=await AudioToTextConvertor().getMessageFromAudio(path);

    final text=response.fold((l) {
      log("error from getTextFormAudio repos",error: l);
      return null;
    }, (r) {
      return r;
    });
    if(text!=null){
      return Right(text);
    }else{
      return Left(Exception("getTextFormAudio"));
    }
  }

  @override
  Future<Either<Exception, bool>> startRecordAudio() async {
    try {
      var appExternalDirectory = await getExternalStorageDirectory();
      var file =
          "${appExternalDirectory!.path}/${DateTime.now().toString().split(" ")[0]}_${DateTime.now().millisecondsSinceEpoch.toString()}.wav";
      if (await record.hasPermission()) {
        await record.start(
          path: file,
        );
      }
      bool isRecording = await record.isRecording();
      return Right(isRecording);
    } catch (e) {
      return Left(e as Exception);
    }
  }

  @override
  void stoptRecordAudioAndUploadFile() async {
    final path = await record.stop();
    print("here is file path of sotp aduio: $path");
    //save file to firebase
    if(path!=null){
    final data = await saveVoiceChatData(path,true);
    data.fold((l) {
      log("save data to firestore error");
      return null;
    }, (r) {
      log("save data to firestore success",error: "error");
      
      return r;
    });
    textToAudioAndUploadFile(path);
    }
  }

  void textToAudioAndUploadFile(audiopath)async{
    log("data from textToAudioAndUploadFile");
    FlutterTts flutterTts = FlutterTts();
    var fileName =
          "${DateTime.now().toString().split(" ")[0]}_${DateTime.now().millisecondsSinceEpoch.toString()}.wav";
    try{
    final response = await getTextfromAudio(audiopath);
    final text=response.fold((l) {
      log("convert audio to text error",error: l);
      return null;
    }, (r) {
      log("convert audio to text success");
      return r;
    });
    if(text!=null){
      await flutterTts.synthesizeToFile(text.toString().toLowerCase().trim(), Platform.isAndroid ?fileName : "tts.caf");
      //to add gpt chat
      // final gptresponse=await ChatGptService().getMessageFromGpt(text);
      // gptresponse.fold((l) {
      //   log("message from chat gpt service",error: l);
      //   return null;
      // }, (r)async {
      //   await flutterTts.synthesizeToFile(r.toString().toLowerCase().trim(), Platform.isAndroid ?fileName : "tts.caf");
      //   return r;
      // });
      
      
    }
    await Future.delayed(Duration.zero,()async{
      var appExternalDirectory = await getExternalStorageDirectory();
      var newpath =
          "${appExternalDirectory!.path}/$fileName";
    final response=await saveVoiceChatData(newpath, false);
    response.fold((l) {
      log("save gpt to firestore error");
      return null;
    }, (r) {
      log("save gpt to firestore success");
      File(audiopath).delete();
      File(newpath).delete();
      return r;
    });
    });
    }catch (e){
      log("textToAudioAndUploadFile",error: e);
    }
  }
}
