import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/helper/my_date_util.dart';
import 'package:chatapp/models/message.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../widgets/message_card.dart';
import 'view_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
//for storing all the messages
  List<Message> _list = [];
//for handling text messages changes
  final _textController = TextEditingController();

//for storing value of showing or hiding emojis
//isuploading for checking if the image is uploading or not
  bool _showEmoji = false, _isUploading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if emojis are shown & back button is pressed then hide emojis
          //or else simple close current screen on back button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
              //app bar
              appBar: AppBar(
                //removing back button
                automaticallyImplyLeading: false,
                flexibleSpace: _appBar(),
              ),
              backgroundColor: const Color.fromARGB(255, 234, 248, 255),
              //body
              body: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: APIs.getAllMessages(widget.user),
                      //from where it will take data
                      // stream: APIs.getAllUsers(),
                      builder: (context, snapshot) {
                        //data is loading or have been loading
                        switch (snapshot.connectionState) {
                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const SizedBox();

                          //if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data
                                ?.docs; // question mark agr data null na ho
                            // log('Data : ${jsonEncode(data![0].data())}');
                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];

                            //final _list=[];
                            //_list.clear();
                            //_list.add(Message(told: 'hi', msg: 'sdlf', read: 'read', type: Type.text, fromId: 'xyz', sent: '12am'));
                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  //to shoe the last message first
                                  reverse: true,
                                  itemCount: _list.length,

                                  //adding margin frm the top
                                  padding:
                                      EdgeInsets.only(top: mq.height * .01),

                                  //bouncing on scrolling
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return MessageCard(message: _list[index]);

                                    // return Text('Name : ${_list[index]}');
                                  });
                            } else {
                              return const Center(
                                  child: Text('Say hi',
                                      style: TextStyle(fontSize: 20)));
                            }
                        }
                      },
                    ),
                  ),
                  //if image is uploading then show the progress indicator
                  if (_isUploading)
                    const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: CircularProgressIndicator(strokeWidth: 2))),
                  //chat input field
                  _chatInput(),
                  //import 'package:flutter/foundation.dart' as foundation;

                  //show emogi on keyboard emogi button click & vice versa

                  if (_showEmoji)
                    SizedBox(
                      height: mq.height * .35,
                      child: EmojiPicker(
                        textEditingController: _textController,
                        config: Config(
                          bgColor: const Color.fromARGB(255, 234, 248, 255),
                          columns: 8,

                          emojiSizeMax: 32 *
                              (Platform.isIOS
                                  ? 1.30
                                  : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                        ),
                      ),
                    )
                ],
              )),
        ),
      ),
    );
  }

//app bar widget
  Widget _appBar() {
    return InkWell(
        onTap: () {

          Navigator.push(context,MaterialPageRoute(builder: (_)=> ViewProfileScreen(user : widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;

              final list = data
                      ?.map((e) =>
                          ChatUser.fromJson(e.data() as Map<String, dynamic>))
                      .toList() ??
                  [];

              

              return Row(
                children: [
                  //back button
                  IconButton(
                      onPressed: () {},
                      icon:
                          const Icon(Icons.arrow_back, color: Colors.black54)),

                  //user profile pic
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      width: mq.height * .05,
                      height: mq.height * .05,

                      imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),

                  //for adding some space
                  const SizedBox(width: 10),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(list.isNotEmpty ? list[0].name : widget.user.name,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500)),

                      //for adding some space
                      const SizedBox(height: 2),

                        //last seen time of user
                       Text(list.isNotEmpty ?
                       //if the user is online then show online 
                       list[0].isOnline ? 'Online' : 
                       
                       //
                        MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                        
                        : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54
                              //fontWeight: FontWeight.w500
                              )),
                    ],
                  )
                ],
              );
            }));
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  ///emogi button
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                        size: 25,
                      )),

                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                    },
                    decoration: const InputDecoration(
                        hintText: 'Type Something',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none),
                  )),
                  //take image from gallery
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        //picking multiple images
                        final List<XFile>? images =
                            await picker.pickMultiImage(imageQuality: 70);
                        //uploading and sending image one by one
                        for (var i in images!) {
                          setState(() => _isUploading = true);
                          await APIs.sentChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.image,
                          color: Colors.blueAccent, size: 26)),

                  //take image from camera
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          setState(() => _isUploading = true);
                          await APIs.sentChatImage(
                              widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Colors.blueAccent, size: 26)),

                  //adding some space
                  SizedBox(width: mq.width * .02)
                ],
              ),
            ),
          ),

          //send message button
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text, Type.text);
                _textController.text = '';
              }
            },
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            color: Colors.green,
            child: Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }
}
