import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isSentByBot;
  final bool isSender;
  final String? time;

  ChatMessage({
    required this.message,
    required this.isSentByBot,
    required this.isSender,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment:
            isSentByBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            message,
            style: TextStyle(
              fontSize: 16.0,
              color: isSentByBot ? Colors.black : Colors.white,
            ),
          ),
          // if (isSentByBot && time.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text(
              time ?? '',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
