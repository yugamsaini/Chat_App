import 'package:chatapp/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      //setting the margin of the user message bar from left side and top
      margin:EdgeInsets.symmetric(horizontal: mq.width*.04,vertical:4),

      //color of the user message bar
      //color: Colors.blue.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      //setting up the user messages bar
      child: InkWell(
        onTap:(){},
        child: const ListTile(
          //setting the user icon
          leading: CircleAvatar(child:Icon(CupertinoIcons.person)),
          title:Text('Demo User'),
        subtitle: Text('Last User message',maxLines: 1),
        //the time of the last message
        trailing: Text('12:00 PM',
        style: TextStyle(color:Colors.black54),
        ),


        ),  
      ),
    );
  }
}