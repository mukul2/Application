import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_tv/series_like_home/home.dart';
import 'package:flutter_app_tv/ui/auth/auth.dart';
import 'package:flutter_app_tv/ui/channel/channel_as_home.dart';
import 'package:flutter_app_tv/ui/channel/channel_detail.dart';
import 'package:flutter_app_tv/ui/channel/channels.dart';
import 'package:flutter_app_tv/ui/comment/comment_add.dart';
import 'package:flutter_app_tv/ui/comment/comments.dart';
import 'package:flutter_app_tv/ui/home/home.dart';
import 'package:flutter_app_tv/key_code.dart';
import 'package:flutter_app_tv/ui/auth/login.dart';
import 'package:flutter_app_tv/ui/movie/movie.dart';
import 'package:flutter_app_tv/ui/movie/movies.dart';
import 'package:flutter_app_tv/ui/pages/privacy.dart';
import 'package:flutter_app_tv/ui/review/review_add.dart';
import 'package:flutter_app_tv/ui/review/reviews.dart';
import 'package:flutter_app_tv/ui/serie/serie.dart';
import 'package:flutter_app_tv/ui/serie/series.dart';
import 'package:flutter_app_tv/ui/setting/settings.dart';
import 'package:flutter_app_tv/ui/pages/splash.dart';
import 'package:wakelock/wakelock.dart';
import 'EPG/epg.dart';
import 'SlingTv/sling_tv_activity.dart';
import 'ui/player/video_player.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';




void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Wakelock.enable();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    FocusNode focusNode = FocusNode();
    List<String>sTitles = ["English","Bengali"];
    ThemeData td =  ThemeData(fontFamily: "Poppins",primaryColor: Colors.redAccent,  primarySwatch: Colors.red,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: Colors.black,);

     MaterialApp(home:RawKeyboardListener(
      focusNode: focusNode,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
          RawKeyDownEvent rawKeyDownEvent = event;
          RawKeyEventDataAndroid rawKeyEventDataAndroid =rawKeyDownEvent.data as RawKeyEventDataAndroid;
          //print(rawKeyEventDataAndroid.keyCode);
          switch (rawKeyEventDataAndroid.keyCode) {


            case KEY_CENTER:

              break;
            case KEY_UP:




              break;
            case KEY_DOWN:

              break;
            case KEY_LEFT:

              break;
            case KEY_RIGHT:

              break;
            default:
              break;
          }


        }
      },
      child:Scaffold(backgroundColor: Colors.black,
        body: Column(
          children: [
            MyCustomWidget(data: 'name',gotfocused: (val){
              print(val);
            },),
            MyCustomWidget(data: 'name 2',gotfocused: (val){
              print(val);
            },),
          ],
        ),
      ),
    ) ,);

     Shortcuts(shortcuts: <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
    }, child: MaterialApp(
        title: 'SFlix',debugShowCheckedModeBanner: false,
        home: WillPopScope(
          onWillPop: () async{


            return true;
          },
          child:  true?Scaffold(backgroundColor: Colors.black,
            body: Column(
              children: [
                   MyCustomWidget(data: 'name',gotfocused: (val){
                  print(val);
                },),
                  MyCustomWidget(data: 'name 2',gotfocused: (val){
                  print(val);
                },),
              ],
            ),
          ): SlingTv(),
        )
    ));
    return Shortcuts(shortcuts: <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
    }, child:  MaterialApp(theme: td,
      debugShowCheckedModeBanner: false,

    //  home: EpgActivity(),
       home: Home(),
      //home:TvChannelsHome() ,
      routes: {
        "/splash": (context) => Splash(),
        "/home": (context) => Home(),
        "/movie": (context) => Movie(),
        "/serie": (context) => Serie(),
        "/channel_detail": (context) => ChannelDetail(),
        "/channels": (context) => TvChannelsHome(),
        "/movies": (context) => Movies(),
        "/series": (context) => SeriesAsHome(),
        "/reviews": (context) => Reviews(id: 1, image: "image", title: 'title', type: "type"),
        "/review_add": (context) => ReviewAdd(type: "", id: 1, image: 'image'),
        "/comments": (context) => Comments(),
        "/comment_add": (context) => CommentAdd(image: "", id: 1,type: ""),
        "/login": (context) => Login(),
        "/video_player": (context) => VideoPlayer(focused_source: 0),
      },
    ));

    return
           MaterialApp(theme: td,
             debugShowCheckedModeBanner: false,

             //home: EpgActivity(),
            // home: SlingTv(),
             home:Home() ,
            routes: {
              "/splash": (context) => Splash(),
              "/home": (context) => Home(),
              "/movie": (context) => Movie(),
              "/serie": (context) => Serie(),
              "/channel_detail": (context) => ChannelDetail(),
              "/channels": (context) => Channels(),
              "/movies": (context) => Movies(),
              "/series": (context) => SeriesAsHome(),
              "/reviews": (context) => Reviews(id: 1, image: "image", title: 'title', type: "type"),
              "/review_add": (context) => ReviewAdd(type: "", id: 1, image: 'image'),
              "/comments": (context) => Comments(),
              "/comment_add": (context) => CommentAdd(image: "", id: 1,type: ""),
              "/login": (context) => Login(),
              "/video_player": (context) => VideoPlayer(focused_source: 0),
            },
          );
  }




}


class MyCustomWidget extends StatefulWidget {
  String data ;
  Function(bool) gotfocused;
  String? logo;
  MyCustomWidget({required this.data,required this.gotfocused,this.logo});


  @override
  State<MyCustomWidget> createState() => _MyCustomWidgetState();
}

class _MyCustomWidgetState extends State<MyCustomWidget> {
  Color _color = Colors.grey;
  String _label = 'Unfocused';

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (bool focused) {
        setState(() {
          _color = focused ? Colors.white : Colors.grey;
          _label = focused ? 'Focused' : 'Unfocused';
        });
        widget.gotfocused(focused);
      },
      child: InkWell(onTap: (){
        print("clicked ");
      },
        child: Padding(
          padding:  EdgeInsets.all(MediaQuery.of(context).size.longestSide*0.004),
          child: Center(
            child: AnimatedContainer(duration: Duration(milliseconds: 200),decoration: BoxDecoration( color: _color,borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.0015)),
              // width:_label=='Focused'?MediaQuery.of(context).size.width*0.30: MediaQuery.of(context).size.width*0.23,
              // height:_label=='Focused'?MediaQuery.of(context).size.width*0.30: MediaQuery.of(context).size.width*0.23,
              height: _label=='Focused'?MediaQuery.of(context).size.width*0.03: MediaQuery.of(context).size.width*0.025,
              alignment: Alignment.center,

              child: (widget.logo!=null)? Row(
                children: [

                  if(widget.logo!=null) Padding(
                    padding:  EdgeInsets.all(MediaQuery.of(context).size.height*0.004),
                    child: Image.network(widget.logo!),
                  ),

                  Center(child: Text(widget.data,style: TextStyle(fontSize:MediaQuery.of(context).size.height*0.03),)),
                ],
              ) :Center(child: Text(widget.data,style: TextStyle(fontSize:MediaQuery.of(context).size.height*0.03),)),
            ),
          ),
        ),
      ),
    );
  }
}