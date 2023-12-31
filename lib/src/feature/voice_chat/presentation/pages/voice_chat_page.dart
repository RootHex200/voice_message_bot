import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_chat_bot/src/core/state/base_state.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/presentation/provider/audio_provider.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/presentation/provider/voice_button_provider.dart';
import 'package:voice_chat_bot/src/core/utils/colors/appcolors.dart';
import 'package:voice_chat_bot/src/feature/voice_chat/presentation/provider/voice_chat_message_list_provider.dart';
import 'package:voice_message_package/voice_message_package.dart';

class VoiceChat extends StatelessWidget {
  const VoiceChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text(
          'Voice Chat Bot',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final voicechatmessage = ref.watch(voicechatmessageProvider);
                return voicechatmessage.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text(error.toString()),
                  ),
                  data: (data) {
                    return ListView.separated(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      itemCount: data.length,
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: data[index].me == true
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            VoiceMessage(
                              meBgColor: Appcolors.userrMessagecolor,
                              contactBgColor: Appcolors.botMessagecolor,
                              contactPlayIconBgColor: data[index].me == true
                                  ? Colors.white
                                  : Colors.black,
                              contactPlayIconColor: data[index].me == true
                                  ? Colors.black
                                  : Colors.white,

                              played: false,
                              audioSrc: data[index].voice_message_url,

                              // To show played badge or not.
                              me: data[index].me as bool, // Set message side.
                              //showDuration: true,
                              onPlay: () {}, // Do something when voice played.
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(
                          height: 20,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(
            height: 79,
          ),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(aduioProvider);
          final voicebutton = ref.watch(voicebuttonProvider);
          return GestureDetector(
            onLongPressStart: (details) async {
              ref.read(voicebuttonProvider.notifier).state = true;
              ref.read(aduioProvider.notifier).startRecordAudio();
            },
            onLongPressEnd: (details) {
              ref.read(voicebuttonProvider.notifier).state = false;
              ref.read(aduioProvider.notifier).stoptRecordAudio();
            },

            child:state is LoadingState?const CircularProgressIndicator(color: Colors.pinkAccent,)
            
            :state is ErrorState? Text(state.data.toString(),style:const TextStyle(color: Colors.white)) :CircleAvatar(
              radius: 40,
              backgroundColor: Colors.pinkAccent,
              child: voicebutton
                  ? const Icon(
                      Icons.record_voice_over,
                      size: 40,
                    )
                  : const Icon(
                      Icons.mic,
                      size: 40,
                    ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}
