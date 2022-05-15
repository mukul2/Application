import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_tv/api/api_rest.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'EPG/epg.dart';
class EPG_of_channel extends StatefulWidget {
  String channelId ;
  EPG_of_channel({required this.channelId});

  @override
  State<EPG_of_channel> createState() => _EPG_of_channelState();
}

class _EPG_of_channelState extends State<EPG_of_channel> {

  List epgs = [];

  bool epgDownlaoded = false;

  @override
  void initState() {
    print("title inited");
    // TODO: implement initState
    getEpgs();
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return epgs.length>0? ListView.builder(shrinkWrap: true,
      itemCount: epgs.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(epgs[index]["title"],style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.03),),
        );
      },
    ):Center(child: Text("No EPG",style:  TextStyle(color:epgDownlaoded? Colors.white:Colors.redAccent,fontSize:MediaQuery.of(context).size.height*0.03),),);
  }

  Future<void> getEpgs() async {
    print("getting rpd");

    epgs =  jsonDecode(widget.channelId);
    print("Downloaded epg");
    setState(() {
      epgDownlaoded = true;
    });


  }
}



class EPG_of_channel_horizontal extends StatefulWidget {
  String channelId ;
  EPG_of_channel_horizontal({required this.channelId});

  @override
  State<EPG_of_channel_horizontal> createState() => _EPG_of_channel_horizontalState();
}

class _EPG_of_channel_horizontalState extends State<EPG_of_channel_horizontal> {

  List epgs = [];

  bool epgDownlaoded = false;

  @override
  void initState() {
    print("title inited");
    // TODO: implement initState
    getEpgs();
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return epgs.length>0? ListView.builder(shrinkWrap: true,
      itemCount: epgs.length,scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
      return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.005)),
        child: InkWell(onTap: (){},focusColor: Colors.redAccent,child:  Container(margin: EdgeInsets.all(MediaQuery.of(context).size.width*0.002),decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2),borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.005)),width: MediaQuery.of(context).size.width*0.00007*((int.parse(epgs[index]["stop_timestamp"])-int.parse(epgs[index]["start_timestamp"]))),child:

        Center(
          child: Wrap(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(utf8.decode(base64.decode(epgs[index]["title"])),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.02),),
              Text(   DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(60000+int.parse(epgs[index]["start_timestamp"])*1000)),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
              Text(  " - ",style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
              Text(   DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(60000+int.parse(epgs[index]["stop_timestamp"])*1000)),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
              Text( "( "+( (int.parse(epgs[index]["stop_timestamp"])-int.parse(epgs[index]["start_timestamp"]))/60).toStringAsFixed(0)+" min )",style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),


            ],
          ),
        ))),
      );
        return ListTile(
          title: Text(epgs[index]["title"],style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.03),),
        );
      },
    ):Center(child: Text("---",style:  TextStyle(color:epgDownlaoded? Colors.white:Colors.redAccent,fontSize:MediaQuery.of(context).size.height*0.03),),);
  }

  Future<void> getEpgs() async {
    print("getting rpd");
    String castLink = "http://connect.proxytx.cloud/player_api.php?username=4fe8679c08&password=2016&action=get_short_epg&stream_id="+widget.channelId+"&limit=10";
    print(castLink);
    var responseEPG = await http.get(Uri.parse(castLink), );
    dynamic dd  =  jsonDecode(responseEPG.body);
    print(responseEPG.body);
    epgs  =dd["epg_listings"];
    print("Downloaded epg");
    if(mounted) setState(() {
      epgDownlaoded = true;
    });


  }
}