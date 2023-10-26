import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;


  const ChatUserCard({super.key, required this.user});

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
        child: ListTile(
          //setting the user icon
          //leading: const CircleAvatar(child:Icon(CupertinoIcons.person)),
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
          title:Text(widget.user.name),
        subtitle: Text(widget.user.about,maxLines: 1),
        //the time of the last message
        trailing: Container(width: 15,
         height: 15,
         decoration: BoxDecoration(color: Colors.greenAccent.shade400, borderRadius: BorderRadius.circular(10)),
         )
        

        // trailing: Text('12:00 PM',
        // style: TextStyle(color:Colors.black54),
        // ),


        ),  
      ),
    );
  }
}