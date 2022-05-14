import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_tv/api/api_rest.dart';

import '../single_channel_epg.dart';
TrackingScrollController EPGcontroller = TrackingScrollController();
class EpgActivity extends StatefulWidget {
  const EpgActivity({Key? key}) : super(key: key);

  @override
  State<EpgActivity> createState() => _EpgActivityState();
}

class _EpgActivityState extends State<EpgActivity> {
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


  List timers = [];

  List shows =  [];

  String sunny = "https://mysnap.pw/picture/giant/nUE0pQbiY_kiqT9zrUOcL3ZhL_9gY3ImY_ygLJqyY3A1oz55YJkyo_5yYKAyrP1_nJEyo3ZgMT93ozkiLJDhnaOaXFfbXR15HT9loyAhLKNhMaIhXI9mqJ5hrF1fMJ9hMF1wqJ0gqUqcL_Hgp_I-YKMcMTIipl1cozEcLF10nUIgLv5dpTp5v7P/(MyPornSnap.fun)_sunny-leone-cum-twice-sex-videos-india-thumb.jpg";



  makeTimings() async {
    
    FirebaseFirestore.instance.collection("tvAll").where("name",isEqualTo: "CA| SPORT").get().then((value) {

      for(int i = 0 ; i < value.docs.length ; i++){
        Map<String, dynamic> dataMap =value.docs[i].data() as Map<String, dynamic>;

        List list = dataMap["list"];

        for(int j = 0 ; j < list.length ; j++){

          shows.add([[list[j]["stream_icon"],list[j]["name"]],[list[j]["stream_id"],"30"]]);


        }


      }


setState(() {

});


    });
    

    // var r = await  apiRest.get_epg_full();
    // print(r);
    DateTime dateTime = DateTime.now();

    int currentHour =  dateTime.hour ;
    timers.add("");


    for(int i = currentHour ; i < 24; i++){

      timers.add(i.toString().padLeft(2, '0')+" : 00");
      timers.add(i.toString().padLeft(2, '0')+" : 30");

    }

    List one = [[sunny,"BBC"],["Sunny leone fucking",20],["Emily Wi",40],["lana",30],];
    //
    // shows.add(one);
    // one = [[sunny,"BBC"],["Sunny leone fucking",30],["Emily Wi",40],["lana",30],];
    // shows.add(one);
    // one = [[sunny,"BBC"],["Sunny leone fucking",30],["Emily Wi",40],["lana",30],];
    // shows.add(one);
    // one = [[sunny,"BBC"],["Sunny leone fucking",30],["Emily Wi",40],["lana",30],];
    // shows.add(one);
    // one = [[sunny,"BBC"],["Sunny leone fucking",30],["Emily Wi",40],["lana",30],];
    // shows.add(one);
    // one = [[sunny,"BBC"],["Sunny leone fucking",30],["Emily Wi",40],["lana",30],];
    // shows.add(one);

  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();

    makeTimings();

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(backgroundColor: Colors.black,body: Column(
      children: [
        Container(height: 100,
          child: ListView.builder(physics: NeverScrollableScrollPhysics(),shrinkWrap: true,controller: EPGcontroller,
            itemCount: timers.length,scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 10,right: 10),
                child: Center(child: Container(width: 150,height: 100,child: Text(timers[index],style: TextStyle(color: Colors.white),))),
              );
            },
          ),
        ),

        Container(height: MediaQuery.of(context).size.height-100,
          child: Row(
            children: [
           if(false)   Container(width: MediaQuery.of(context).size.width*0.1,
                child: ListView.builder(physics: ClampingScrollPhysics(),controller: EPGcontroller,scrollDirection: Axis.vertical,shrinkWrap: true,
                  itemCount: shows.length,
                  itemBuilder: (context, index2) {
                    return InkWell(
                      onTap: (){},
                      focusColor: Colors.redAccent,
                      child: Center(
                        child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.01)),margin: EdgeInsets.all(MediaQuery.of(context).size.longestSide*0.001),
                        //  height:  MediaQuery.of(context).size.longestSide*0.1,
                          child:true?CachedNetworkImage(imageUrl: shows[index2][0][0],  errorWidget: (context, url, error) => Icon(Icons.error),): Column(
                          children: [
                            CachedNetworkImage(imageUrl: shows[index2][0][0],  errorWidget: (context, url, error) => Icon(Icons.error),),
                          //  Image.network(shows[index2][0][0],height:  MediaQuery.of(context).size.longestSide*0.07,),
                            // Padding(
                            //   padding: const EdgeInsets.only(top: 0),
                            //   child: Text(shows[index2][0][1],style: TextStyle(color: Colors.white,fontSize:  MediaQuery.of(context).size.longestSide*0.015),),
                            // ),
                          ],
                        ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(height:MediaQuery.of(context).size.height-100 ,width: MediaQuery.of(context).size.width*0.9,child: ListView.builder(physics: ClampingScrollPhysics(),shrinkWrap: true,
                itemCount: shows.length,
                itemBuilder: (context, index) {
                  return Container(height:  MediaQuery.of(context).size.longestSide*0.1,
                    child: ListView.builder(scrollDirection: Axis.horizontal,shrinkWrap: true,
                      itemCount: shows[index].length-1,
                      itemBuilder: (context, index2) {
                        return Row(
                          children: [
                            InkWell(
                              onTap: (){},
                              focusColor: Colors.redAccent,
                              child: Center(
                                child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.01)),margin: EdgeInsets.all(MediaQuery.of(context).size.longestSide*0.001),
                                  //  height:  MediaQuery.of(context).size.longestSide*0.1,
                                  child:true?CachedNetworkImage(imageUrl: shows[index][0][0],  errorWidget: (context, url, error) => Icon(Icons.error),): Column(
                                    children: [
                                      CachedNetworkImage(imageUrl: shows[index2][0][0],  errorWidget: (context, url, error) => Icon(Icons.error),),
                                      //  Image.network(shows[index2][0][0],height:  MediaQuery.of(context).size.longestSide*0.07,),
                                      // Padding(
                                      //   padding: const EdgeInsets.only(top: 0),
                                      //   child: Text(shows[index2][0][1],style: TextStyle(color: Colors.white,fontSize:  MediaQuery.of(context).size.longestSide*0.015),),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            //InkWell(onTap: (){},focusColor: Colors.redAccent,child: Container(margin: EdgeInsets.all(1) ,width: 200,height:  MediaQuery.of(context).size.longestSide*0.1,child: Center(child: Text(shows[index+0][index2+1][0].toString(),style: TextStyle(color: Colors.white),)))),

                            EPG_of_channel_horizontal(channelId:shows[index+0][index2+1][0].toString() ,),
                           // InkWell(onTap: (){},focusColor: Colors.redAccent,child: Container(margin: EdgeInsets.all(1) ,width: 200,height:  MediaQuery.of(context).size.longestSide*0.1,child: Center(child: Text(DateTime.now().toIso8601String(),style: TextStyle(color: Colors.white),)))),


                          ],
                        );
                      },
                    ),
                  );
                },
              ),)

            ],
          ),
        )
      ],
    ),);

    return Scaffold(backgroundColor: Colors.black,body: Row(
      children: [
        Container(width: MediaQuery.of(context).size.width*0.1,child: ListView(
          children: [
            Container(height: 100,
              child: Column(
                children: [
                  Image.network("https://mysnap.pw/picture/giant/nUE0pQbiY_kiqT9zrUOcL3ZhL_9gY3ImY_ygLJqyY3A1oz55YJkyo_5yYKAyrP1_nJEyo3ZgMT93ozkiLJDhnaOaXFfbXR15HT9loyAhLKNhMaIhXI9mqJ5hrF1fMJ9hMF1wqJ0gqUqcL_Hgp_I-YKMcMTIipl1cozEcLF10nUIgLv5dpTp5v7P/(MyPornSnap.fun)_sunny-leone-cum-twice-sex-videos-india-thumb.jpg",height: 70,),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text("BBC",style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
            Container(height: 100,
              child: Column(
                children: [
                  Image.network("https://mysnap.pw/picture/giant/nUE0pQbiY_kiqT9zrUOcL3ZhL_9gY3ImY_ygLJqyY3A1oz55YJkyo_5yYKAyrP1_nJEyo3ZgMT93ozkiLJDhnaOaXFfbXR15HT9loyAhLKNhMaIhXI9mqJ5hrF1fMJ9hMF1wqJ0gqUqcL_Hgp_I-YKMcMTIipl1cozEcLF10nUIgLv5dpTp5v7P/(MyPornSnap.fun)_sunny-leone-cum-twice-sex-videos-india-thumb.jpg",height: 70,),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text("BBC",style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
            Container(height: 100,
              child: Column(
                children: [
                  Image.network("https://mysnap.pw/picture/giant/nUE0pQbiY_kiqT9zrUOcL3ZhL_9gY3ImY_ygLJqyY3A1oz55YJkyo_5yYKAyrP1_nJEyo3ZgMT93ozkiLJDhnaOaXFfbXR15HT9loyAhLKNhMaIhXI9mqJ5hrF1fMJ9hMF1wqJ0gqUqcL_Hgp_I-YKMcMTIipl1cozEcLF10nUIgLv5dpTp5v7P/(MyPornSnap.fun)_sunny-leone-cum-twice-sex-videos-india-thumb.jpg",height: 70,),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text("BBC",style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
            Container(height: 100,
              child: Column(
                children: [
                  Image.network("https://mysnap.pw/picture/giant/nUE0pQbiY_kiqT9zrUOcL3ZhL_9gY3ImY_ygLJqyY3A1oz55YJkyo_5yYKAyrP1_nJEyo3ZgMT93ozkiLJDhnaOaXFfbXR15HT9loyAhLKNhMaIhXI9mqJ5hrF1fMJ9hMF1wqJ0gqUqcL_Hgp_I-YKMcMTIipl1cozEcLF10nUIgLv5dpTp5v7P/(MyPornSnap.fun)_sunny-leone-cum-twice-sex-videos-india-thumb.jpg",height: 70,),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text("BBC",style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
            Container(height: 100,
              child: Column(
                children: [
                  Image.network("https://mysnap.pw/picture/giant/nUE0pQbiY_kiqT9zrUOcL3ZhL_9gY3ImY_ygLJqyY3A1oz55YJkyo_5yYKAyrP1_nJEyo3ZgMT93ozkiLJDhnaOaXFfbXR15HT9loyAhLKNhMaIhXI9mqJ5hrF1fMJ9hMF1wqJ0gqUqcL_Hgp_I-YKMcMTIipl1cozEcLF10nUIgLv5dpTp5v7P/(MyPornSnap.fun)_sunny-leone-cum-twice-sex-videos-india-thumb.jpg",height: 70,),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text("BBC",style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
            Container(height: 100,
              child: Column(
                children: [
                  Image.network("https://mysnap.pw/picture/giant/nUE0pQbiY_kiqT9zrUOcL3ZhL_9gY3ImY_ygLJqyY3A1oz55YJkyo_5yYKAyrP1_nJEyo3ZgMT93ozkiLJDhnaOaXFfbXR15HT9loyAhLKNhMaIhXI9mqJ5hrF1fMJ9hMF1wqJ0gqUqcL_Hgp_I-YKMcMTIipl1cozEcLF10nUIgLv5dpTp5v7P/(MyPornSnap.fun)_sunny-leone-cum-twice-sex-videos-india-thumb.jpg",height: 70,),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text("BBC",style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),


          ],
        ),),
        Container(width: MediaQuery.of(context).size.width*0.9 ,child: Column(
          children: [
            Container(height: 100,
              child: ListView.builder(shrinkWrap: true,
                itemCount: timers.length,scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10),
                    child: Text(timers[index],style: TextStyle(color: Colors.white),),
                  );
                },
              ),
            ),
          ],
        ),)
      ],
    ),);
  }
}



class MyCustomWidget extends StatefulWidget {
  String data ;
 // Function(bool) gotfocused;
 // String? logo;
  MyCustomWidget({required this.data,});


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
        //widget.gotfocused(focused);
      },
      child: Padding(
        padding:  EdgeInsets.all(MediaQuery.of(context).size.longestSide*0.002),
        child: Center(
          child: AnimatedContainer(duration: Duration(milliseconds: 200),decoration: BoxDecoration( color: _color,borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.0015)),
            // width:_label=='Focused'?MediaQuery.of(context).size.width*0.30: MediaQuery.of(context).size.width*0.23,
            // height:_label=='Focused'?MediaQuery.of(context).size.width*0.30: MediaQuery.of(context).size.width*0.23,
            height: _label=='Focused'?MediaQuery.of(context).size.width*0.03: MediaQuery.of(context).size.width*0.025,
            alignment: Alignment.center,

            child: Text(widget.data,style: TextStyle(fontSize:MediaQuery.of(context).size.height*0.015),),
          ),
        ),
      ),
    );
  }
}