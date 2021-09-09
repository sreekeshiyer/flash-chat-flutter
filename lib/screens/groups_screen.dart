import 'dart:math';

import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class GroupScreen extends StatefulWidget {
  static const String id = 'group_screen';
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;
  String messageTime;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  String getSnapshotData() {
    var snapshots =
        _firestore.collection('groups').orderBy('timestamp').snapshots();
    return (snapshots.toString());
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Create a Group'),
            content: Container(
              decoration: kMessageContainerDecoration,
              child: TextField(
                controller: messageTextController,
                onChanged: (value) {
                  messageText = value;
                },
                decoration: kMessageTextFieldDecoration.copyWith(
                  hintText: 'Create new Group',
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancel',
                  style: kSendButtonTextStyle.copyWith(
                    color: Colors.red,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                onPressed: () {
                  List list1 = [];
                  var groupID = Random().nextInt(1000) + 1;
                  list1.add(groupID);
                  list1.add(messageText);
                  list1.add(loggedInUser.email);
                  List list2 = [];
                  list2.add(loggedInUser.email);

                  messageTextController.clear();
                  _firestore.collection('groups').add({
                    'groupID': groupID,
                    'name': messageText,
                    'user_emails': list2,
                    'timestamp': FieldValue.serverTimestamp(),
                    'created_by': loggedInUser.email,
                  });

                  Navigator.pushNamed(context, ChatScreen.id, arguments: list1);
                },
                child: Text(
                  'Create',
                  style: kSendButtonTextStyle,
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _auth.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, WelcomeScreen.id, (route) => false);
              }),
        ],
        title: Text('⚡️Groups'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GroupStream(),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: FloatingActionButton(
                child: Icon(Icons.add),
                backgroundColor: Colors.blue,
                hoverColor: Colors.blueAccent,
                onPressed: () {
                  _displayTextInputDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('groups').orderBy('timestamp').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final groups = snapshot.data.docs;
        List<GroupBox> groupBoxes = [];
        for (var group in groups) {
          final data = Map<dynamic, dynamic>.from(group.data());
          final groupName = data['name'];
          final currentUser = loggedInUser.email;

          var groupID = data['groupID'];
          var owner = data['created_by'];

          var groupData = [];
          groupData.add(groupID);
          groupData.add(groupName);
          groupData.add(owner);

          final userEmails = data['user_emails'];
          // ignore: unused_local_variable

          for (var user in userEmails) {
            if (user == loggedInUser.email) {
              final groupBox = GroupBox(
                currentUser: currentUser,
                data: groupData,
              );
              groupBoxes.add(groupBox);
            }
          }
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5.0),
            children: groupBoxes,
          ),
        );
      },
    );
  }
}

class GroupBox extends StatelessWidget {
  GroupBox({this.currentUser, this.data});

  final String currentUser;
  final List data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: TextButton(
        child: Text(
          data[1],
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(context, ChatScreen.id, arguments: data);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
        ),
      ),
    );
  }
}

// Row(
// crossAxisAlignment: CrossAxisAlignment.center,
// children: <Widget>[
// Expanded(
// child: TextField(
// controller: messageTextController,
// onChanged: (value) {
// messageText = value;
// },
// decoration: kMessageTextFieldDecoration.copyWith(
// hintText: 'Create new Group',
// ),
// ),
// ),
// TextButton(
// onPressed: () {
// List list1 = [];
// var groupID = Random().nextInt(1000) + 1;
// list1.add(groupID);
// list1.add(messageText);
// List list2 = [];
// list2.add(loggedInUser.email);
//
// messageTextController.clear();
// _firestore.collection('groups').add({
// 'groupID': groupID,
// 'name': messageText,
// 'user_emails': list2,
// 'timestamp': FieldValue.serverTimestamp(),
// });
//
// Navigator.pushNamed(context, ChatScreen.id,
// arguments: list1);
// },
// child: Text(
// 'Create',
// style: kSendButtonTextStyle,
// ),
// ),
// ],
// ),
