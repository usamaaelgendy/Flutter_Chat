import 'dart:io';

import 'package:chatting_ui_fun/model/messages.dart';
import 'package:chatting_ui_fun/model/users.dart';
import 'package:chatting_ui_fun/ui/widgets/mycircleavatar.dart';
import 'package:chatting_ui_fun/ui/widgets/send_reciever_widgets/receivedmessagewidget.dart';
import 'package:chatting_ui_fun/ui/widgets/send_reciever_widgets/sentmessagewidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class ChatScreen extends StatefulWidget {
  final Users peerUser;
  final String currentUserId;

  ChatScreen({
    Key key,
    @required this.peerUser,
    @required this.currentUserId,
  }) : super(key: key);

  @override
  _ChatScreenViewState createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreen> {
  String peerId, peerAvatar, groupChatId = '';

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  FirebaseAuth _auth = FirebaseAuth.instance;

  // firebase
  CollectionReference _messageCollectionRef =
      FirebaseFirestore.instance.collection('Messages');

  @override
  void initState() {
    super.initState();
    String s = "usama";
    String ss = "usama";
    print(s.hashCode);
    print(ss.hashCode);

    peerId = widget.peerUser.userId;
    peerAvatar = widget.peerUser.profilePic;
    if (peerId.hashCode <= {widget.currentUserId}.hashCode) {
      groupChatId = '$peerId-${widget.currentUserId}';
    } else {
      groupChatId = '${widget.currentUserId}-$peerId';
    }
    focusNode.addListener(onFocusChange);

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyCircleAvatar(
              imgUrl: widget.peerUser.profilePic,
            ),
            SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.peerUser.userName,
                  style: Theme.of(context).textTheme.subtitle1,
                  overflow: TextOverflow.clip,
                ),
                Text(
                  "Online",
                  style: Theme.of(context).textTheme.subtitle1.apply(
                        color: Colors.green,
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.phone),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _messageCollectionRef
                      .doc(groupChatId)
                      .collection(groupChatId)
                      .orderBy('timestamp', descending: true)
                      .limit(20)
                      .snapshots(),

                  // _messageCollectionRef.orderBy('date').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: CircularProgressIndicator(),
                      );

                    List<DocumentSnapshot> docs = snapshot.data.docs;

                    // docs.map((e) => print(e));
                    // List<Widget> messages = docs
                    //     .map((doc) => Messages())
                    //     .toList();
                    List<Messages> messages = docs
                        .map((doc) => Messages(
                              content: doc.data()["content"],
                              idFrom: doc.data()["idFrom"],
                              idTo: doc.data()["idTo"],
                              timestamp: doc.data()["timestamp"],
                              type: doc.data()["type"],
                              time: doc.data()["time"],
                            ))
                        .toList();

                    return ListView.builder(
                      controller: listScrollController,
                      itemBuilder: (context, index) =>
                          buildItem(index, messages[index], messages),
                      itemCount: messages.length,
                      reverse: true,
                      // children: <Widget>[
                      //   ...messages,
                      // ],
                    );
                  },
                ),
              ),
              buildInput(),
              //Sticker
              (isShowSticker ? buildSticker() : Container()),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      FirebaseFirestore.instance
          .collection('UsersChat')
          .doc(widget.currentUserId)
          .update({'chattingWith': null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  Widget buildItem(int index, Messages message, List<Messages> listMessage) {
    if (message.idFrom == widget.currentUserId) {
      return SentMessageWidget(
        message: message,
      );
    } else {
      return ReceivedMessagesWidget(
        user: widget.peerUser,
        message: message,
      );
    }
  }

  bool isLastMessageLeft(int index, List<Messages> listMessage) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].idFrom == widget.currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index, List<Messages> listMessage) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].idFrom != widget.currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildInput() {
    return Container(
      margin: EdgeInsets.all(15.0),
      height: 61,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35.0),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 3), blurRadius: 5, color: Colors.grey)
                ],
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.image),
                    onPressed: getImage,
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: Icon(Icons.face),
                    onPressed: getSticker,
                    color: Colors.blue,
                  ),
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                          hintText: "Type Something...",
                          border: InputBorder.none),
                      focusNode: focusNode,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: Colors.white,
            child: Container(
              padding: EdgeInsets.only(left: 10),
              color: Colors.white,
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: Image.asset(
                  'assets/images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: Image.asset(
                  'assets/images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: Image.asset(
                  'assets/images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: Image.asset(
                  'assets/images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: Image.asset(
                  'assets/images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: Image.asset(
                  'assets/images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: Image.asset(
                  'assets/images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: Image.asset(
                  'assets/images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: Image.asset(
                  'assets/images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const CircularProgressIndicator() : Container(),
    );
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = Firestore.instance
          .collection('Messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': widget.currentUserId,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type,
            'time': DateFormat('dd MMM kk:mm').format(
              DateTime.fromMillisecondsSinceEpoch(
                int.parse(DateTime.now().millisecondsSinceEpoch.toString()),
              ),
            ),
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Toast.show("Nothing to send", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Toast.show("This file is not an image", context);
    });
  }
}
