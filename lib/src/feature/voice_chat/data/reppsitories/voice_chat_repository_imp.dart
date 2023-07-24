import 'dart:developer';
import 'dart:io';
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
  AudioTextConvertorService audioService = AudioTextConvertorService();
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
  Future<Either<Exception, String>> stoptRecordAudio() async {
    final path = await record.stop();
    log("here is file path of sotp aduio: $path");
    if (path != null) {
      return Right(path);
      // final data = await saveVoiceChatData(path,true);
      // data.fold((l) {
      //   log("save data to firestore error");
      //   return null;
      // }, (r) {
      //   log("save data to firestore success",error: "error");

      //   return r;
      // });
      // textToAudioAndUploadFile(path);
    }
    return Left(Exception("path is empty"));
  }


  @override
  Future<Either<Exception, String>> saveUserAudioFileToDatabase(
      String path) async {
        return await saveaudioFileToDatabase(path,true);
  }

  @override
  Future<Either<Exception, String>> generateBotAudioFileandSaveToDatabase(
      String userAudiopath) async {
    //get text from user audio file
    final getmessageresponse = await audioService.getMessageFromAudio(userAudiopath);
    final userTextfromAudio = getmessageresponse.fold((l) {
      log("error from getTextFormAudio repos", error: l);
      return null;
    }, (r) {
      return r;
    });

    //genearte bot audio file from this.text
    if (userTextfromAudio != null) {
      final getAudioresponse = await audioService.getAudioFromMessage(userTextfromAudio);
      final botAudioFilename = getAudioresponse.fold((l) {
        log("error from getAudioFromMessage repos", error: l);
        return null;
      }, (r) {
        return r;
      });

      //save bot audio file to firebase
      if(botAudioFilename!=null){
        await Future.delayed(Duration.zero, () async {
        var appExternalDirectory = await getExternalStorageDirectory();
        var botAudioPath = "${appExternalDirectory!.path}/$botAudioFilename";
        final response = await saveaudioFileToDatabase(botAudioPath, false);
        response.fold((l) {
          log("save gpt to firestore error");
          return null;
        }, (r) {
          log("save gpt to firestore success");
          File(userAudiopath).delete();
          File(botAudioPath).delete();
          return r;
        });
      });
      }
      return const Right("save bot audio file to database");
    }
    return Left(Exception("userTextfromAudio is null"));
  }
}
