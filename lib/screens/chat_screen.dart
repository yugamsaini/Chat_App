import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/models/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
   final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

//for storing all the messages
  List<Message> _list=[];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
    //app bar
        appBar: AppBar(
          //removing back button
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),

backgroundColor: const Color.fromARGB(255, 234, 248, 255),
        //body
        body:Column(children: [
          
          Expanded(
            child: StreamBuilder(
              stream: APIs.getAllMessages(),
              //from where it will take data
             // stream: APIs.getAllUsers(),
              builder: (context, snapshot) {
                //data is loading or have been loading
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());
            
                  //if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data =
                        snapshot.data?.docs; // question mark agr data null na ho
                        log('Data : ${jsonEncode(data![0].data())}');
                    // _list =
                    //     data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
            
            //final _list=[];
            _list.clear();
            _list.add(Message(told: 'hi', msg: 'sdlf', read: 'read', type: Type.text, fromId: 'xyz', sent: '12am'));
                    if(_list.isNotEmpty){
                      return ListView.builder(
                        itemCount : _list.length,
            
                        //adding margin frm the top
                        padding: EdgeInsets.only(top: mq.height * .01),
            
                        //bouncing on scrolling
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return MessageCard(message: _list[index]);
            
                         // return Text('Name : ${_list[index]}');
                        });
                    } else {
                      return const Center(child: Text('Say hi', style: TextStyle(fontSize: 20)));
                    }
                }
              }, 
            ),
          ),
          _chatInput()],
        
        )
      ),
    );
  }

  Widget _appBar(){

    return InkWell(
      onTap: ()=> Navigator.pop(context),
      child: Row(children: [
        //back button
        IconButton(
          onPressed: (){}, 
          icon: const Icon(
            Icons.arrow_back,
            color:Colors.black54
            )),
    
    //user profile pic
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height*.3),
              child: CachedNetworkImage(
            
                width:mq.height*.05,
                height:mq.height*.05,
            
                    imageUrl: widget.user.image,
                   // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const CircleAvatar(child:Icon(CupertinoIcons.person)),
                 ),
            ),
    
    //for adding some space
        const SizedBox(width: 10),
    
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(widget.user.name,style: const TextStyle(fontSize:16,color: Colors.black87,
            fontWeight: FontWeight.w500
            )),
    
    
    //for adding some space
    const SizedBox(height: 2),
    
            const Text('Last seen not available',
            style: const TextStyle(
              fontSize:13,color: Colors.black54
            //fontWeight: FontWeight.w500
            )),
            
            ],)
      ],),
    );
  } 

  Widget _chatInput(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: mq.height*.01,
      horizontal: mq.width * .025
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(children: [
            ///emogi button
                 IconButton(
                    onPressed: (){},
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color:Colors.blueAccent,
                      size: 25,
                      )),
            
             const Expanded(child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(hintText: 'Type Something',
                hintStyle: TextStyle(color: Colors.blueAccent),
                border:InputBorder.none),
              )),
            //take image from gallery
                      IconButton(
                    onPressed: (){},
                    icon: const Icon(
                      Icons.image,
                      color:Colors.blueAccent,
                      size: 26
                      )),
            
            //take image from camera
                      IconButton(
                    onPressed: (){},
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color:Colors.blueAccent,
                      size: 26
                      )),

                      //adding some space
                      SizedBox(width:mq.width * .02)
              ],),
            ),
          ),
    
          //send message button
          MaterialButton(onPressed: (){},
          minWidth: 0,
          padding:EdgeInsets.only(top:10,bottom: 10,right:5,left:10),
          shape: CircleBorder(),
          color:Colors.green ,
          child:Icon(Icons.send,color: Colors.white,size: 28),)
        ],
      ),
    );
  }
}