

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_chat_bot/src/core/state/base_state.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/domain/use_cases/voice_chat_use_case.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/presentation/provider/audio_notifier.dart';

final aduioProvider = StateNotifierProvider<AudioNotifier,BaseState>((ref) {
  return AudioNotifier(voiceChatUseCase: ref.watch(voicechatusecaseProvider));
});