// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fire;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_tv/api/api_rest.dart';
import 'package:flutter_app_tv/model/channel.dart';
import 'package:flutter_app_tv/model/episode.dart';
import 'package:flutter_app_tv/model/season.dart';
import 'package:flutter_app_tv/ui/dialogs/subscribe_dialog.dart';
import 'package:flutter_app_tv/ui/dialogs/subtitles_dialog.dart' as ui;
import 'package:flutter_app_tv/model/subtitle.dart' as model;
import 'package:flutter_app_tv/ui/dialogs/sources_dialog.dart' as ui;
import 'package:flutter_app_tv/model/poster.dart';
import 'package:flutter_app_tv/model/source.dart';
import 'package:flutter_app_tv/model/subtitle.dart';
import 'package:flutter_app_tv/ui/setting/settings.dart';
import 'package:flutter_app_tv/ui/player/video_controller_widget.dart' as ui;
import 'package:flutter_app_tv/ui/home/home.dart';
import 'package:flutter_app_tv/key_code.dart';
import 'package:flutter_app_tv/ui/player/subtitle_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert' as convert;

import 'package:url_launcher/url_launcher.dart';

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.


class VideoPlayer extends StatefulWidget {

  List<Source>? sourcesList = [];
  List<Source>? sourcesListDialog = [];
  Poster? poster;
  Channel? channel;
  int? episode;
  int? season;


  int? next_episode;
  int? next_season;
  String? next_title ="";

  List<Season>? seasons = [];
  int? selected_source =0;
  int focused_source =0;
  bool? next = false ;
  bool? live = false ;
  bool? _play_next_episode = true ;

  List<model.Subtitle>? subtitles ;
  int? selected_subtitle ;

  VideoPlayer({this.subtitles ,this.selected_subtitle,this.sourcesList,  this.selected_source,required this.focused_source, this.poster,this.episode,this.seasons,this.season,this.channel});

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer>   with SingleTickerProviderStateMixin{

  List<Color> _list_text_bg = [
    Colors.transparent,
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.brown,
    Colors.purple,
    Colors.pink,
    Colors.teal
  ];
  List<Color> _list_text_color = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.brown,
    Colors.purple,
    Colors.pink,
    Colors.teal
  ];
   BetterPlayerController? _betterPlayerController;

   AnimationController? _animated_controller;
   ItemScrollController _subtitlesScrollController = ItemScrollController();
   ItemScrollController _sourcesScrollController = ItemScrollController();

   bool _visibile_controllers= true;
   bool _visibile_subtitles_dialog= false;
   bool visibileSourcesDialog= false;
   bool _visibile_subtitles_loading= true;

   Timer? _visibile_controllers_future;

   FocusNode video_player_focus_node = FocusNode();


   int _selected_subtitle= 0;
   int _focused_subtitle= 0;



   int  _video_controller_play_position = 0;
   int  _video_controller_slider_position = 1;
   int  _video_controller_settings_position = 2;
  bool visible_subscribe_dialog = false;

  // List<model.Subtitle> _subtitlesList = [];

   int post_x= 0;
   int post_y= 0;
   double _slider_video_value= 0;

   bool isPlaying = true;

  SharedPreferences? prefs;

   bool? _subtitle_enabled =true;
   int? _subtitle_size =11;
   int? _subtitle_color =0;
   int? _subtitle_background =0;
  bool? logged =false;
  String? subscribed = "FALSE";

  String? nowWorkingSubtitle = "";

   @override
  void initState() {
  if(widget.selected_subtitle!=null)   _selected_subtitle = widget.selected_subtitle!;
  if(widget.selected_subtitle!=null)  _focused_subtitle = widget.selected_subtitle!;
     try{
       print(widget.channel!.sources.first.url);
       print(widget.poster!.sources.first.url);
     }catch(e){

     }

     try{

     }catch(e){

     }

    // print("selected subtitle index "+widget.selected_subtitle!.toString());


    Future.delayed(Duration.zero, () async {

      String initFileName = "";

      if(widget.subtitles!.length>0 && widget.selected_subtitle!>0){
        initFileName =  (widget.subtitles![ widget.selected_subtitle!].file_id).toString() ;

       var value = await  fire.FirebaseFirestore.instance.collection("subtitlesByFileId").doc(initFileName).get();

        if(value.exists){

          print("subtitle was previously available");

          String linkStorage = value.get("storage");

          nowWorkingSubtitle = linkStorage;


        }else{

          print("need to download and cache subtitle ");
          //search and get subtitle from opensubtitles and cache and use

          String link = await  apiRest.downloadubtitles(fileName: widget.subtitles![ widget.selected_subtitle!].file_name!, fileId: widget.subtitles![ widget.selected_subtitle!].file_id.toString(), lang: widget.subtitles![ widget.selected_subtitle!].language);


          nowWorkingSubtitle = link;

          print("just downloaded subtitle "+nowWorkingSubtitle!);

        }

      }else{
        //run no subtitle


      }


      print("running with no subtitle");
      print(widget.episode);
      print("running with no subtitle");
      widget.next =  (widget.episode != null)? true:false;
      widget.live =  (widget.channel!= null)? true:false;
      FocusScope.of(context).requestFocus(video_player_focus_node);
      _prepareNext();
      _getSubtitlesList();
      _checkLogged();

     // print("selected subtitle  "+widget.subtitles![widget.selected_subtitle!].file_id.toString());





    });

    initSettings();
    super.initState();

   }
  void _checkLogged()  async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.logged = prefs.getBool("LOGGED_USER");
    this. subscribed =  prefs.getString("NEW_SUBSCRIBE_ENABLED");


  }
  void _prepareNext() {
    if (widget.episode != null){
      if ((widget.episode! + 1) <
            widget.seasons![widget.season!].episodes.length) {
          widget.next_episode = widget.episode! + 1;
          widget.next_season = widget.season!;
          widget.next = true;
          widget.next_title = widget.seasons![widget.next_season!].title + " : " +
              widget.seasons![widget.next_season!].episodes[widget.next_episode!]
                  .title;
        } else {
          if ((widget.season! + 1) < widget.seasons!.length) {
            if (widget.seasons![widget.season! + 1].episodes.length > 0) {
              widget.next_episode = 0;
              widget.next_season = widget.season! + 1;
              widget.next = true;
              widget.next_title =
                  widget.seasons![widget.next_season!].title + " : " +
                      widget.seasons![widget.next_season!].episodes[widget
                          .next_episode!].title;
            } else {
              widget.next = false;
            }
          } else {
            widget.next = false;
          }
        }
      setState(() {
      //  widget.next = true;//fake
      });
    }
  }
  void _getSubtitlesList()  async{
     if(widget.channel != null)
       return;
   // _subtitlesList.clear();
    setState(() {
      _visibile_subtitles_loading=true;
    });
  //  model.Subtitle? subtitle =new model.Subtitle(id: -1, type: "", language: "", url: "", image: "");
   // widget.subtitles!.insert(0, subtitle);
    var response;
   // if((widget.episode  == null))
     //response =await apiRest.getSubtitlesByMovie(widget.poster!.id);
   // else
     //response =await apiRest.getSubtitlesByEpisode(widget.seasons![widget.season!].episodes[widget.episode!].id);

    // if(response != null){
    //   if (response.statusCode == 200) {
    //     var jsonData =  convert.jsonDecode(response.body);
    //     for(Map language in jsonData){
    //         int count = 1;
    //         for(Map subtitle in language["subtitles"] ){
    //               print(subtitle["url"]);
    //               model.Subtitle _subtitle = model.Subtitle(id: subtitle["id"],type: subtitle["type"],url: subtitle["url"],image: language["image"],language: language["language"] +" ("+(count).toString()+")");
    //               _subtitlesList.add(_subtitle);
    //               count++;
    //         }
    //     }
    //   }
    // }
    // model.Subtitle _subtitle = model.Subtitle(id: 1,type: "",url: "https://storage.googleapis.com/sflix-edc5e.appspot.com/subtitles/263229_The%20Last%20Detail.English.srt",image:"https://cdn.britannica.com/44/344-004-494CC2E8/Flag-England.jpg",language:"es" +" ("+(1).toString()+")");
     //_subtitlesList.add(_subtitle);

    // model.Subtitle _subtitle2 = model.Subtitle(id: 2,type: "",url: "https://storage.googleapis.com/sflix-edc5e.appspot.com/subtitles/264214_The.Last.Detail.1973.720p.WEB-DL.AAC2.0.H.264-CtrlHD.srt",image:"https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Flag_of_Portugal.svg/255px-Flag_of_Portugal.svg.png",language:"Por" +" ("+(2).toString()+")");
    // _subtitlesList.add(_subtitle2);
    setState(() {
      _visibile_subtitles_loading=false;
    });

     _applySubtitle();
  }
  void _setupDataSource(int index) async {



    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.sourcesList![index].url,
      liveStream: (widget.channel == null)? false : true
    );
    _betterPlayerController!.setupDataSource(dataSource);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    try{
      _visibile_controllers_future!.cancel();
      _betterPlayerController!.dispose();
      _animated_controller!.dispose();
      video_player_focus_node.dispose();
    }catch(e){

    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        //&& widget.episode!=null && widget.season!=null
        if(widget.poster!=null && widget.episode==null){
          print("save in fb");

          try{
            dynamic data =   {"num":0,"name":widget.poster!.title,"stream_type":"movie","stream_id":widget.poster!.id,"stream_icon":widget.poster!.cover,"rating":widget.poster!.rating.toString(),"rating_5based":(widget.poster!.rating/2).roundToDouble(),"added":"1650236100","category_id":"1242","container_extension":widget.poster!.sources[0].type,"custom_sid":null,"direct_source":widget.poster!.sources[0].url};
            apiRest.pushWatch(totalDuration:_betterPlayerController!.videoPlayerController!.value.duration!.inSeconds,durationSeconds:_betterPlayerController!.videoPlayerController!.value.position.inSeconds,data: data);
            return true;
          }catch(e){
            return true;
          }
        }else{
          if(widget.episode!=null &&widget.season!=null ){
            print("save in fb");


             // dynamic data =   {"num":0,"name":widget.poster!.title,"stream_type":"series","stream_id":widget.poster!.id,"stream_icon":widget.poster!.cover,"rating":widget.poster!.rating.toString(),"rating_5based":(widget.poster!.rating/2).roundToDouble(),"added":"1650236100","category_id":"1242","container_extension":widget.poster!.sources[0].type,"custom_sid":null,"direct_source":widget.poster!.sources[0].url};
            //  apiRest.pushWatchSeries(totalDuration:_betterPlayerController!.videoPlayerController!.value.duration!.inSeconds,series_num: widget.poster!.id.toString(),type: "series", durationSeconds: _betterPlayerController!.videoPlayerController!.value.position.inSeconds,data:{"series":widget.seasons![widget.season!],"episode":widget.seasons![widget.season!].episodes[widget.episode!]});
            //
            //   FirebaseFirestore  firestore =  FirebaseFirestore.instance;
            //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
            //   String EMAIL =  sharedPreferences.getString("USER_ID")!;
            //   firestore.collection("watchHistory"+EMAIL).where("series_id",isEqualTo:data["series"]["series_id"]).where("episode_num",isEqualTo:data["episode"]["episode_num"]).get().then((value){
            //     if(value.docs.length>0){
            //       value.docs.first.reference.update({"time":DateTime.now().millisecondsSinceEpoch,"duration":durationSeconds});
            //     }else{
            //       firestore.collection("watchHistory"+EMAIL).add({"series_num":series_num,"series_id":data["series"]["series_id"],"episode_num":data["episode"]["episode_num"],"time":DateTime.now().millisecondsSinceEpoch,"type":type,"duration":durationSeconds,"data":data,"total":totalDuration}).then((value) => print("firebase note added"));
            //
            //     }

              return true;

          }else{
            print("no save now");
          }

          return true;
        }



        if(visible_subscribe_dialog){
          setState(() {
            visible_subscribe_dialog = false;
          });
          return false;
        }
       widget. _play_next_episode= false;
        if(_visibile_subtitles_dialog){
          _hideSubtitlesDialog();
          return false;
        }
        // if(visibileSourcesDialog){
        //   _hideSourcesDialog();
        //   return false;
        // }
        if(_visibile_controllers){
          _hideControllersDialog();
          return false;
        }




        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: RawKeyboardListener(
          focusNode: video_player_focus_node,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
              RawKeyDownEvent rawKeyDownEvent = event;
              RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data as RawKeyEventDataAndroid;
              print("Focus Node 0 ${rawKeyEventDataAndroid.keyCode}");

              if(rawKeyEventDataAndroid.keyCode == 4){
               // Navigator.pop(context);
              }



              if(!_visibile_controllers && rawKeyEventDataAndroid.keyCode != 4) {
                _hideControllers();
                return;
              }else{
                (rawKeyEventDataAndroid.keyCode != 4)? _hideControllers() : 0 ;

                switch (rawKeyEventDataAndroid.keyCode) {
                  case KEY_CENTER:
                    if(_visibile_subtitles_dialog){
                      _applySubtitle();
                    }else if(visibileSourcesDialog){
                       _applySource();
                    }else{
                        pausePlayVideo();
                        toStart();
                        FastRewind();
                        FastForward();
                        _showSubtitlesDialog();
                        //_showSourcesDialog();

                        _goToNextEpisode();
                    }
                    break;
                  case KEY_UP:
                    if(_visibile_subtitles_dialog){
                        (_focused_subtitle  == 0 )?  print("play sound") : _focused_subtitle--;
                    }else if(visibileSourcesDialog){
                        ( widget.focused_source  == 0 )? print("play sound") :  widget.focused_source--;
                    }else{
                      if(post_y == _video_controller_play_position){
                          print("play sound");
                      }else{
                          post_y --;
                          post_x= 0;
                      }
                    }
                    break;
                  case KEY_DOWN:
                    if(_visibile_subtitles_dialog){
                      (_focused_subtitle  == widget.subtitles!.length -1 )? print("play sound") : _focused_subtitle++;;
                    } else if(visibileSourcesDialog){
                      ( widget.focused_source  == widget.sourcesListDialog!.length -1 )? print("play sound") : widget.focused_source++;;
                    }else{
                        if(post_y == _video_controller_settings_position){
                          print("play sound");
                        }else{
                          post_y ++;
                          post_x= 0;
                        }
                    }
                    break;
                  case KEY_LEFT:
                      (_visibile_subtitles_dialog || visibileSourcesDialog)? print("play sound"):(post_y == _video_controller_slider_position)? _fastForwardRewindVideo(-5):(post_x == 0)?print("play sound"):post_x --;
                    break;
                  case KEY_RIGHT:
                     (_visibile_subtitles_dialog || visibileSourcesDialog)? print("play sound"):(post_y == _video_controller_slider_position )? _fastForwardRewindVideo(5): ((post_y == _video_controller_play_position && post_x == 4 && widget.next!) || (post_y == _video_controller_play_position && post_x == 3 && !widget.next!) || (post_y == _video_controller_settings_position && post_x == 1) )? print("play sound"):post_x ++;
                    break;
                  default:
                    break;
                }
              }
              setState(() {

              });
              if(_visibile_subtitles_dialog && _subtitlesScrollController!= null){
                _subtitlesScrollController.scrollTo(index: _focused_subtitle,alignment: 0.43,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
              }
              if(visibileSourcesDialog && _sourcesScrollController!= null){
                _sourcesScrollController.scrollTo(index: widget.focused_source,alignment: 0.43,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
              }
            }
          },
          child: Stack(children: [
            if(_betterPlayerController != null)
                GestureDetector(
                  onTap: (){
                    _hideControllers();
                  },
                  child: Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: BetterPlayer(controller: _betterPlayerController!),
                  ),
              ),
                )
            else
              Center(
                child: Container(
                  height: 100,
                  width: 110,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            if(_betterPlayerController != null)
            ui.VideoControllerWidget(
                live:widget.live ,
                title:(widget.channel != null)? widget.channel!.title:  ((widget.poster!.title + ((widget.seasons != null && widget.episode != null && widget.season!= null)? (widget.seasons!.length>0)? (widget.seasons![widget.season!].episodes.length>0)? " : "+widget.seasons![widget.season!].episodes[widget.episode!].title :  "":"":""))),
                next: widget.next,
                video_controller_play_position: _video_controller_play_position,
                video_controller_settings_position: _video_controller_settings_position,
                video_controller_slider_position: _video_controller_slider_position,
                visibile_controllers: _visibile_controllers,
                visibileSourcesDialog: visibileSourcesDialog,
                visibile_subtitles_dialog: _visibile_subtitles_dialog,
                animated_controller: _animated_controller,
                post_y: post_y,
                post_x: post_x,
                betterPlayerController: _betterPlayerController,
                slider_video_value: _slider_video_value,
                next_title:  widget.next_title,
                autohide:_hideControllers,
                fastRewind:FastRewindButton,
                fastForward:FastForwardButton,
                playnext: PlayNextButton,
               // sources: SourcesButton,
                subtitles :SubtitlesButton,
                pauseplay: PausePlayButton,
                tostart: ToStartButton,

            ),
            ui.SubtitlesDialog(subtitlesList: widget.subtitles!,selected_subtitle: _selected_subtitle,focused_subtitle: _focused_subtitle,subtitlesScrollController: _subtitlesScrollController,visibile: _visibile_subtitles_dialog,close: closeSubtitleDialog,select:selectSubtitle ),
            //ui.SourcesDialog(sourcesScrollController2: _sourcesScrollController,sourcesList: widget.sourcesListDialog!,selected_source: widget.selected_source!,focused_source: widget.focused_source,sourcesScrollController: _sourcesScrollController,visibileSourcesDialog: visibileSourcesDialog,close: closeSourceDialog,select:selectSource ),
            SubscribeDialog(visible:visible_subscribe_dialog ,close:(){
              setState(() {
                visible_subscribe_dialog= false;
              });
            }),
          ]),
        ),
      ),
    );
  }
  void selectSource(int selected_source_pick){
    setState(() {
      widget.focused_source =  selected_source_pick;
      _applySource();

    });
  }


  void ToStartButton(){
    setState(() {
      post_y = 0;
      post_x = 1;
      toStart();
    });
  }
  void PausePlayButton(){
      setState(() {
        post_y = 0;
        post_x = 0;
        pausePlayVideo();
      });
  }

  Future<void> selectSubtitle(int selected_subtitle_pick) async {

     print("just subtitlle selected at "+selected_subtitle_pick.toString());
     print(widget.subtitles![ selected_subtitle_pick]);


     // String link = await  apiRest.downloadubtitles(fileName: widget.subtitles![ selected_subtitle_pick].file_id.toString()+".srt", fileId: widget.subtitles![ selected_subtitle_pick].file_id.toString(), lang: widget.subtitles![selected_subtitle_pick].language);
     //
     //
     // nowWorkingSubtitle = link;
     //
     // print("just downloaded subtitle "+nowWorkingSubtitle!);
     //
     //
     //
     //
      setState(() {
        _focused_subtitle = selected_subtitle_pick;
        _applySubtitle();
        _visibile_subtitles_dialog = false;
      });

  }
  void closeSourceDialog(){
    setState(() {
      visibileSourcesDialog = false;
    });
  }
  void closeSubtitleDialog(){
    setState(() {
      _visibile_subtitles_dialog = false;
    });
  }

   _hideControllers(){
     setState(() {
       _visibile_controllers = true;
     });
     if(_visibile_controllers_future != null){
       _visibile_controllers_future?.cancel();
     }
     _visibile_controllers_future = Timer(Duration(milliseconds: 5000), () {
       setState(() {
         _visibile_controllers = false;
       });
     });
     // and later, before the timer goes off...

   }



   Future<void> _fastForwardRewindVideo(int seconds) async {
     if(_betterPlayerController!.videoPlayerController!.value.duration!=null && _betterPlayerController?.videoPlayerController?.value.position != null){
        int? milli_second_seek_to = _betterPlayerController!.videoPlayerController!.value.position.inSeconds + seconds;
        if(milli_second_seek_to < 0){
           milli_second_seek_to = 0;
        }else if(milli_second_seek_to > _betterPlayerController!.videoPlayerController!.value.duration!.inSeconds ){
          milli_second_seek_to =  _betterPlayerController?.videoPlayerController?.value?.duration?.inSeconds;
        }
       _betterPlayerController?.seekTo(Duration(seconds:  milli_second_seek_to!));
     }
   }
  void pausePlayVideo() {
    if(post_y == _video_controller_play_position && post_x == 0){
      if( _betterPlayerController?.isPlaying() == true){
        _betterPlayerController?.videoPlayerController?.pause();
        _animated_controller?.reverse();
    }else{
        _betterPlayerController?.videoPlayerController?.play();
        _animated_controller?.forward();
      }
    }
  }
  void SubtitlesButton() {
    setState(() {
      post_y = _video_controller_settings_position ;
      post_x = 0;
    });
    Future.delayed(Duration(milliseconds: 200),(){
      _showSubtitlesDialog();
    });
  }
  void SourcesButton() {
    setState(() {
      post_y = _video_controller_settings_position ;
      post_x = 1;
    });
    Future.delayed(Duration(milliseconds: 200),(){
      _showSourcesDialog();
    });
  }
  void FastRewind() {
    if(post_y == _video_controller_play_position && post_x == 2) _fastForwardRewindVideo(-10);
  }
  void FastRewindButton() {
    setState(() {
      post_y = _video_controller_play_position ;
      post_x = 2;
    });
    Future.delayed(Duration(milliseconds: 200),(){
      FastRewind();
    });
  }
   void FastForward() {
     if(post_y == _video_controller_play_position && post_x == 3) _fastForwardRewindVideo(10);
   }
  void FastForwardButton() {
    setState(() {
      post_y = _video_controller_play_position ;
      post_x = 3;
    });
    Future.delayed(Duration(milliseconds: 200),(){
      FastForward();
    });
   }
  void _showSubtitlesDialog() {
    if(post_y == _video_controller_settings_position && post_x == 0 && widget.live == false)
      setState(() {
        _visibile_subtitles_dialog = true;
      });
  }
   void _hideSubtitlesDialog() {
       setState(() {
         _visibile_subtitles_dialog = false;
       });
   }
   void _showSourcesDialog() {
     if(post_y == _video_controller_settings_position && post_x == 1) {
       widget.sourcesListDialog = widget.sourcesList;
       setState(() {
         visibileSourcesDialog = true;
       });
     }
   }
   void _hideSourcesDialog() {
       setState(() {
         visibileSourcesDialog = false;
       });
   }
   void _hideControllersDialog() {
     setState(() {
       _visibile_controllers =  false;
     });
   }

   Future<void> _applySubtitle() async {

    _visibile_subtitles_dialog = false;
    _visibile_controllers = false;
    _selected_subtitle = _focused_subtitle;

    print("at setting subtitle done "+_selected_subtitle.toString());

    print(widget.subtitles!.length);
   // print(widget.subtitles![_selected_subtitle].file_id);
   // print(widget.subtitles![_selected_subtitle].language);

    BetterPlayerSubtitlesSource subtitlesSource;

    if(_selected_subtitle == 0){
      subtitlesSource =  BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.none
      );
    }else {


    String  initFileName =  (widget.subtitles![ _selected_subtitle].file_id).toString() ;

     var  value = await  fire.FirebaseFirestore.instance.collection("subtitlesByFileId").doc(initFileName).get();

    if(value.exists){

      print("subtitle was previously available");

      String linkStorage = value.get("storage");

      nowWorkingSubtitle = linkStorage;


    }else{

      print("need to download and cache subtitle ");
      //search and get subtitle from opensubtitles and cache and use

      String link = await  apiRest.downloadubtitles(fileName: widget.subtitles![_selected_subtitle].file_id.toString(), fileId: widget.subtitles![_selected_subtitle].file_id.toString(), lang: widget.subtitles![_selected_subtitle].language);


      nowWorkingSubtitle = link;

      print("just downloaded subtitle "+nowWorkingSubtitle!);

    }








     // print(widget.subtitles![_selected_subtitle].url);
     // print(widget.subtitles![_selected_subtitle].language);
    //  print(widget.subtitles![_selected_subtitle].type);
     // print(widget.subtitles![_selected_subtitle].image);
      print("setting subtitle");
      subtitlesSource = BetterPlayerSubtitlesSource(
        type: BetterPlayerSubtitlesSourceType.network,
        name: widget.subtitles![_selected_subtitle].language,
        urls: [
        //  widget.subtitles![_selected_subtitle].url,
          nowWorkingSubtitle
        ],
      );


    }


    if(widget.subtitles!.length>0 && widget.selected_subtitle!>0)


    try{
      _betterPlayerController?.setupSubtitleSource(subtitlesSource).then((value) {
        print("setting subtitle done "+_betterPlayerController!.betterPlayerSubtitlesSource!.urls!.first!);
      });
    }catch(e){
      print("subtitle set error");
      print(e);
    }



   }

   void _applySource() {


     if(widget._play_next_episode! == true){
       _openSourcePlayer();
     }else{
       visibileSourcesDialog = false;
       _visibile_controllers = false;
       widget.selected_source = widget.focused_source;

       if(widget.sourcesListDialog![widget.selected_source!].premium == "2" || widget.sourcesListDialog![widget.selected_source!].premium == "3"){

         if(subscribed == "TRUE"){
           _setupDataSource(widget.selected_source!);
         }else{

           setState(() {
             visible_subscribe_dialog = true;
           });
         }
       }else{
         _setupDataSource(widget.selected_source!);
       }

     }

   }

  void _openSourcePlayer() async{
    if(visibileSourcesDialog) {
      visibileSourcesDialog = false;
      widget.selected_source = widget.focused_source;

      if(widget.sourcesListDialog![widget.selected_source!].premium == "2" || widget.sourcesListDialog![widget.selected_source!].premium == "3"){
        if(subscribed == "TRUE"){
          _goToNextEpisodePlayer();
        }else{
          setState(() {
            visible_subscribe_dialog = true;
          });
        }
      }else{
        _goToNextEpisodePlayer();
      }
    }
  }
  _goToNextEpisodePlayer() async{
    if (widget.sourcesListDialog![widget.selected_source!].type == "youtube" || widget.sourcesListDialog![widget.selected_source!].type == "embed" ) {

      String url = widget.sourcesListDialog![widget.selected_source!].url;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      int _new_selected_source =0;
      List<Source> _sources = [];
      int j = 0;
      for (var i = 0; i < widget.sourcesListDialog!.length; i++) {
        if(widget.sourcesListDialog![widget.selected_source!].type != "youtube"){
          _sources.add(widget.sourcesListDialog![i]);
          if(widget.selected_source == i){
            _new_selected_source = j;
          }
          j++;
        }
      }

      // Navigator.push(
      //   context,
      //   PageRouteBuilder(
      //     pageBuilder: (context, animation1, animation2) => VideoPlayer(subtitles: [],sourcesList: _sources,selected_source:_new_selected_source,focused_source: _new_selected_source,poster: widget.serie,episode:selected_episode!,season: selected_season,seasons:seasons ),
      //     transitionDuration: Duration(seconds: 0),
      //   ),
      // );


      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => VideoPlayer(subtitles: [],selected_subtitle: 0,sourcesList: _sources,selected_source:_new_selected_source,focused_source: _new_selected_source,poster: widget.poster,episode:widget.next_episode,season: widget.next_season,seasons:widget.seasons ),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    }
  }
   void initSettings() async{
     try{
       _animated_controller = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
       _animated_controller!.forward();

       prefs = await SharedPreferences.getInstance();
     //  _subtitle_enabled  =  prefs?.getBool("subtitle_enabled");
       _subtitle_enabled  =  true;
       //  _subtitle_size =  prefs?.getInt("subtitle_size")!;
       _subtitle_size =  (MediaQuery.of(context).size.longestSide*0.02).toInt();
       _subtitle_color =  prefs?.getInt("subtitle_color")!;
       _subtitle_background =  prefs?.getInt("subtitle_background")!;
     }catch(e){
       _subtitle_color = 1;
       _subtitle_background = 2;
     }


     BetterPlayerConfiguration betterPlayerConfiguration =
     BetterPlayerConfiguration(
       controlsConfiguration: BetterPlayerControlsConfiguration(
         showControls: false,
       ),
       aspectRatio: 16 / 9,
       fit: BoxFit.contain,
       autoPlay: true,
       subtitlesConfiguration: BetterPlayerSubtitlesConfiguration(
         backgroundColor: _list_text_bg[_subtitle_background!],
         fontColor: _list_text_color[_subtitle_color!  ],
         outlineColor: Colors.black,
         fontSize: _subtitle_size!.toDouble(),
       ),
     );
     _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);


     _setupDataSource(widget.selected_source!);
     _hideControllers();
     //_subtitle_enabled! == true &&
     if( widget.subtitles!.length>0 && widget.selected_subtitle!>0){
       Fluttertoast.showToast(
         msg: "with subtitle",
         gravity: ToastGravity.BOTTOM,
         backgroundColor: Colors.green,
         textColor: Colors.white,
       );
       _applySubtitle();
     }else{
       Fluttertoast.showToast(
         msg: "no   subtitle",
         gravity: ToastGravity.BOTTOM,
         backgroundColor: Colors.green,
         textColor: Colors.white,
       );
     }

   }
  PlayNextButton() {
    setState(() {
      post_y = _video_controller_play_position  ;
      post_x = 4;
    });
    Future.delayed(Duration(milliseconds: 200),(){
      _goToNextEpisode();
    });
  }
  void _goToNextEpisode() {

     print("PLay Next Episode");

    if(post_y == _video_controller_play_position  && post_x == 4){
      widget.selected_source =0;
      widget.focused_source =0;
      widget.sourcesListDialog =  widget.seasons![widget.next_season!].episodes[widget.next_episode!].sources;
      widget._play_next_episode = true;
      setState(() {
        visibileSourcesDialog =  true;
      });

      _openSourcePlayer();
    }
  }

  void toStart() {
    if(post_y == _video_controller_play_position  && post_x == 1){
      if(_betterPlayerController?.videoPlayerController?.value.duration!=null && _betterPlayerController?.videoPlayerController?.value.position != null){
        _betterPlayerController?.seekTo(Duration(seconds:  0));
      }
    }
  }




}

