import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_tv/ui/channel/channel_detail.dart';
import 'package:flutter_app_tv/ui/home/home.dart';
import 'package:flutter_app_tv/model/channel.dart';
import 'package:flutter_app_tv/ui/channel/channel_widget.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:http/http.dart' as http;

import '../model/slingChannel.dart';
class SlingWidgetWidget extends StatefulWidget {

  List<SlingChannel> channels = [];

  String title;
  double size;


  int posty;
  int postx;
  int jndex;
  ItemScrollController scrollController;


  SlingWidgetWidget({required this.posty, required this.postx, required this.jndex, required this.scrollController,required this.size,required this.title,required this.channels});

  @override
  _ChannelsWidgetState createState() => _ChannelsWidgetState();
}

class _ChannelsWidgetState extends State<SlingWidgetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(  height:  MediaQuery.of(context).size.longestSide*0.18,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.longestSide*0.027,bottom: MediaQuery.of(context).size.longestSide*0.004),

            child: Text(
              widget.title,
              style: TextStyle(
                  color: (widget.jndex == widget.posty)?Colors.white:Colors.white,
                  fontSize: widget.size,
                  fontWeight: FontWeight.w900
              ),
            ),
          ),
          Container(
            height:  MediaQuery.of(context).size.longestSide*0.15,
            child:  ScrollConfiguration(
              behavior: MyBehavior(),   // From this behaviour you can change the behaviour
              child: ScrollablePositionedList.builder(
                itemCount: widget.channels.length,
                itemScrollController:widget.scrollController,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {


                  return AnimatedContainer(duration: Duration(milliseconds: 200),height:   ((widget.posty == widget.jndex && widget.postx == index))? (MediaQuery.of(context).size.longestSide*0.15):(MediaQuery.of(context).size.longestSide*0.12) ,width:   ((widget.posty == widget.jndex && widget.postx == index))? (MediaQuery.of(context).size.longestSide*0.3):(MediaQuery.of(context).size.longestSide*0.25), margin: EdgeInsets.all(MediaQuery.of(context).size.longestSide*0.005),
                    decoration: BoxDecoration(border: Border.all(color: ((widget.posty == widget.jndex && widget.postx == index))?Colors.red: Colors.white),borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.0025),
                      //color: (jndex2==postx && posty == -1)?Colors.red:Colors.transparent,

                    ),child: Center(
                      child: Stack(
                        children: [

                          Align(alignment: Alignment.centerRight,child:Image.network( widget.channels[index].thumbBig?? "https://bobsvagene.club/wp-content/uploads/2021/09/sunny_leone_nude_b-7871.jpg",fit: BoxFit.cover,width: ((widget.posty == widget.jndex && widget.postx == index))? (MediaQuery.of(context).size.longestSide*0.3):(MediaQuery.of(context).size.longestSide*0.25) ,) ,),
                          Align(alignment: Alignment.bottomLeft,child:  Container(decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black,
                                  Colors.black,
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.5),
                                  Colors.black.withOpacity(0.1),

                                ],
                              )
                          ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(mainAxisAlignment: MainAxisAlignment.end,crossAxisAlignment: CrossAxisAlignment.start,
                                children: [


                                   Text(utf8.decode(base64.decode( widget.channels[index].epgs![0]["title"])),maxLines: 1,style: TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.longestSide*0.017 ),),
                                  Text(utf8.decode(base64.decode(widget.channels[index].epgs![0]["description"])),maxLines: 2,style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.longestSide*0.015),),
                                  Row(
                                    children: [
                                      Text(DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(60000+int.parse(widget.channels[index].epgs![0]["start_timestamp"])*1000)),maxLines: 2,style:  TextStyle(color: Colors.redAccent,fontSize:MediaQuery.of(context).size.longestSide*0.010),),
                                      Text(" - ",maxLines: 2,style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.longestSide*0.010),),
                                      Text(DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(60000+int.parse(widget.channels[index].epgs![0]["stop_timestamp"])*1000)),maxLines: 2,style:  TextStyle(color: Colors.redAccent,fontSize:MediaQuery.of(context).size.longestSide*0.010),),
                                    ],
                                  ),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Text( widget.channels[index].title,style: TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.longestSide*0.01 ),),
                                          if( ((widget.posty == widget.jndex && widget.postx == index)))    Container(decoration: BoxDecoration( borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.003),color: Colors.white,),
                                            margin: EdgeInsets.only(left:MediaQuery.of(context).size.longestSide*0.01), child: Padding(
                                              padding:  EdgeInsets.only(top: MediaQuery.of(context).size.longestSide*0.005,bottom: MediaQuery.of(context).size.longestSide*0.005,left: MediaQuery.of(context).size.longestSide*0.01,right: MediaQuery.of(context).size.longestSide*0.01),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.tv,color: Colors.black,size:MediaQuery.of(context).size.longestSide*0.01),
                                                  Padding(
                                                    padding:  EdgeInsets.only(left: MediaQuery.of(context).size.longestSide*0.01),
                                                    child: Text("Watch",style: TextStyle(color: Colors.black,fontSize:MediaQuery.of(context).size.longestSide*0.01 ),),
                                                  ),

                                                ],
                                              ),
                                            ),),
                                        ],
                                      ),

                                      CachedNetworkImage(height:MediaQuery.of(context).size.longestSide*0.03 ,width: MediaQuery.of(context).size.longestSide*0.03,
                                        imageUrl: widget.channels[index].image,
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                        // fit: !isFocus? BoxFit.cover:BoxFit.none,
                                      ),

                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),

                        ],
                      ),
                    ),

                  );


                  // return Padding(
                  //   padding:  EdgeInsets.only(left:(0==index)?MediaQuery.of(context).size.longestSide*0.018:0),
                  //   child: GestureDetector(
                  //       onTap: (){
                  //         setState(() {
                  //           widget.posty = widget.jndex;
                  //           widget.postx =index;
                  //           Future.delayed(Duration(milliseconds: 250),(){
                  //             Navigator.push(
                  //               context,
                  //               PageRouteBuilder(
                  //                 pageBuilder: (context, animation1, animation2) => ChannelDetail(channel: widget.channels[index]),
                  //                 transitionDuration: Duration(seconds: 0),
                  //               ),
                  //             );
                  //           });
                  //         });
                  //       },
                  //       child: ChannelWidget(isFocus:  ((widget.posty == widget.jndex && widget.postx == index)),channel: widget.channels[index])
                  //   ),
                  // );
                },
              ),
            ),
          )
        ],
      ),
    );

  }
}



class ChannelsWidgetForEPGUI extends StatefulWidget {



  Channel channel;

  String title;
  double size;

  int posty;
  int postx;
  int jndex;
  ItemScrollController scrollController;


  ChannelsWidgetForEPGUI({required this.posty, required this.postx, required this.jndex, required this.scrollController,required this.size,required this.title,required this.channel});

  @override
  _ChannelsWidgetForEPGUIState createState() => _ChannelsWidgetForEPGUIState();
}

class _ChannelsWidgetForEPGUIState extends State<ChannelsWidgetForEPGUI> {

  Future<List> downloadEPG() async {

    List epgs = [];
    String castLink = "http://connect.proxytx.cloud/player_api.php?username=4fe8679c08&password=2016&action=get_short_epg&stream_id="+widget.channel.id.toString()+"&limit=10";
    print(castLink);
    var responseEPG = await http.get(Uri.parse(castLink), );
    print("sort epg res "+ responseEPG.body);

    dynamic dd = jsonDecode(responseEPG.body);
    epgs = dd["epg_listings"];

    return epgs;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height:  MediaQuery.of(context).size.longestSide*0.06,
      child:  Row(
        children: [
          Container(  width: MediaQuery.of(context).size.longestSide*0.06,height:MediaQuery.of(context).size.longestSide*0.06 ,
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.longestSide*0.001,vertical: MediaQuery.of(context).size.longestSide*0.001),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                child: ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl:widget.channel.image,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      // fit: (((widget.posty == widget.jndex && widget.postx == 0)))? BoxFit.cover:BoxFit.none,
                    ),
                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.004)
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.004),
                  color: Colors.transparent,
                  // border: (((widget.posty == widget.jndex && widget.postx == 0)))?Border.all(color: Colors.purple,width: MediaQuery.of(context).size.longestSide*0.002):Border.all(color: Colors.transparent,width: 0),
                  // boxShadow: [
                  //   BoxShadow(
                  //       color: (((widget.posty == widget.jndex && widget.postx == 0)))?Colors.purple:Colors.white.withOpacity(0),
                  //       offset: Offset(0,0),
                  //       blurRadius: MediaQuery.of(context).size.longestSide*0.002
                  //   ),
                  // ],
                ),

                width: MediaQuery.of(context).size.longestSide*0.06,
              ),
            ),
          ),
          Expanded(
            child:ScrollConfiguration(
              behavior: MyBehavior(),   // From this behaviour you can change the behaviour
              child: ScrollablePositionedList.builder(
                itemCount: 10,
                itemScrollController:widget.scrollController,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {




                  return Padding(
                    padding:  EdgeInsets.only(left:(0==index)?MediaQuery.of(context).size.longestSide*0.009:0),
                    child: GestureDetector(
                        onTap: (){
                          // setState(() {
                          //   widget.posty = widget.jndex;
                          //   widget.postx =index;
                          //   Future.delayed(Duration(milliseconds: 250),(){
                          //     Navigator.push(
                          //       context,
                          //       PageRouteBuilder(
                          //         pageBuilder: (context, animation1, animation2) => ChannelDetail(channel: widget.channels[index]),
                          //         transitionDuration: Duration(seconds: 0),
                          //       ),
                          //     );
                          //   });
                          // });
                        },
                        //  child: ChannelWidget(isFocus:  ((widget.posty == widget.jndex && widget.postx == index)),channel: widget.channels[index])
                        child: Padding(
                          padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.longestSide*0.003,vertical: MediaQuery.of(context).size.longestSide*0.003),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            child: ClipRRect(
                              //child: Text(snapshot.data[index],style: TextStyle(color: Colors.white),),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(utf8.decode(base64.decode(widget.channel.epgs![index]["title"])),style: TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.019),),
                                    Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(   DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(60000+int.parse(widget.channel.epgs![index]["start_timestamp"])*1000)),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
                                        Text(  " - ",style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
                                        Text(   DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(60000+int.parse(widget.channel.epgs![index]["stop_timestamp"])*1000)),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),


                                      ],
                                    )
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.002)
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.004),
                              color:   Colors.grey.withOpacity( (((widget.posty == widget.jndex && widget.postx == index)))?  0.18:0.1),
                              border: (((widget.posty == widget.jndex && widget.postx == index)))?Border.all(color:   (((widget.posty == widget.jndex && widget.postx == index)))? Colors.white:Colors.transparent,width: MediaQuery.of(context).size.longestSide*0.0002):Border.all(color: Colors.transparent,width: 0),
                              // boxShadow: [
                              //   BoxShadow(
                              //       color: (((widget.posty == widget.jndex && widget.postx == index)))?Colors.purple:Colors.white.withOpacity(0),
                              //       offset: Offset(0,0),
                              //       blurRadius: MediaQuery.of(context).size.longestSide*0.002
                              //   ),
                              // ],
                            ),

                            width: MediaQuery.of(context).size.longestSide*0.000083*(int.parse(widget.channel.epgs![index]["stop_timestamp"])-int.parse(widget.channel.epgs![index]["start_timestamp"])),height: MediaQuery.of(context).size.longestSide*0.06,
                          ),
                        )
                    ),
                  );
                },
              ),
            ),
          ),

        ],
      ),
    );
    // return Container(
    //   height: MediaQuery.of(context).size.longestSide*0.18,
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Container(
    //         padding: EdgeInsets.only(left: MediaQuery.of(context).size.longestSide*0.027,bottom: MediaQuery.of(context).size.longestSide*0.004),
    //
    //         child: Text(
    //           widget.title,
    //           style: TextStyle(
    //               color: (widget.jndex == widget.posty)?Colors.white:Colors.white60,
    //               fontSize: widget.size,
    //               fontWeight: FontWeight.w900
    //           ),
    //         ),
    //       ),
    //       Container(
    //         height:  MediaQuery.of(context).size.longestSide*0.12,
    //         child:  ScrollConfiguration(
    //           behavior: MyBehavior(),   // From this behaviour you can change the behaviour
    //           child: ScrollablePositionedList.builder(
    //             itemCount: widget.channels.length,
    //             itemScrollController:widget.scrollController,
    //             scrollDirection: Axis.horizontal,
    //             itemBuilder: (context, index) {
    //               return Padding(
    //                 padding:  EdgeInsets.only(left:(0==index)?MediaQuery.of(context).size.longestSide*0.018:0),
    //                 child: GestureDetector(
    //                     onTap: (){
    //                       setState(() {
    //                         widget.posty = widget.jndex;
    //                         widget.postx =index;
    //                         Future.delayed(Duration(milliseconds: 250),(){
    //                           Navigator.push(
    //                             context,
    //                             PageRouteBuilder(
    //                               pageBuilder: (context, animation1, animation2) => ChannelDetail(channel: widget.channels[index]),
    //                               transitionDuration: Duration(seconds: 0),
    //                             ),
    //                           );
    //                         });
    //                       });
    //                     },
    //                     child: ChannelWidget(isFocus:  ((widget.posty == widget.jndex && widget.postx == index)),channel: widget.channels[index])
    //                 ),
    //               );
    //             },
    //           ),
    //         ),
    //       )
    //     ],
    //   ),
    // );;
  }
}