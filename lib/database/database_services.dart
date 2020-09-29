import 'dart:async';

import 'package:chatting_ui_fun/model/messages.dart';
import 'package:chatting_ui_fun/model/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('Users');
  final CollectionReference _messageCollectionRef =
      FirebaseFirestore.instance.collection('Messages');

  // stream Controller
  final StreamController<List<Messages>> _messageUserController =
      StreamController<List<Messages>>.broadcast();

  // Add and Update User Data
  Future addAndUpdateUserData(Users user) async {
    return _userCollectionRef.doc(user.userId).set(user.toJson());
  }

  Stream getUserList() {
    return _userCollectionRef.snapshots();
  }

  Stream listenToMessages(String groupChatId) {
    _messageCollectionRef
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((messageChatSnapshot) {
      print(messageChatSnapshot.docs);
      if (messageChatSnapshot.docs.isNotEmpty) {
        var message = messageChatSnapshot.docs
            .map((snapshot) => Messages.fromJson(snapshot.data()))
            .where((mappedItem) => mappedItem.content != null)
            .toList();

        print(message);
        _messageUserController.add(message);
      }
    });
    return _messageUserController.stream;
  }
}
