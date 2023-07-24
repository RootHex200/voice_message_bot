import 'dart:developer';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:voice_chat_bot/src/core/utils/constraint_k.dart';

class AudioTextConvertorService {
  Future<Either<Execute, String>> getAudioFromMessage(String message) async {
    try{
    FlutterTts flutterTts = FlutterTts();

    var botAudioFilename =
        "${DateTime.now().toString().split(" ")[0]}_${DateTime.now().millisecondsSinceEpoch.toString()}.wav";
    await flutterTts.synthesizeToFile(
        message.toString().toLowerCase().trim(),
        Platform.isAndroid ? botAudioFilename : "tts.caf");
    return Right(botAudioFilename);
    }catch (e){
      return Left(e as Execute);
    }
    
  }

  Future<Either<Exception, String>> getMessageFromAudio(path) async {
    try {
      const API_TOKEN = ASEEMBLYAI_TOKEN;

      final uploadUrl =
          await AudioTextConvertorService().uploadFile(API_TOKEN, path);

      if (uploadUrl == null) {
        return Left(Exception("Upload failed. Please try again."));
      }

      final transcript = await AudioTextConvertorService()
          .transcribeAudio(API_TOKEN, uploadUrl);
      return Right(transcript['text']);
    } catch (e) {
      log("getAudiotoText", error: e);
      return Left(e as Exception);
    }
  }

  Future<String?> uploadFile(String apiToken, String path) async {
    File file = File(path);
    var bytes = file.readAsBytesSync();
    const url = "https://api.assemblyai.com/v2/upload";

    try {
      final dio = Dio();
      dio.options.headers.addAll({
        HttpHeaders.contentTypeHeader: "application/octet-stream",
        HttpHeaders.authorizationHeader: apiToken,
      });
      //binary data
      final response =
          await dio.post(url, data: Stream.fromIterable(bytes.map((e) => [e])));

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData["upload_url"];
      } else {
        print("Error: ${response.statusCode} - ${response.statusMessage}");
        return null;
      }
    } catch (error) {
      print("Error: $error");
      return null;
    }
  }

  Future<Map<String, dynamic>> transcribeAudio(
      String apiToken, String audioUrl) async {
    final headers = {
      HttpHeaders.authorizationHeader: apiToken,
      HttpHeaders.contentTypeHeader: "application/json",
    };

    const url = "https://api.assemblyai.com/v2/transcript";
    final dio = Dio();

    try {
      final response = await dio.post(url,
          options: Options(headers: headers), data: {"audio_url": audioUrl});

      final responseData = response.data;
      final transcriptId = responseData["id"];

      final pollingEndpoint =
          "https://api.assemblyai.com/v2/transcript/$transcriptId";

      while (true) {
        final pollingResponse =
            await dio.get(pollingEndpoint, options: Options(headers: headers));
        final pollingResult = pollingResponse.data;

        if (pollingResult["status"] == "completed") {
          return pollingResult;
        } else if (pollingResult["status"] == "error") {
          throw Exception("Transcription failed: ${pollingResult["error"]}");
        } else {
          await Future.delayed(const Duration(seconds: 3));
        }
      }
    } catch (error) {
      print("Error: $error");
      rethrow;
    }
  }
}
