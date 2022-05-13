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
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert' as convert;

import 'package:url_launcher/url_launcher.dart';

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.


class VideoPlayerTrailerOnly extends StatefulWidget {

  Source? source;








  int? selected_source =0;
  int focused_source =0;
  bool? next = false ;
  bool? live = false ;





  VideoPlayerTrailerOnly({  required this.focused_source,this.source});

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayerTrailerOnly>   with SingleTickerProviderStateMixin{

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


     try{

     }catch(e){

     }

    // print("selected subtitle index "+widget.selected_subtitle!.toString());


    Future.delayed(Duration.zero, () async {

      String initFileName = "";




      print("running with no subtitle");

      print("running with no subtitle");
      widget.next = false;
      widget.live =  false;
      FocusScope.of(context).requestFocus(video_player_focus_node);
     // _prepareNext();
     // _getSubtitlesList();
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


  void _setupDataSource(int index) async {

     print("running better layer");
     print(widget.source!.url);



    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,"https://www.youtube.com/watch?v=O38-IuOmExU",
      liveStream:  false
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
                Navigator.pop(context);
              }



              if(!_visibile_controllers && rawKeyEventDataAndroid.keyCode != 4) {
                //_hideControllers();
                return;
              }else{
                (rawKeyEventDataAndroid.keyCode != 4)? _hideControllers() : 0 ;

                switch (rawKeyEventDataAndroid.keyCode) {
                  case KEY_CENTER:
                    if(_visibile_subtitles_dialog){

                    }else if(visibileSourcesDialog){
                      // _applySource();
                    }else{
                        //pausePlayVideo();
                        //toStart();
                        FastRewind();
                        FastForward();
                       // _showSubtitlesDialog();
                        //_showSourcesDialog();


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

                        if(post_y == _video_controller_settings_position){
                          print("play sound");
                        }else{
                          post_y ++;
                          post_x= 0;
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
                title:widget.source!.title,
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
                //next_title:  widget.next_title,
                autohide:_hideControllers,
                fastRewind:FastRewindButton,
                fastForward:FastForwardButton,
                playnext: PlayNextButton,
               // sources: SourcesButton,
                subtitles :SubtitlesButton,
                pauseplay: PausePlayButton,
                tostart: ToStartButton,

            ),
           // ui.SubtitlesDialog(subtitlesList: widget.subtitles!,selected_subtitle: _selected_subtitle,focused_subtitle: _focused_subtitle,subtitlesScrollController: _subtitlesScrollController,visibile: _visibile_subtitles_dialog,close: closeSubtitleDialog,select:selectSubtitle ),
            //ui.SourcesDialog(sourcesScrollController2: _sourcesScrollController,sourcesList: widget.sourcesListDialog!,selected_source: widget.selected_source!,focused_source: widget.focused_source,sourcesScrollController: _sourcesScrollController,visibileSourcesDialog: visibileSourcesDialog,close: closeSourceDialog,select:selectSource ),
            // SubscribeDialog(visible:visible_subscribe_dialog ,close:(){
            //   setState(() {
            //     visible_subscribe_dialog= false;
            //   });
            // }),
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


   void _applySource() {


     // if(widget._play_next_episode! == true){
     //   _openSourcePlayer();
     // }else{
     //   visibileSourcesDialog = false;
     //   _visibile_controllers = false;
     //   widget.selected_source = widget.focused_source;
     //
     //   if(widget.sourcesListDialog![widget.selected_source!].premium == "2" || widget.sourcesListDialog![widget.selected_source!].premium == "3"){
     //
     //     if(subscribed == "TRUE"){
     //       _setupDataSource(widget.selected_source!);
     //     }else{
     //
     //       setState(() {
     //         visible_subscribe_dialog = true;
     //       });
     //     }
     //   }else{
     //     _setupDataSource(widget.selected_source!);
     //   }
     //
     // }

   }

  void _openSourcePlayer() async{
    // if(visibileSourcesDialog) {
    //   visibileSourcesDialog = false;
    //   widget.selected_source = widget.focused_source;
    //
    //   if(widget.sourcesListDialog![widget.selected_source!].premium == "2" || widget.sourcesListDialog![widget.selected_source!].premium == "3"){
    //     if(subscribed == "TRUE"){
    //       _goToNextEpisodePlayer();
    //     }else{
    //       setState(() {
    //         visible_subscribe_dialog = true;
    //       });
    //     }
    //   }else{
    //     _goToNextEpisodePlayer();
    //   }
    // }
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


   }
  PlayNextButton() {
    setState(() {
      post_y = _video_controller_play_position  ;
      post_x = 4;
    });

  }


  void toStart() {
    if(post_y == _video_controller_play_position  && post_x == 1){
      if(_betterPlayerController?.videoPlayerController?.value.duration!=null && _betterPlayerController?.videoPlayerController?.value.position != null){
        _betterPlayerController?.seekTo(Duration(seconds:  0));
      }
    }
  }




}

