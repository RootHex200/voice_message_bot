


import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:voice_chat_bot/src/core/utils/constraint_k.dart';

class ChatGptService{

Future<Either<Exception,String>> getMessageFromGpt(String usermessage)async{
  try{
    final response = await sendMessage(usermessage);

    final data = response.data as Map<String,dynamic>;
    final choices = data['choices'] as List<dynamic>;
    final choice = choices.first as Map<String,dynamic>;
    final text = choice['text'] as String;
    return Right(text);
  }catch(e){
    log("message from chat gpt service",error: e);
    return Left(e as Exception);
  }
}
  

Future<Response> sendMessage(String message) async {
  const apiKey = GPT_Token;
  const endpoint = 'https://api.openai.com/v1/chat/completions';
  final dio = Dio();
  dio.options.headers['Content-Type'] = 'application/json';
  dio.options.headers['Authorization'] = 'Bearer $apiKey';

  final body = {
    'model': 'gpt-3.5-turbo', // You can use other models as per your subscription
    'messages': [
      {'role': 'system', 'content': 'You are a user'},
      {'role': 'user', 'content': message},
    ],
  };

  try {
    final response = await dio.post(endpoint, data: jsonEncode(body));
    print(response);
    return response;
  } catch (e) {
    rethrow;
  }
}
}