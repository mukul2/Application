import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_tv/model/category.dart';
import 'package:flutter_app_tv/model/channel.dart';

import '../model/country.dart';
import '../ui/player/video_player.dart';
import 'package:flutter_app_tv/model/source.dart' as modelS;
class SlingTv extends StatefulWidget {
  const SlingTv({Key? key}) : super(key: key);

  @override
  State<SlingTv> createState() => _SlingTvState();
}

class _SlingTvState extends State<SlingTv> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home:  Shortcuts(shortcuts: <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
    }, child: MaterialApp(
      title: 'SFlix',debugShowCheckedModeBanner: false,
      home: Activity()
    )),);
  }
}

class Activity extends StatefulWidget {
  const Activity({Key? key}) : super(key: key);
  
 


  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {

  List<String> level_2 = ["2-1","2-2","2-3","2-4"];
  ScrollController controller1 = ScrollController();
  ScrollController controller2 = ScrollController();
  List folders = [];
  int currectSelection_1 = -1;
  int currectSelection_2 = -1;
  modelS.Source? source ;
  Channel? channel;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadFolders();
  }
  downloadFolders(){
    print("download started");
    FirebaseFirestore.instance.collection("tvAll").get().then((value) {
      folders.clear();
      for(int i = 0 ; i < value.docs.length ; i++){
        Map<String, dynamic> dataMap =value.docs[i].data() as Map<String, dynamic>;

        folders.add(dataMap);
      }

      setState(() {

      });
      print("download finished");

    });

  }
  @override
  Widget build(BuildContext context) {



    return Scaffold(backgroundColor: Colors.black,body: Row(
      children: [
        Expanded(child: folders.length==0 ?Center(child: CupertinoActivityIndicator(color: Colors.white,),): ListView.builder(controller: controller1,
          itemCount: folders.length,shrinkWrap: true,scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return Center(child: MyCustomWidget(data: folders[index]["name"],gotfocused: (val){
                if(val==true){

                  setState(() {
                    currectSelection_1 = index;
                  });
               //   controller1.animateTo(MediaQuery.of(context).size.width*4+(MediaQuery.of(context).size.width*0.23)*index, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);

                }


              },) ,);
          },
        )),
        Expanded(child: currectSelection_1==-1 ?Center(child: CupertinoActivityIndicator(color: Colors.white,),): ListView.builder(controller: controller1,
          itemCount: folders[currectSelection_1]["list"].length,shrinkWrap: true,scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return Center(child: MyCustomWidget(data:folders[currectSelection_1]["list"][index]["name"],gotfocused: (val){
              if(val==true){
                String SERVER = "http://connect.proxytx.cloud";
                String PORT = "80";
                String EMAIL = "4fe8679c08";
                String PASSWORD = "2016";
                String m3uFile = SERVER+":$PORT"+"/"+folders[currectSelection_1]["list"][index]["stream_type"]+"/"+EMAIL+"/"+PASSWORD.toString() +"/"+folders[currectSelection_1]["list"][index]["stream_id"].toString()+".m3u8";

                source = modelS.Source(id: 1,
                    type: "LIVE",
                    title: folders[currectSelection_1]["list"][index]["name"],
                    size: null,
                    quality: "FHD",  kind: "both",
                    premium: "1",
                    external: false,
                    url: m3uFile);
                 channel = Channel(countries: [Country(id: 1,title: "UK", image: '')],id: 0,comment: false,title:folders[currectSelection_1]["list"][index]["name"],image:(folders[currectSelection_1]["list"][index]["stream_icon"].toString().length>0)?folders[currectSelection_1]["list"][index]["stream_icon"]: "https://i5.walmartimages.com/asr/74d5a667-7df8-44f2-b9db-81f26878d316_1.c7233452b7b19b699ef96944c8cbbe74.jpeg", categories: [Category(id: 1, title: "Sports")], duration: '', classification: '', rating: 4.3, sources:
                [
                  source!
                ], description: 'Description', sublabel: null, type: '', playas: '', website: '', downloadas: '', label: '' );
                setState(() {
                  currectSelection_2 = index;

                });
                //   controller1.animateTo(MediaQuery.of(context).size.width*4+(MediaQuery.of(context).size.width*0.23)*index, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);

              }


            },) ,);
          },
        )),
        Expanded(child: currectSelection_2==-1 ?Center(child: CupertinoActivityIndicator(color: Colors.white,),):Center(child: VideoPlayer(subtitles: [],selected_subtitle: 0,sourcesList: [source!],selected_source:0,focused_source: 0,channel:channel!),)),
      ],
    ),);
  }
}

class MyCustomWidget extends StatefulWidget {
  String data ;
  Function(bool) gotfocused;
  MyCustomWidget({required this.data,required this.gotfocused});


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
      child: Padding(
        padding:  EdgeInsets.all(MediaQuery.of(context).size.longestSide*0.001),
        child: Center(
          child: AnimatedContainer(duration: Duration(milliseconds: 200),decoration: BoxDecoration( color: _color,borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.0015)),
           // width:_label=='Focused'?MediaQuery.of(context).size.width*0.30: MediaQuery.of(context).size.width*0.23,
           // height:_label=='Focused'?MediaQuery.of(context).size.width*0.30: MediaQuery.of(context).size.width*0.23,
            height: _label=='Focused'?MediaQuery.of(context).size.width*0.03: MediaQuery.of(context).size.width*0.025,
            alignment: Alignment.center,

            child: Center(child: Text(widget.data,style: TextStyle(fontSize:MediaQuery.of(context).size.height*0.02),)),
          ),
        ),
      ),
    );
  }
}