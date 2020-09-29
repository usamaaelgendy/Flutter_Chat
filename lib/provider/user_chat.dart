import 'package:chatting_ui_fun/database/database_services.dart';
import 'package:chatting_ui_fun/model/messages.dart';
import 'package:flutter/cupertino.dart';

class UserChat extends ChangeNotifier {
  List<Messages> _messages;

  List<Messages> get message => _messages;
  DatabaseServices _databaseServices = DatabaseServices();

  List<Messages> listenToMessages(String groupChatId) {
    _databaseServices.listenToMessages(groupChatId).listen((userData) {
      print(userData);
      _messages = userData;
    });
    return _messages;
  }
}
