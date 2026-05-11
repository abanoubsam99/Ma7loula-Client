import 'dart:developer';
import 'dart:io';

// import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola/controller/user_provider.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/assets_manager.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:ma7lola/core/utils/util_values.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
// import 'package:social_media_recorder/audio_encoder_type.dart';
// import 'package:social_media_recorder/screen/social_media_recorder.dart';

import '../../../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../../../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../../../../../core/services/secure_storage/secure_storage_service.dart';
import 'local_widgets/chat_message.dart';
import 'local_widgets/chat_message_item.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = '/helpchat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  // final AudioPlayer _audioPlayer = AudioPlayer();

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    return Scaffold(
      backgroundColor: ColorsPalette.lightGrey,
      appBar: AppBarApp(
        title: LocaleKeys.help.tr(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: /* userProvider.isLoggedIn
            ? FirebaseFirestore.instance
                .collection('questions')
                .doc(userProvider.user?.data?.user?.authToken ?? '')
                .collection('chats')
                .orderBy('timestamp')
                .snapshots()
            :*/
            FirebaseFirestore.instance
                .collection('questions')
                .orderBy('timestamp')
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          final questions = snapshot.data!.docs;

          return Column(
            children: <Widget>[
              if (!questions.any((element) => element['isSender'] == true))
                Container(
                  margin: EdgeInsets.all(8),
                  alignment: Alignment.center,
                  height: 30.h,
                  decoration: BoxDecoration(
                      color: ColorsPalette.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Image.asset(
                      AssetsManager.appBlackLogo,
                    ),
                  )),
                ),
              Expanded(
                  child: ListView.builder(
                controller: _scrollController,
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: ChatMessageItem(
                      message: ChatMessage(
                          message: questions[index]['text'],
                          isSentByBot: questions[index]['isSentByBot'],
                          isSender: questions[index]['isSender']),
                      onTap: () async {
                        final storedToken = await SecureStorageService.instance
                            .readString(key: SecureStorageKeys.token);
                        _showResponse(questions[index]['answer'],
                            questions[index]['text']);
                        if (questions[index]['isSender'] != true) {
                          if (userProvider.isLoggedIn) {
                            await FirebaseFirestore.instance
                                .collection('questions')
                                // .doc(storedToken ?? '')
                                // .collection('chats')
                                .add({
                              'text': questions[index]['text'],
                              'answer': '',
                              'isSender': true,
                              'isSentByBot': false,
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                          } else {
                            await FirebaseFirestore.instance
                                .collection('questions')
                                .add({
                              'text': questions[index]['text'],
                              'answer': '',
                              'isSender': true,
                              'isSentByBot': false,
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                          }
                        }
                        _scrollToBottom();
                        setState(() {
                          // messages.add(ChatMessage(
                          //   message: messages[index].message,
                          //   isSentByBot: true,
                          //   isSender: true,
                          //   time: DateTime.now().toString(),
                          // ));
                          _messageController.clear();
                        });
                      },
                    ),
                    // onTap: () => _showResponse(
                    //     questions[index]['answer'], questions[index]['text']),
                  );
                },
              )),
              Container(
                color: ColorsPalette.white,
                padding: EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: ColorsPalette.lightGrey),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: <Widget>[
                      UtilValues.gap8,
                      // _socialMediaRecord(),
                      UtilValues.gap8,
                      Expanded(
                        child: TextField(
                          style: TextStyle(fontFamily: ZainTextStyles.font),
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالتك',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: SvgPicture.asset(AssetsManager.send),
                        onPressed: _sentMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _response = '';

  _sentMessage() async {
    final userProvider = context.read<UserProvider>();

    final storedToken = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    if (userProvider.isLoggedIn) {
      await Future.delayed(Duration(seconds: 3));
      await FirebaseFirestore.instance
          .collection('questions')
          // .doc(storedToken ?? '')
          // .collection('chats')
          .add({
        'text': _messageController.text,
        'answer': '',
        'isSender': true,
        'isSentByBot': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
      _scrollToBottom();
    } else {
      await Future.delayed(Duration(seconds: 3));
      await FirebaseFirestore.instance.collection('questions').add({
        'text': _messageController.text,
        'answer': '',
        'isSender': true,
        'isSentByBot': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
      _scrollToBottom();
    }
    setState(() {});
  }

  void _showResponse(String answer, String question) async {
    final userProvider = context.read<UserProvider>();

    final storedToken = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    if (userProvider.isLoggedIn) {
      await Future.delayed(Duration(seconds: 3));
      await FirebaseFirestore.instance
          .collection('questions')
          // .doc(storedToken ?? '')
          // .collection('chats')
          .add({
        'text': answer,
        'answer': '',
        'isSender': false,
        'isSentByBot': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _scrollToBottom();
      setState(() {
        _response = answer;
      });
    } else {
      await Future.delayed(Duration(seconds: 3));
      await FirebaseFirestore.instance.collection('questions').add({
        'text': answer,
        'answer': '',
        'isSender': false,
        'isSentByBot': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _scrollToBottom();
      setState(() {
        _response = answer;
      });
    }
  }

  Future<void> _addQuestionToFirestore(String question) async {
    await FirebaseFirestore.instance.collection('user_questions').add({
      'question': question,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  //
  // String? _record;
  // Widget _socialMediaRecord() {
  //   return SocialMediaRecorder(
  //     sendButtonIcon: Icon(CupertinoIcons.mic),
  //     backGroundColor: ColorsPalette.white,
  //     recordIconWhenLockedRecord: Icon(CupertinoIcons.mic),
  //     // slideToCancelValue: 60,
  //     // timeRecordLimitation: duration,
  //     radius: const BorderRadius.all(Radius.circular(100)),
  //     recordIconBackGroundColor: ColorsPalette.white,
  //     slideToCancelTextStyle: TextStyle(
  //       color: ColorsPalette.black,
  //       fontSize: 14.sp,
  //       fontFamily: ZainTextStyles.font,
  //     ),
  //     recordIconWhenLockBackGroundColor: ColorsPalette.primaryColor,
  //     recordIcon: Icon(CupertinoIcons.mic),
  //     sendRequestFunction: (soundFile, text) {
  //       _sendAudio(soundFile);
  //       startPlayMp3();
  //     },
  //     encode: AudioEncoderType.AAC_LD,
  //   );
  // }
  //
  // void startPlayMp3() async {
  //   await _audioPlayer.play(
  //     AssetSource('audio/message_send.wav'),
  //   );
  // }

  // Future<void> _sendAudio(File soundFile) async {
  //   try {
  //     await Future.delayed(Duration(seconds: 3));
  //     final result = await MiscellaneousApi.uploadImage(
  //         image: soundFile, locale: context.locale);
  //     setState(() {
  //       _record = result.data?.images?.first.filename ?? '';
  //     });
  //     await FirebaseFirestore.instance.collection('questions').add({
  //       'text': _record ?? '',
  //       'answer': '',
  //       'isSender': true,
  //       'isSentByBot': false,
  //       'timestamp': FieldValue.serverTimestamp(),
  //     });
  //     _messageController.clear();
  //     _record = '';
  //     _record = null;
  //     _scrollToBottom();
  //     log('dldklkdk $result');
  //   } catch (error) {
  //     log('error: $error');
  //   }
  // }
}
