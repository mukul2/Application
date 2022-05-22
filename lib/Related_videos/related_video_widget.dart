import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_tv/model/source.dart';
import 'package:flutter_app_tv/ui/home/home.dart';
import 'package:flutter_app_tv/model/poster.dart';
import 'package:flutter_app_tv/ui/movie/movie.dart';
import 'package:flutter_app_tv/ui/movie/movie_widget.dart';
import 'package:flutter_app_tv/ui/movie/movies.dart' as isss;
import 'package:flutter_app_tv/ui/serie/serie.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../ui/player/video_player_trailer_only.dart';
import 'RelatedVideo.dart';

class RelatedVideoWidget extends StatefulWidget {
  String? title;
  List<Source>? posters =[];
  int? size;
  int? posty;
  int? postx;
  int? jndex;
  ItemScrollController? scrollController;


  RelatedVideoWidget({this.posty, this.postx, this.jndex, this.scrollController,this.title,this.posters, this.size});

  @override
  _MoviesWidgetState createState() => _MoviesWidgetState();
}

class _MoviesWidgetState extends State<RelatedVideoWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.longestSide*0.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.only(left: 50,bottom: 5),
           // height: 22,
            child: Text(
              widget.title!,
              style: TextStyle(
                  color: (widget.jndex == widget.posty)?Colors.white:Colors.white60,
                  fontSize: (widget.size == null)? MediaQuery.of(context).size.longestSide*0.018: MediaQuery.of(context).size.longestSide*0.018,
                  fontWeight: FontWeight.w900
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.longestSide*0.15,
            width: double.infinity,
            child: ScrollConfiguration(
              behavior: MyBehavior(),   //
              child: ScrollablePositionedList.builder(
                itemCount: widget.posters!.length,
                itemScrollController: widget.scrollController,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:  EdgeInsets.only(left:(0==index)?40:0),
                    child: GestureDetector(
                        onTap: (){
                          setState(() {
                            widget.posty = widget.jndex;
                            widget.postx =index;
                            Future.delayed(Duration(milliseconds: 250),(){


                              //play the video now




                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) => VideoPlayerTrailerOnly(source:  widget.posters![index],focused_source: 0,),
                                  transitionDuration: Duration(seconds: 0),
                                ),
                              );
                            });
                          });
                        },
                       // child: MovieWidget(isFocus:  ((widget.posty == widget.jndex && widget.postx == index)),movie: widget.posters![index])
                        child: RVWidget(isFocus:  ((widget.posty == widget.jndex && widget.postx == index)),source: widget.posters![index])
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}