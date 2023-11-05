
import 'package:chatapp/api/apis.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/screens/profile_screen.dart';
//import 'package:chatapp/widgets/chat_user_card.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helper/dialogs.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];

  //for storing search items
  final List<ChatUser> _searchList = [];
//for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();



     //for updating user active status according to lifecyle events
     //resume means that active or online
     //pause means that inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message){
     // log('Message : $message');

     if (APIs.auth.currentUser != null) {
     if(message.toString().contains('resume')) {
      
      APIs.updateActiveStatus(true);
     }
     if(message.toString().contains('pause')) {
      
      APIs.updateActiveStatus(false);
     }
   //  if(message.toString().contains('pause')) APIs.updateActiveStatus(false);
     }
        return Future.value(message);
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding the keyboard  when a tap is detected on the screen
      onTap:()=> FocusScope.of(context).unfocus(),
      child: WillPopScope(
        ///if search is on & back button is pressed then close search
        ///or else close the current screen on back button click
        onWillPop: () {
          if(_isSearching){
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          }else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            title: _isSearching ? 
            TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Name, Email, ...' ) ,
                autofocus: true,
                style: TextStyle(fontSize: 16,letterSpacing: 0.5),
                //after search the text update the search list
                onChanged: (val){
                  //search logic
                  _searchList.clear();
          
                  for(var i in _list){
                    if(i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase())){
                      _searchList.add(i);
                    
                    setState(() {
                      _searchList;
                    });
                  }
                  }
                },
              
            ) : const Text('We Chat'),
            actions: [
              //search user button
              IconButton(onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              }, icon: Icon(_isSearching 
              ? CupertinoIcons.clear_circled_solid
              : Icons.search)),


              //more feature button :
              IconButton(onPressed: () {
          
                Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfileScreen(user: APIs.me)));
              }, icon: const Icon(Icons.more_vert))
            ],
          ),
          
          //bottom right corner flaoting button to add the new user
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              //BUTTON TO ADD NEW USER
                onPressed: () async {
                  _addChatUserDialog();
                  // await APIs.auth.signOut();
                  // await GoogleSignIn().signOut();
                 // _addChatUserDialog();
                },
                child: const Icon(Icons.add_comment_rounded)),
          ),
          
          //stream builder dynamically add the data
          body: StreamBuilder(
             stream : APIs.getMyUsersId(),
            builder : (context,snapshot){
             
             
            if(snapshot.hasData){
              StreamBuilder(
            //from where it will take data
            stream: APIs.getAllUsers(
                      snapshot.data?.docs.map((e)=> e.id).toList()??[]
                      
            ),
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
                  _list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
          
                  if(_list.isNotEmpty){
                    return ListView.builder(
                      itemCount: _isSearching ? _searchList.length : _list.length,
          
                      //adding margin frm the top
                      padding: EdgeInsets.only(top: mq.height * .01),
          
                      //bouncing on scrolling
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ChatUserCard(
                          user: _isSearching ? _searchList[index] : _list[index]);
          
                       // return Text('Name : ${_list[index]}');
                      });
                  } else {
                    return const Center(child: Text('No Connection Found!', style: TextStyle(fontSize: 20)));
                  }
              }
            },
          );
            }
            return Center(child: CircularProgressIndicator(strokeWidth: 2));
          },),
        ),
      ),
    );
  }

  
  //dialog for updating the message content
  void _addChatUserDialog() {
    String email = '';

    showDialog(context: context, builder: (_)=>AlertDialog(
      contentPadding: EdgeInsets.only(left: 24,right: 24,top: 20,bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //title
      title:Row(children: const [Icon(Icons.person_add,color:Colors.blue,size:28),
      Text('  Add User')
      ],
      ),
      //content
      content: TextFormField(
      maxLines: null,
      onChanged: (value) => email=value,
      decoration: InputDecoration(
        hintText: 'Email Id',
        prefixIcon: Icon(Icons.email,color: Colors.blue),
        border : OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      ),

      //actions
      actions: [
        //cancel button
        MaterialButton(onPressed: (){
          //hide alert dialog
          Navigator.pop(context);
        },child:Text('Cancel',
        style: TextStyle(color:Colors.blue,fontSize: 16),
        )),

//add user button
        MaterialButton(onPressed: () async {
          //hide alert dialog
          Navigator.pop(context);
          if(email.isNotEmpty){
          await APIs.addChatUser(email).then((value) {
            if(!value){
              Dialogs.showSnackbar(
                context,'User does not Exists!'
              );
            }
          });
          }
        },child:Text('Add',
        style: TextStyle(color:Colors.blue,fontSize: 16),
        ))
      ],
    ));
  }
}
