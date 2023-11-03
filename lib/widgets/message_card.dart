import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/helper/my_date_util.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {

  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {

    ///variable for the curr user if the user himself sending the message then showt he 
    ///green tick else show the  blue tick
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        return _showBottomSheet(isMe);
      },
      child : isMe ? _greenMessage()
    : _blueMessage());
  }

  //sender or another user messages
  Widget _blueMessage(){

    //update last read message if sender and receiver are different
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
      log('message read updated');
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width * 0.03 : mq.width * .04),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width*.04,vertical: mq.height *.01
            ),
            decoration: BoxDecoration(
              color:const Color.fromARGB(255, 221, 245, 255),
            border:Border.all(color:Colors.lightBlue),
        
            //making border curve
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight:Radius.circular(30),
              bottomRight: Radius.circular(30)
              )),
            child:
            widget.message.type == Type.text ?
            //show text
            Text(widget.message.msg,

            style: const TextStyle(fontSize: 15,color:Colors.black87),
            ) :  
            ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
       
              imageUrl: widget.message.msg,
              placeholder: (context,url)=>
            const Padding(
               padding: const EdgeInsets.all(8.0),
               child: const CircularProgressIndicator(strokeWidth: 2),
             ),
              
              // placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.image,size : 70),
            ),
          ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(right:mq.width*.04),
          child: Text(
         MyDateUtil.getFormattedTime(
          context: context, time: widget.message.sent),

            style:const TextStyle(fontSize: 13,color: Colors.black54),
          ),
        ),

        //adding some space
       // SizedBox(width: mq.width*.04)
      ],
    );
  }

  //ourself or user message
  Widget _greenMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message time
        Row(
          children: [
            //adding some space
            SizedBox(width: mq.width*.04),

            //double tic blue icon for message read
            if(widget.message.read.isNotEmpty)

            const Icon(
              Icons.done_all_rounded,
              color:Colors.blue,
              size: 20
            ),
            //for adding some space
            SizedBox(width:2),

            //sent time
            Text(
              //widget.message.sent,
              MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style:const TextStyle(fontSize: 13,color: Colors.black54),
            ),
          ],
        ),
        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width * .03 : mq.width * .04),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width*.04,vertical: mq.height *.01
            ),
            decoration: BoxDecoration(
              color:const Color.fromARGB(255, 218, 255, 176),
            border:Border.all(color:Colors.lightGreen),
        
            //making border curve
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight:Radius.circular(30),
              bottomLeft: Radius.circular(30)
              )),
            child:widget.message.type == Type.text ?
            //show text
            Text(widget.message.msg,

            style: const TextStyle(fontSize: 15,color:Colors.black87),
            ) :  
            //show image
            ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
       
              imageUrl: widget.message.msg,
              placeholder: (context,url)=>
            const Padding(
               padding: const EdgeInsets.all(8.0),
               child: const CircularProgressIndicator(strokeWidth: 2),
             ),
              
              // placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.image,size : 70),
            ),
          ),
          ),
        ),


        //  Flexible(
        //   child: Container(
        //     padding: EdgeInsets.all(mq.width * .04),
        //     margin: EdgeInsets.symmetric(
        //       horizontal: mq.width*.04,vertical: mq.height *.01
        //     ),
        //     decoration: BoxDecoration(
        //       color:const Color.fromARGB(255, 218, 255, 176),
        //     border:Border.all(color:Colors.lightGreen),
        
        //     //making border curve
        //     borderRadius: BorderRadius.only(
        //       topLeft: Radius.circular(30),
        //       topRight:Radius.circular(30),
        //       bottomLeft: Radius.circular(30)
        //       )),
        //     child:Text(widget.message.msg,
        //     style: const TextStyle(fontSize: 15,color:Colors.black87),
        //     ),
        //   ),
        // ),

        //adding some space
       // SizedBox(width: mq.width*.04)
      ],
    );
  }

//bottom sheet for modifying user messages and the show the status of the read message
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            
            children: [
              Container(
                height: 4,
                margin : EdgeInsets.symmetric(
                  vertical: mq.height * 0.015, horizontal: mq.width * .4
                ),
                decoration: BoxDecoration(color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
                ),
              ),

              //if the tapped item is text then show the edit option other wise
              //show the save option
              widget.message.type == Type.text
              ?
              //copy text
             _OptionItem(icon: const Icon(Icons.copy_all_rounded,color: Colors.blue,size:26), name: 'Copy Text: ', onTap: (){})
             :
             //save item
               _OptionItem(icon: const Icon(Icons.download_rounded,color: Colors.blue,size:26), name: 'Save Image: ', onTap: (){}),

             //separator between the option item
             if(isMe)
             Divider(
              color : Colors.black54,
              endIndent: mq.width * 0.04,
              indent: mq.width * .04,

             ),
             //if the tapped item is text thenshow only the edit button
             if(widget.message.type == Type.text && isMe)
             //edit option
             _OptionItem(icon: Icon(Icons.edit,color: Colors.blue,size:26), name: 'Edit Message: ', onTap: (){}),
             //Delete option
             if(isMe)
             _OptionItem(icon: Icon(Icons.delete_forever,color: Colors.red,size:26), name: 'Delete Message: ', onTap: (){}),
              
              Divider(
              color : Colors.black54,
              endIndent: mq.width * 0.04,
              indent: mq.width * .04,

             ),

             //Sent At
             _OptionItem(icon: Icon(Icons.remove_red_eye,color: Colors.blue), name: 'Sent At: ', onTap: (){}),
             //message read time
             _OptionItem(icon: Icon(Icons.remove_red_eye,color: Colors.green), name: 'Read At: ', onTap: (){})



            ],
          );
        });
  }
}

class _OptionItem extends StatelessWidget {
  //for the bottom sheet diaog 
  //we will show the icon and the edit message button
  final Icon icon;
  final String name;

  //this also will be given by the user
  final VoidCallback onTap;

  const _OptionItem({required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
        
       child : Padding(
         padding: EdgeInsets.only(
          left: mq.width * .05,
          top: mq.height * .015,
          bottom : mq.height * .015,
         ),
         child: Row(children: [icon, Flexible(
          child: Text('    $name',style : TextStyle(fontSize: 15,color : Colors.black54,letterSpacing: 0.5)))]),
       )
    );
  }
}