import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_tv/ui/home/home.dart';
import 'package:flutter_app_tv/model/source.dart';
import 'package:flutter_app_tv/ui/player/source_widget.dart';
import 'package:flutter_app_tv/ui/player/subtitle_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../model/subtitle.dart';
import '../player/subtitle_tile_source_widget.dart';

class SourcesDialog extends StatefulWidget {

  List?  sourcesList = [];
  bool visibileSourcesDialog;
  int focused_source;
  int selected_source;
  ItemScrollController sourcesScrollController = ItemScrollController();
  ItemScrollController sourcesScrollController2 = ItemScrollController();
  Function close;
  Function select;
  Function? subtitleSelect;

  String? tmdb_id;

  List<Subtitle>? subtitleList = [];

  SourcesDialog({this.subtitleSelect,this.subtitleList,this.tmdb_id,required this.sourcesList,required this.sourcesScrollController,required this.sourcesScrollController2,required this.focused_source,required this.selected_source,required this.visibileSourcesDialog,required this.close,required this.select});

  @override
  _SourcesDialogState createState() => _SourcesDialogState();


}


class _SourcesDialogState extends State<SourcesDialog> {

  List<String>sTitles = ["English","Bengali"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
     Shortcuts(shortcuts: <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
    }, child: MaterialApp(
      title: 'SFlix',debugShowCheckedModeBanner: false,
      home: Scaffold(body: Stack(
        children: [
          Align(alignment: Alignment.centerRight,child: Container(width: MediaQuery.of(context).size.width/3,height: MediaQuery.of(context).size.height ,child:ListView.builder(shrinkWrap: true,
            itemCount: sTitles.length,
            itemBuilder: (context, index) {
              return InkWell(focusColor: Colors.red.withOpacity(0.5),onTap: (){

              },child: Text(sTitles[index]),);
            },
          ) ,),)
        ],
      ),),
    ));

    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Visibility(
          visible: widget.visibileSourcesDialog,
          child: Container(
            color: Colors.black87,
            child: Stack(
                children: [
                  Positioned(
                      left: 0,
                      bottom: 0,
                      top: 0,
                      right:(MediaQuery.of(context).size.width/3),
                      child: GestureDetector(
                        onTap: (){
                          widget.close();
                        },
                        child: Container(
                          color:Colors.black.withOpacity(0.1)
                        ),
                      )
                  ),
                  Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width/3,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          boxShadow: [
                            BoxShadow(
                                color:Colors.black,
                                offset: Offset(0,0),
                                blurRadius: 5
                            ),
                          ],
                        ),
                        child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              color: Colors.black45,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 80.0,left: 10,bottom: 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.high_quality_sharp,color: Colors.white70,size: 35),
                                    SizedBox(width: 10),
                                    Text(
                                      "Select subtile",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.longestSide*0.025,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white70
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Expanded(child:
                            // Container(
                            //   color: Colors.black.withOpacity(0.7),
                            //   child:  ScrollConfiguration(
                            //     behavior: MyBehavior(),   // From this behaviour you can change the behaviour
                            //     child: ScrollablePositionedList.builder(
                            //       itemCount: widget.sourcesList.length,
                            //       itemScrollController: widget.sourcesScrollController2,
                            //       scrollDirection: Axis.vertical,
                            //       itemBuilder: (context, index) {
                            //         return  GestureDetector(
                            //             onTap: (){
                            //               widget.select(index);
                            //             },
                            //             child: SourceWidget(isFocused: (index == widget.focused_source),source:widget.sourcesList[index])
                            //         );
                            //       },
                            //     ),
                            //   ),
                            // ) ,
                                Container(
                              color: Colors.black.withOpacity(0.7),
                              child:  ScrollConfiguration(
                                behavior: MyBehavior(),   // From this behaviour you can change the behaviour
                                child: ScrollablePositionedList.builder(
                                  itemCount: widget.subtitleList!.length,
                                  itemScrollController: widget.sourcesScrollController,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return  GestureDetector(
                                        onTap: (){
                                          print("setting subtitles");
                                          widget.subtitleSelect!(index);
                                        },
                                        child:false?Text(widget.subtitleList![index].toString()): SubtitleTileSourceWidget(isFocused: (index == widget.focused_source),subtitleSource:widget.subtitleList![index])
                                    );
                                  },
                                ),
                              ),
                            )


                            ),

                        // if(false)   Expanded(child:
                        //     Container(
                        //       color: Colors.black.withOpacity(0.7),
                        //       child:  ScrollConfiguration(
                        //         behavior: MyBehavior(),   // From this behaviour you can change the behaviour
                        //         child: ScrollablePositionedList.builder(
                        //           itemCount: widget.sourcesList.length,
                        //           itemScrollController: widget.sourcesScrollController,
                        //           scrollDirection: Axis.vertical,
                        //           itemBuilder: (context, index) {
                        //             return  GestureDetector(
                        //                 onTap: (){
                        //                     widget.select(index);
                        //                 },
                        //                 child: SourceWidget(isFocused: (index == widget.focused_source),source:widget.sourcesList[index])
                        //             );
                        //           },
                        //         ),
                        //       ),
                        //     ))
                          ],
                        ),
                      )
                  )
                ]
            ),
          )
      ),
    );
  }
}