import 'package:chatting_ui_fun/database/database_services.dart';
import 'package:chatting_ui_fun/model/users.dart';
import 'package:chatting_ui_fun/provider/user_auth_provider.dart';
import 'package:chatting_ui_fun/ui/pages/auth/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserAuthProvider>(context);
    DatabaseServices databaseServices = DatabaseServices();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 8,
        title: Text(
          'Contacts',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          child: RaisedButton(
            onPressed: () {
              user.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) {
                  return WelcomeScreen();
                }),
              );
            },
            child: Text("Logout"),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: databaseServices.getUserList(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => _buildItem(
                context,
                user.user.uid,
                snapshot.data.documents[index],
              ),
              itemCount: snapshot.data.documents.length,
            );
          }
        },
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, String currentUserId, DocumentSnapshot snapshot) {
    if (snapshot.data()['userId'] == currentUserId) {
      return Container();
    } else {
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              peerUser: Users.fromJson(snapshot.data()),
              currentUserId: currentUserId,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(2),
                decoration:
                    // chat.unread
                    // ? BoxDecoration(
                    //     borderRadius: BorderRadius.all(Radius.circular(40)),
                    //     border: Border.all(
                    //       width: 2,
                    //       color: Theme.of(context).primaryColor,
                    //     ),
                    //     // shape: BoxShape.circle,
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.grey.withOpacity(0.5),
                    //         spreadRadius: 2,
                    //         blurRadius: 5,
                    //       ),
                    //     ],
                    //   )
                    // :
                    BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(snapshot.data()['profilePic'] !=
                          null
                      ? snapshot.data()['profilePic']
                      : "https://static.toiimg.com/thumb/72975551.cms?width=680&height=512&imgsize=881753"),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.65,
                padding: EdgeInsets.only(
                  left: 20,
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              snapshot.data()['userName'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // chat.sender.isOnline
                            //     ?
                            Container(
                              margin: const EdgeInsets.only(left: 5),
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            // : Container(
                            //     child: null,
                            //   ),
                          ],
                        ),
                        Text(
                          "4 : 10",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        snapshot.data()['isOnline'] == true
                            ? "Online"
                            : "Offline",
                        style: TextStyle(
                          fontSize: 13,
                          color: snapshot.data()['isOnline'] == true
                              ? Colors.green
                              : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
