import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_tv/model/genre.dart';
import 'package:flutter_app_tv/model/poster.dart';
import 'package:flutter_app_tv/ui/channel/channel_detail.dart';
import 'package:flutter_app_tv/ui/movie/movie.dart';
import 'package:flutter_app_tv/ui/serie/serie.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MovieShortDetailMiniWidget extends StatelessWidget {
  Poster? movie;
  String genres ="";
  String TMDB ="";


  MovieShortDetailMiniWidget({this.movie}){
      for(Genre g in movie!.genres){
        genres = genres + " • "+g.title;

      }
  }
  Future<dynamic>  searchMovieInTMDB({required String title}) async {

    List alls = title.split("-");
    String second = alls.last;

    List qq = second.split("(");

    List kk = qq.first.toString().split(" ");
    String key ="" ;
    for(int i = 0 ; i < kk.length ; i++){

      if(kk[i].toString().trim()!="4K"){
        if(i==1){
          if(kk[i].toString().length>0) key = kk[i];
        }else{
          if(kk[i].toString().length>0) key = key+"+"+kk[i];
        }

      }




    }

    key = key.replaceAll("++", "+");
    key = key.replaceAll(":", "");
    key = key.replaceAll("(", "");
    key = key.replaceAll(")", "");

    print(key);




    String tvSHowTMDB = "https://api.themoviedb.org/3/search/movie?api_key=103096910bbe8842c151f7cce00ab218&query="+key;
    print(tvSHowTMDB);

    var responseTMDB = await http.get(Uri.parse(tvSHowTMDB) );

    dynamic jsonTMDB = jsonDecode(responseTMDB.body);
    String tmdbId="";
    if(jsonTMDB["total_results"]>0){

      tmdbId = jsonTMDB["results"][0]["id"].toString();
      String tvSHowTMDBFull = "https://api.themoviedb.org/3/movie/$tmdbId?api_key=103096910bbe8842c151f7cce00ab218";
      print(tvSHowTMDBFull);
      TMDB = tmdbId;
      var responseTMDFF = await http.get(Uri.parse(tvSHowTMDBFull), );
      print(responseTMDFF.body);

    //  await FirebaseFirestore.instance.collection("moreInfoSeries").doc(seriedID).set({"fullSeries":responseTMDFF.body});

     return jsonDecode(responseTMDFF.body);
    }else{
      String tvSHowTMDBFull = "https://api.themoviedb.org/3/movie/414906?api_key=103096910bbe8842c151f7cce00ab218";
      print(tvSHowTMDBFull);
      TMDB = tmdbId;
      var responseTMDFF = await http.get(Uri.parse(tvSHowTMDBFull), );
      print(responseTMDFF.body);

      //  await FirebaseFirestore.instance.collection("moreInfoSeries").doc(seriedID).set({"fullSeries":responseTMDFF.body});

      return jsonDecode(responseTMDFF.body);
    }





    cach() async {
      String ll = "http://connect.proxytx.cloud/player_api.php?username=4fe8679c08&password=2016&get_vod_info&vod_id="+(movie!.id).toString();
      print(ll);


      //   String link = "https://api.themoviedb.org/3/search/movie?api_key=103096910bbe8842c151f7cce00ab218&query="+key;


      // final responseTMDB = await http.get(Uri.parse(link));
      // print(responseTMDB.body);
      final responseOneMovie = await http.get(Uri.parse(ll));
      print(ll);
      print(responseOneMovie.body);
      dynamic movieInfo = jsonDecode(responseOneMovie.body);
      print("just downloaded");
      print(movieInfo);
      print(movieInfo["info"]["tmdb_id"]);
      await FirebaseFirestore.instance.collection("moreInfo").doc((movie!.id).toString()).set(movieInfo);
      await FirebaseFirestore.instance.collection("moreInfo").doc((movie!.id).toString()).update({"tmdbId":movieInfo["info"]["tmdb_id"]});


      String tmdb = movieInfo["info"]["tmdb_id"];

      String detail = "https://api.themoviedb.org/3/movie/$tmdb?api_key=103096910bbe8842c151f7cce00ab218";
      print("need to cache "+detail);
      http.Response responseTMDBBig;
      responseTMDBBig = await http.get(Uri.parse(detail));
      // movieInfo["full"]=responseTMDBBig.body;
      await FirebaseFirestore.instance.collection("moreInfo").doc((movie!.id).toString()).update({"full":responseTMDBBig.body});
    }
    print("searchMovieInTMDB "+(movie!.id).toString());

    DocumentSnapshot moreInfo = await FirebaseFirestore.instance.collection("moreInfo").doc((movie!.id).toString()).get();
    if(moreInfo.exists){
      print("searchMovieInTMDB ok");
      Map<String, dynamic> data = moreInfo.data() as Map<String, dynamic>;

      if(data.containsKey("full")){
        return data;
      }else{
        Map<String, dynamic> data = moreInfo.data() as Map<String, dynamic>;


        if(data.containsKey("info")==false){
          cach();
        }
        DocumentSnapshot moreInfo3 = await FirebaseFirestore.instance.collection("moreInfo").doc((movie!.id).toString()).get();
        Map<String, dynamic> data2 = moreInfo3.data() as Map<String, dynamic>;
        print("searchMovieInTMDB else");
        print(data2["info"]);
        print(data2);
        print(data2["info"]["tmdb_id"]);
        String t = data2["info"]["tmdb_id"];
        String detail = "https://api.themoviedb.org/3/movie/$t?api_key=103096910bbe8842c151f7cce00ab218";

        http.Response responseTMDBBig;
        responseTMDBBig = await http.get(Uri.parse(detail));

        await FirebaseFirestore.instance.collection("moreInfo").doc((movie!.id).toString()).update({"full":responseTMDBBig.body});
        DocumentSnapshot moreInfo2 = await FirebaseFirestore.instance.collection("moreInfo").doc((movie!.id).toString()).get();
        Map<String, dynamic> dataR = moreInfo2.data() as Map<String, dynamic>;
        print("repaired one cache");
        return dataR;
      }



    }else{

      print("need to cache "+movie!.id.toString());
      try{




        cach();


        //returnValue =  jsonDecode(responseTMDBBig.body);

        DocumentSnapshot moreInfo2 = await FirebaseFirestore.instance.collection("moreInfo").doc((movie!.id).toString()).get();
        Map<String, dynamic> data = moreInfo2.data() as Map<String, dynamic>;
        print("made one cache");
        return data;
      }catch(e){
        print("11");
        print("error while cacing");
        print(e);

      }
    }







    //
    //
    // List alls = title.split("-");
    // String second = alls.last;
    // List kk = second.split(" ");
    // String key ="" ;
    // for(int i = 0 ; i < kk.length ; i++){
    //   key = key+"+"+kk[i];
    //
    // }
    // key = key.replaceAll("++", "");
    //
    // print(key);
    // String link = "https://api.themoviedb.org/3/search/movie?api_key=103096910bbe8842c151f7cce00ab218&query="+key;
    // print(link);
    // final responseTMDB = await http.get(Uri.parse(link));
    // print(responseTMDB.body);
    // dynamic movieInfo = jsonDecode(responseTMDB.body);
    // if(movieInfo["results"].length>0){
    //   print(movieInfo["results"][0]);
    // }
    // return movieInfo["results"][0];

  }
  @override
  Widget build(BuildContext context) {
    print("should only work at movies");


    return FutureBuilder<dynamic>(
      future: searchMovieInTMDB(title: movie!.title), // async work
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

        if(snapshot.connectionState == ConnectionState.done  && snapshot.hasData){
          //String more = snapshot.data["full"];

         // dynamic moreDataMap = jsonDecode(more);
         // print(moreDataMap);
          List genresA = snapshot.data["genres"];
          String gg = "";
          for(int i = 0 ; i < genresA.length ; i++){
            gg = gg + " • "+genresA[i]["name"].toString();
          }

          return Container(
            width:  MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(left: 50,right: 50),
            child: Stack(
              children: [
                Container(
                  height: 170,
                  margin:  EdgeInsets.only(right: MediaQuery.of(context).size.width/5),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(snapshot.data["original_title"],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text(movie!.rating.toString() +" / 5", style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800
                          ),),
                          RatingBar.builder(
                            initialRating: 3.5,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 15.0,
                            ignoreGestures: true,
                            unratedColor: Colors.amber.withOpacity(0.4),
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                          SizedBox(width: 10),
                          Text("  •   "+snapshot.data["vote_average"].toString()+" / 10", style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800
                          ),
                          )
                          ,
                          SizedBox(width: 5),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 2,horizontal: 5),
                            decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: Text("IMDb", style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800
                            ),
                            ),
                          )

                        ],
                      ),
                      SizedBox(height: 10),

                    if(true)  Text("${DateFormat("yyyy").format(DateTime.parse(snapshot.data["release_date"]))} • ${snapshot.data["runtime"] }min ${gg}"
                        , style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900
                        ),),
                      SizedBox(height: 10),
                      Text(snapshot.data["overview"]
                        , style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            height: 1.5,
                            fontWeight: FontWeight.normal
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: (){

                      if(movie != null){
                        Future.delayed(Duration(milliseconds: 50),(){
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) => (movie!.type == "serie")? Serie(serie: movie):Movie(movie: movie),
                              transitionDuration: Duration(seconds: 0),
                            ),
                          );
                        });
                      }
                    },
                    child: Container(
                      child: Row(
                        children: [
                          Container(
                            height: 35,
                            width: 35,
                            child: Center(child: Icon(Icons.info_outline,size: 20,color:Colors.white)),
                            decoration: BoxDecoration(
                                border: Border(right: BorderSide(width: 1,color:Colors.black12))
                            ),
                          ),
                          Expanded(
                              child: Center(
                                  child: Text(
                                    "More details",
                                    style: TextStyle(
                                        color:Colors.white,
                                        fontWeight: FontWeight.w500
                                    ),
                                  )
                              )
                          )
                        ],
                      ),
                      height: 35,
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white30,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }else{
        return Text('Loading....');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Text('Loading....');
          default:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else
              print(snapshot.data);
            String more = snapshot.data["full"];

            dynamic moreDataMap = jsonDecode(more);
            print(moreDataMap);
              return Container(
                width:  MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(left: 50,right: 50),
                child: Stack(
                  children: [
                    Container(
                      height: 170,
                      margin:  EdgeInsets.only(right: MediaQuery.of(context).size.width/5),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(movie!.title,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Text(movie!.rating.toString() +" / 5", style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800
                              ),),
                              RatingBar.builder(
                                initialRating: 3.5,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 15.0,
                                ignoreGestures: true,
                                unratedColor: Colors.amber.withOpacity(0.4),
                                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  print(rating);
                                },
                              ),
                              SizedBox(width: 10),
                              Text("  •   "+moreDataMap["vote_average"].toString()+" / 10", style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800
                              ),
                              )
                              ,
                              SizedBox(width: 5),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 2,horizontal: 5),
                                decoration: BoxDecoration(
                                    color: Colors.orangeAccent,
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                child: Text("IMDb", style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800
                                ),
                                ),
                              )

                            ],
                          ),
                          SizedBox(height: 10),

                          Text("${DateFormat("yyyy").format(DateTime.parse(snapshot.data["info"]["releasedate"]))} • ${movie!.classification} • ${snapshot.data["info"]["duration"]} ${genres}"
                            , style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900
                            ),),
                          SizedBox(height: 10),
                          Text(moreDataMap["overview"]
                            , style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                height: 1.5,
                                fontWeight: FontWeight.normal
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: (){

                          if(movie != null){
                            Future.delayed(Duration(milliseconds: 50),(){
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) => (movie!.type == "serie")? Serie(serie: movie):Movie(movie: movie),
                                  transitionDuration: Duration(seconds: 0),
                                ),
                              );
                            });
                          }
                        },
                        child: Container(
                          child: Row(
                            children: [
                              Container(
                                height: 35,
                                width: 35,
                                child: Center(child: Icon(Icons.info_outline,size: 20,color:Colors.white)),
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1,color:Colors.black12))
                                ),
                              ),
                              Expanded(
                                  child: Center(
                                      child: Text(
                                        "More details",
                                        style: TextStyle(
                                            color:Colors.white,
                                            fontWeight: FontWeight.w500
                                        ),
                                      )
                                  )
                              )
                            ],
                          ),
                          height: 35,
                          width: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white30,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
        }
      },
    );
    return Container(
      width:  MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: 50,right: 50),
      child: Stack(
        children: [
          Container(
            height: 170,
            margin:  EdgeInsets.only(right: MediaQuery.of(context).size.width/5),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie!.title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Text(movie!.rating.toString() +" / 5", style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800
                    ),),
                    RatingBar.builder(
                      initialRating: 3.5,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 15.0,
                      ignoreGestures: true,
                      unratedColor: Colors.amber.withOpacity(0.4),
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    ),
                    SizedBox(width: 10),
                    Text("  •   "+movie!.imdb.toString() +" / 10", style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800
                    ),
                    )
                    ,
                    SizedBox(width: 5),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 2,horizontal: 5),
                      decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Text("IMDb", style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800
                      ),
                      ),
                    )

                  ],
                ),
                SizedBox(height: 10),
                Text("${movie!.year} • ${movie!.classification} • ${movie!.duration} ${genres}"
                  , style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900
                  ),),
                SizedBox(height: 10),
                Text(movie!.description
                  , style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      height: 1.5,
                      fontWeight: FontWeight.normal
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: (){

                if(movie != null){
                  Future.delayed(Duration(milliseconds: 50),(){
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => (movie!.type == "serie")? Serie(serie: movie):Movie(movie: movie),
                        transitionDuration: Duration(seconds: 0),
                      ),
                    );
                  });
                }
              },
              child: Container(
                child: Row(
                  children: [
                    Container(
                      height: 35,
                      width: 35,
                      child: Center(child: Icon(Icons.info_outline,size: 20,color:Colors.white)),
                      decoration: BoxDecoration(
                          border: Border(right: BorderSide(width: 1,color:Colors.black12))
                      ),
                    ),
                    Expanded(
                        child: Center(
                            child: Text(
                              "More details",
                              style: TextStyle(
                                  color:Colors.white,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                        )
                    )
                  ],
                ),
                height: 35,
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white30,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
