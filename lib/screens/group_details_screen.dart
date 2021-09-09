import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

final _firestore = FirebaseFirestore.instance;
var owner;
User loggedInUser;

class GroupDetailsScreen extends StatefulWidget {
  GroupDetailsScreen(this.groupData);

  static const String id = 'group_details_screen';

  final groupData;

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  var groupData;

  void initState() {
    groupData = widget.groupData;
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

  bool isOwner() {
    if (loggedInUser.email == owner) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, ChatScreen.id, (route) => false,
                arguments: groupData);
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, WelcomeScreen.id, (route) => false);
              }),
        ],
        title: Text('⚡️Details - ${groupData[1]}'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Group Owner: $owner',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Group Members:',
              style: TextStyle(
                fontSize: 25.0,
              ),
            ),
          ),
          MemberListStream(groupData),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: FloatingActionButton(
              child: Icon(
                Icons.add,
                color:
                    (loggedInUser == groupData[2]) ? Colors.white : Colors.grey,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class MemberListStream extends StatelessWidget {
  MemberListStream(this.groupData);
  final groupData;
  bool isOwner() {
    if (loggedInUser.email == owner) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('groups').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final groups = snapshot.data.docs;
        var memberEmails;
        for (var group in groups) {
          final data = Map<dynamic, dynamic>.from(group.data());
          if (groupData[0] == data['groupID']) {
            memberEmails = data['user_emails'];
            owner = data['created_by'];
            break;
          }
        }
        List<Widget> memberBoxes = [];
        List<Widget> rowMembers = [];
        for (var email in memberEmails) {
          var rowMember1 = Text(
            email.toString(),
            style: TextStyle(
              color: Colors.white,
            ),
          );
          rowMembers.add(rowMember1);
          var rowMember2;
          rowMember2 = Icon(
            Icons.info,
            color: isOwner() ? CupertinoColors.white : Colors.grey,
          );
          rowMembers.add(rowMember2);

          var memberBox = Container(
            margin: EdgeInsets.all(5.0),
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
            color: Colors.lightBlueAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [rowMember1, rowMember2],
            ),
          );
          memberBoxes.add(memberBox);
        }

        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2.0),
            children: memberBoxes,
          ),
        );
      },
    );
  }
}
