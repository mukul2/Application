import 'dart:convert';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_tv/model/category.dart';
import 'package:flutter_app_tv/model/channel.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart' as vP;
import 'package:http/http.dart' as http;
import '../model/country.dart';
import '../single_channel_epg.dart';
import '../ui/player/video_player.dart';
import 'package:flutter_app_tv/api/api_rest.dart';

import 'package:flutter_app_tv/model/source.dart' as modelS;

import '../widget/navigation_widget.dart';
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
    }, child: Activity()),);
  }
}

class Activity extends StatefulWidget {
  const Activity({Key? key}) : super(key: key);
  
 


  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  bool? logged;
  Image image = Image.asset("assets/images/profile.jpg");
  String nowInitialingLink = "";
  late vP.VideoPlayerController _controller;
  List<String> level_2 = ["2-1","2-2","2-3","2-4"];
  ScrollController controller1 = ScrollController();
  ScrollController controller2 = ScrollController();
  List folders = [];
  int currectSelection_1 = -1;
  int currectSelection_2 = -1;
  modelS.Source? source ;
  Channel? channel;

  bool controllerInited = false;

  String epg = "";
  List epgs = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadFolders();
  }
  downloadFolders() async {
    print("download started");

    makeUI({required List dataMap}){

      setState(() {
        folders = dataMap;
      });

    }

    if( await apiRest.checkFile("tv.json") == false){
    List allSeriesCategory =  await apiRest.getTVCateDetails();
    makeUI(dataMap: allSeriesCategory);
    }else{
    File f = await apiRest.localFile("tv.json");
    String data = await f.readAsString();
    try{
    makeUI(dataMap: jsonDecode(data));
    }catch(e){
    }
    apiRest.getTVCateDetails();
    }






  if(false)  FirebaseFirestore.instance.collection("tvAll").get().then((value) {
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



    return Scaffold(backgroundColor: Colors.black,body: Stack(
      children: [

        Positioned(top: 50+MediaQuery.of(context).viewPadding.top,child: SingleChildScrollView(
          child: Container(width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height-(50+MediaQuery.of(context).viewPadding.top),
            child: Row(
              children: [
                Expanded(child: folders.length==0 ?Center(child: CupertinoActivityIndicator(color: Colors.white,),): ListView.builder(controller: controller1,
                  itemCount: folders.length,shrinkWrap: true,scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return Center(child: MyCustomWidget(data: folders[index]["name"],gotfocused: (val){
                      if(val==true){
                        controllerInited = false;
                        setState(() {
                          currectSelection_1 = index;
                          currectSelection_2 = -1;
                        });
                        //   controller1.animateTo(MediaQuery.of(context).size.width*4+(MediaQuery.of(context).size.width*0.23)*index, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);

                      }


                    },) ,);
                  },
                )),
                Expanded(child: currectSelection_1==-1 ?Center(child: CupertinoActivityIndicator(color: Colors.white,),): ListView.builder(controller: controller1,
                  itemCount: folders[currectSelection_1]["list"].length,shrinkWrap: true,scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return Center(child: MyCustomWidget(logo:folders[currectSelection_1]["list"][index]["stream_icon"] ,data:folders[currectSelection_1]["list"][index]["name"],gotfocused: (val) async {
                      if(val==true){

                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

                        String? server =  sharedPreferences.getString("SERVER_URL");
                        String? port =  sharedPreferences.getString("PORT");
                        String? USER_ID =  sharedPreferences.getString("USER_ID");
                        String? PASSWORD =  sharedPreferences.getString("PASSWORD");

                        String m3uFile = "http://"+server!+":$port"+"/"+folders[currectSelection_1]["list"][index]["stream_type"]+"/"+USER_ID!+"/"+PASSWORD.toString() +"/"+folders[currectSelection_1]["list"][index]["stream_id"].toString()+".m3u8";


                        print(m3uFile);
                        controllerInited = false;
                        setState(() {
                          currectSelection_2 = index;

                        });
                        String castLink = "http://$server/player_api.php?username=$USER_ID&password=$PASSWORD&action=get_short_epg&stream_id="+folders[currectSelection_1]["list"][index]["stream_id"].toString()+"&limit=10";
                        print(castLink);
                        var responseEPG = await http.get(Uri.parse(castLink), );
                        print("sort epg res "+ responseEPG.body);
                        epg = responseEPG.body;
                        dynamic dd = jsonDecode(epg);
                        epgs = dd["epg_listings"];


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



                        if(controllerInited==true &&  _controller!=null){
                          print("need to remove old controler");
                          vP.VideoPlayerController oldcontroller = _controller!;

                          // Registering a callback for the end of next frame
                          // to dispose of an old controller
                          // (which won't be used anymore after calling setState)
                          WidgetsBinding.instance!.addPostFrameCallback((_) async {
                            await oldcontroller.dispose();

                            // Initing new controller
                            // Initing new controller

                            nowInitialingLink = m3uFile;
                            _controller = vP.VideoPlayerController.network(m3uFile)
                              ..initialize().then((_) {
                                print("inited 2");
                                // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                                setState(() {});
                                _controller!.play();
                                controllerInited = true;
                                setState(() {


                                });
                              });
                          });

                          // Making sure that controller is not used by setting it to null
                          setState(() {
                            // _controller = null;
                          });
                        }else{
                          print("no need to clear");
                          WidgetsBinding.instance!.addPostFrameCallback((_) async {


                            // Initing new controller
                            // Initing new controller
                            nowInitialingLink = m3uFile;
                            _controller = vP.VideoPlayerController.network(m3uFile)
                              ..initialize().then((_) {
                                print("inited");
                                // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                                setState(() {});
                                _controller!.play();
                                controllerInited = true;
                                setState(() {


                                });
                              });
                          });
                        }








                        // WidgetsBinding.instance!.addPostFrameCallback((_) async {
                        //
                        //
                        //      // Initing new controller
                        //      _controller = vP.VideoPlayerController.network(m3uFile)
                        //        ..initialize().then((_) {
                        //          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                        //          setState(() {});
                        //          _controller.play();
                        //          controllerInited = true;
                        //          setState(() {
                        //            currectSelection_2 = index;
                        //
                        //          });
                        //        });
                        //
                        //
                        //
                        //
                        //
                        // });


                        //   controller1.animateTo(MediaQuery.of(context).size.width*4+(MediaQuery.of(context).size.width*0.23)*index, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);

                      }


                    },) ,);
                  },
                )),
                Expanded(child: currectSelection_2==-1 ?Center(child: CupertinoActivityIndicator(color: Colors.white,),):Padding(
                  padding:  EdgeInsets.all(MediaQuery.of(context).size.longestSide*0.002),
                  child: SingleChildScrollView(
                    child: Column(children: [

                      (controllerInited==true && _controller!=null &&   _controller.value.isInitialized == true)? InkWell(onTap: (){

                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) => VideoPlayer(subtitles: [],sourcesList:channel!.sources,selected_source:0,focused_source: 0,channel:channel),
                            transitionDuration: Duration(seconds: 0),
                          ),
                        );




                      },child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: vP.VideoPlayer(_controller),
                      ),) : CupertinoActivityIndicator(color: Colors.white,),
                      SingleChildScrollView(
                        child: ListView.builder(shrinkWrap: true,
                          itemCount: epgs.length,
                          itemBuilder: (context, index) {
                            print(epgs[index]["start_timestamp"]);

                            return InkWell(onTap: (){

                            },focusColor: Colors.redAccent,
                              child: Container(margin: EdgeInsets.all(MediaQuery.of(context).size.height*0.0085),
                                child: Padding(
                                  padding:  EdgeInsets.only(left: MediaQuery.of(context).size.height*0.0016,right: MediaQuery.of(context).size.height*0.0016,top: MediaQuery.of(context).size.height*0.0085),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(utf8.decode(base64.decode(epgs[index]["title"])),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.02),),
                                      Text(utf8.decode(base64.decode(epgs[index]["description"])),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
                                      Row(
                                        children: [
                                          Text(   DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(60000+int.parse(epgs[index]["start_timestamp"])*1000)),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
                                          Text(  " - ",style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
                                          Text(   DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(60000+int.parse(epgs[index]["stop_timestamp"])*1000)),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),


                                        ],
                                      ),
                                      // Text( epgs[index]["start_timestamp"],style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
                                      //Text( epgs[index].toString(),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),

                                    ],
                                  ),
                                ),
                              ),
                            );
                            return ListTile(subtitle:Text(utf8.decode(base64.decode(epgs[index]["description"])),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),) ,
                              title: Text(utf8.decode(base64.decode(epgs[index]["title"])),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
                            );
                          },
                        ),
                      ),
                      // Text(folders[currectSelection_1]["list"][currectSelection_2].toString(),style: TextStyle(color: Colors.white),)


                    ],),
                  ),
                )),
              ],
            ),
          ),
        )),


        NavigationWidget(postx:4,posty:-2,selectedItem : 4,image : image, logged : logged,),
      ],
    ),);
  }
}

class MyCustomWidget extends StatefulWidget {
  String data ;
  Function(bool) gotfocused;
  String? logo;

  FocusNode? focusNode ;
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

      print("change ??");
        setState(() {
          _color = focused ? Colors.white : Colors.grey;
          _label = focused ? 'Focused' : 'Unfocused';
        });
        widget.gotfocused(focused);
      },
      child: InkWell(onTap: (){
        print("clicked ");
        setState(() {
          _label =  'Focused';
        });
        widget.gotfocused(true);
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

                  Center(child: Text(widget.data,style: TextStyle(color: _label=='Focused'?Colors.white:Colors.black,fontSize:MediaQuery.of(context).size.height*0.03),)),
                ],
              ) :Center(child: Text(widget.data,style: TextStyle(color: _label=='Focused'?Colors.white:Colors.black,fontSize:MediaQuery.of(context).size.height*0.03),)),
            ),
          ),
        ),
      ),
    );
  }
}