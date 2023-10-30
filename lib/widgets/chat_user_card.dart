import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/helper/my_date_util.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:chatapp/models/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

//last message info (id null --> no messages came)
  Message? _message;
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
        onTap:(){
          //for navigating to chat screen
          Navigator.push(
            context,MaterialPageRoute(builder: (_)=>ChatScreen(user : widget.user)));

        },
        child: StreamBuilder(
          stream : APIs.getLastMessage(widget.user),
          builder: (context,snapshot){
            
            final data =
                        snapshot.data?.docs; 
            
                     final list = 
                     data?.map((e) => Message.fromJson(e.data() as Map<String, dynamic>)).toList() ?? [];
                   
                   if(list.isNotEmpty) _message = list[0];
          return ListTile(
          //setting the user icon
          
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height*.3),
            child: CachedNetworkImage(
            
              width:mq.height*.055,
              height:mq.height*.055,
          
                  imageUrl: widget.user.image,
                 // placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const CircleAvatar(child:Icon(CupertinoIcons.person)),
               ),
          ),
          //user name
          title:Text(widget.user.name),

          //last message
        subtitle: Text(_message != null ? _message!.msg : widget.user.about,maxLines: 1),

        //the time of the last message
        trailing: _message == null ? null : //show nothing if no message is sent
        _message!.read.isEmpty &&
        _message!.fromId != APIs.user.uid
        ?
        //show for the unread message
         Container(width: 15,
         height: 15,
         decoration: BoxDecoration(color: Colors.greenAccent.shade400, borderRadius: BorderRadius.circular(10)),
         ) : 
         //message sent time
        Text(
          MyDateUtil.getLastMessageTime(context: context,time:_message!.sent),
          style: const TextStyle(color:Colors.black54)),

        // trailing: Text('12:00 PM',
        // style: TextStyle(color:Colors.black54),
        // ),


        );
        },)
      ),
    );
  }
}