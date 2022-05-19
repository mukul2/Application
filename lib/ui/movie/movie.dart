import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fire;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_tv/api/api_rest.dart';
import 'package:flutter_app_tv/test.dart';
import 'package:flutter_app_tv/ui/actor/actor_detail.dart';
import 'package:flutter_app_tv/ui/auth/auth.dart';
import 'package:flutter_app_tv/ui/channel/channels.dart';
import 'package:flutter_app_tv/ui/dialogs/sources_dialog.dart';
import 'package:flutter_app_tv/model/actor.dart';
import 'package:flutter_app_tv/model/genre.dart';
import 'package:flutter_app_tv/model/poster.dart';
import 'package:flutter_app_tv/model/source.dart';
import 'package:flutter_app_tv/ui/actor/cast_loading_widget.dart';
import 'package:flutter_app_tv/ui/actor/cast_widget.dart';
import 'package:flutter_app_tv/ui/comment/comments.dart';
import 'package:flutter_app_tv/key_code.dart';
import 'package:flutter_app_tv/ui/dialogs/subscribe_dialog.dart';
import 'package:flutter_app_tv/ui/movie/related_loading_widget.dart';
import 'package:flutter_app_tv/ui/review/review_add.dart';
import 'package:flutter_app_tv/ui/player/video_player.dart';
import 'package:flutter_app_tv/ui/movie/movies_widget.dart';
import 'package:flutter_app_tv/ui/review/reviews.dart';
import 'package:flutter_app_tv/ui/serie/serie.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert' as convert;

import '../../Related_videos/related_video_widget.dart';
import '../../model/subtitle.dart';


class Movie extends StatefulWidget {

  Poster? movie;
  String genres ="";
  String genres_id ="";


  Movie({this.movie}){
    int i =0;
    for(Genre g in movie!.genres){
      genres = genres + " • "+g.title;
      if(i == movie!.genres.length-1)
        genres_id +=g.id.toString();
      else
        genres_id +=g.id.toString()+ ",";

      i++;
    }
  }
  @override
  _MovieState createState() => _MovieState();
}

class _MovieState extends State<Movie> {

  String TMDB ="";
  bool isAdded = false;

  List<Subtitle> availableSubtitles = [];

  int postx = 0;
  int posty = 0;
  FocusNode movie_focus_node = FocusNode();
  ItemScrollController _scrollController = ItemScrollController();
  ItemScrollController _castScrollController = ItemScrollController();
  ItemScrollController _moviesScrollController = ItemScrollController();
  ItemScrollController _sourcesScrollController = ItemScrollController();
  ItemScrollController _sourcesScrollController2 = ItemScrollController();

  bool visible_subscribe_dialog = false;

  bool visibileSourcesDialog= false;
  bool _visibile_cast_loading= false;
  bool _visibile_related_loading= true;
  int _selected_source= 0;
  int _selected_subtitle_source = 0;
  int _focused_source= 0;

  List<Actor> actorsList  = [];
  List<Poster> movies =[];
  bool? logged =false;
  bool added =false;

  bool my_list_loading = false;

  String? subscribed = "FALSE";

  fire.DocumentReference? documentReference;

  dynamic? MovieDetails;
  List<Source>  ss = [];
  List<Source>  videosOrTrailers = [];
  String tId = "";
  bool imdbVarified = false;

  String movie_plot = "";
  String image_r = "";

  List gnres_r = [];
  String gng_r ="";
  String gng_r2 ="";
  double rating_r = 0.0;
  String  duration_r = "";
  String  release_year_r = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();



    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(movie_focus_node);

      //_checkLogged();
      //_getCastList();
     // _getRelatedList();

      _getMovieDetails();
      // _checkLogged();

      //  _getRelatedList();
    });
  }

  _getMovieDetails() async {
    print("stream id "+widget.movie!.id.toString());

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String SERVER_URL = sharedPreferences.getString("SERVER_URL")!;

   fire.DocumentSnapshot dS = await fire.FirebaseFirestore.instance.collection("moreInfo"+SERVER_URL).doc(widget.movie!.id.toString()).get();

   try{
      tId = dS.get("tmdbId");
      imdbVarified = true;
   }catch(e){
     imdbVarified = false;
   }
   try{
     Map<String, dynamic> dataMap = dS.data() as Map<String, dynamic>;

     movie_plot = dataMap["info"]["plot"];
     rating_r = dataMap["info"]["rating"];
     duration_r = dataMap["info"]["duration"];
     release_year_r = dataMap["info"]["releasedate"];
     image_r = dataMap["info"]["movie_image"];

     if( dataMap["info"]["genre"]!=null){
       String ggg = dataMap["info"]["genre"];

       gnres_r = ggg.split(",");

       if(gnres_r.length>0){


         for(String g in gnres_r){
           gng_r = gng_r + " • "+g;

         }




       }

     }
   }catch(e){
   }
   setState(() {

   });



    var r  = await apiRest.searchMovieInTMDB(posterID: widget.movie!.id.toString(),name: widget.movie!.title,rTmdbId: imdbVarified?tId:null);

    MovieDetails =  r["movie"];
    actorsList.clear();
    actorsList =await apiRest.getMovieCastAndCrew(imdb:  r["tmdb_id"]);
    TMDB =  r["tmdb_id"];




    for(int i = 0 ; i < r["movie"]["genres"].length ; i++){
      gng_r2  = gng_r2 +  " • "+r["movie"]["genres"][i]["name"];
    }

    print("now getting subtitles");
    availableSubtitles =  await apiRest.getSubtitles(imdb:  TMDB);

    print(availableSubtitles);
    var videosResponse  = await apiRest.getVidoesFromTMDB(id: TMDB);

    videosOrTrailers = videosResponse;


    setState(() {

    });

  }
  void _checkLogged()  async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.logged = prefs.getBool("LOGGED_USER");
    this.subscribed =  prefs.getString("NEW_SUBSCRIBE_ENABLED");

    _checkMylist();
  }
  void _checkMylist() async{

    if(logged == true ){
      setState(() {
        my_list_loading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? id_user =  prefs.getInt("ID_USER");
      String? key_user =  prefs.getString("TOKEN_USER");
      var data =  {"key":key_user,"user":id_user.toString(),"id": widget.movie!.id.toString(),"type":"poster"};
      var response =await apiRest.checkMyList(data);
      print(response.body);

      if(response != null){
        if(response.statusCode == 200){
          if(response.body.toString() == "200"){
            setState(() {
              added = true;
            });
          }else{
            added = false;
          }
        }
      }
      setState(() {
        my_list_loading = false;
      });
    }

  }
  void _addMylist() async{

    if( posty ==  0 && postx  ==  2){


      if(isAdded==false){
        fire.FirebaseFirestore.instance.collection("favourites").add({"x_id": widget.movie!.id,"uid": "4fe8679c08"}).then((value) {

          print("Added");

        });
      }else{
        print("shourd remove");




        documentReference!.delete().then((value) {

          print("deleted");

        });
      }





      // if(logged == true){
      //     setState(() {
      //       my_list_loading = true;
      //     });
      //     SharedPreferences prefs = await SharedPreferences.getInstance();
      //     int? id_user =  prefs.getInt("ID_USER");
      //     String? key_user =  prefs.getString("TOKEN_USER");
      //     var data =  {"key":key_user,"user":id_user.toString(),"id": widget.movie!.id.toString(),"type":"poster"};
      //     var response =await apiRest.addMyList(data);
      //     print(response.body);
      //
      //     if(response != null){
      //       if(response.statusCode == 200){
      //         if(response.body.toString() == "200"){
      //           setState(() {
      //             added = true;
      //           });
      //         }else{
      //           setState(() {
      //             added = false;
      //           });
      //         }
      //       }
      //     }
      //     setState(() {
      //       my_list_loading = false;
      //     });
      //   }else{
      //     Navigator.push(
      //       context,
      //       PageRouteBuilder(
      //         pageBuilder: (context, animation1, animation2) => Auth(),
      //         transitionDuration: Duration(seconds: 0),
      //       ),
      //     );
      //   }
    }

  }
  void _getRelatedList()  async{

    movies.clear();
    setState(() {
      _visibile_related_loading=true;
    });
    var response =await apiRest.getMoviesByGenres(widget.genres_id);
    if(response != null){
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);
        for(Map<String,dynamic> i in jsonData){
          Poster _poster = Poster.fromJson(i);
          movies.add(_poster);
        }
      }
    }
    setState(() {
      _visibile_related_loading=false;
    });
  }
  void _getCastList()  async{
    actorsList.clear();
    // setState(() {
    _visibile_cast_loading=true;
    // });






    var response =await apiRest.geCastByPoster(int.parse(TMDB));
    print("cast response");
    print(response.body);
    if(response != null){
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);
        for(Map<String,dynamic> i in jsonData){
          Actor actor = Actor.fromJson(i);
          actorsList.add(actor);
        }
      }
    }
    //  setState(() {
    _visibile_cast_loading=false;
    //  });
  }
  @override
  Widget build(BuildContext context) {

    Future<dynamic>  getMovieDetails({required String title}) async {
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

        try{
          String castLink = "https://api.themoviedb.org/3/movie/$TMDB/credits?api_key=103096910bbe8842c151f7cce00ab218";
          print(castLink);
          var responseCast = await http.get(Uri.parse(castLink), );
          print(responseCast.body);
          dynamic jRespon = jsonDecode(responseCast.body);
          List castOnlyArray = jRespon["cast"];
          actorsList.clear();
          for(int a = 0 ; a < castOnlyArray.length ; a++){
            print("actor "+castOnlyArray[a]["name"]);
            actorsList.add(Actor(id: castOnlyArray[a]["id"]??a, name: castOnlyArray[a]["name"]??"--", type: "", role: castOnlyArray[a]["character"]??"--", image: "https://image.tmdb.org/t/p/w500/"+castOnlyArray[a]["profile_path"]??"--", born: "1994", height: "", bio: "Bio Here"));
          }
          _visibile_cast_loading=false;
        }catch(e){
          print("error on actors "+e.toString());
        }






        //  await FirebaseFirestore.instance.collection("moreInfoSeries").doc(seriedID).set({"fullSeries":responseTMDFF.body});

        return jsonDecode(responseTMDFF.body);
      }else{
        String tvSHowTMDBFull = "https://api.themoviedb.org/3/movie/414906?api_key=103096910bbe8842c151f7cce00ab218";
        print(tvSHowTMDBFull);
        TMDB = tmdbId;
        var responseTMDFF = await http.get(Uri.parse(tvSHowTMDBFull), );
        print(responseTMDFF.body);

        try{
          //  await FirebaseFirestore.instance.collection("moreInfoSeries").doc(seriedID).set({"fullSeries":responseTMDFF.body});
          String castLink = "https://api.themoviedb.org/3/movie/$TMDB/credits?api_key=103096910bbe8842c151f7cce00ab218";
          actorsList.clear();
          print(castLink);
          var responseCast = await http.get(Uri.parse(castLink), );
          dynamic jRespon = jsonDecode(responseCast.body);
          List castOnlyArray = jRespon["cast"];
          for(int a = 0 ; a < castOnlyArray.length ; a++){
            actorsList.add(Actor(id: castOnlyArray[a]["id"]??a, name: castOnlyArray[a]["name"]??"--", type: "", role: castOnlyArray[a]["character"]??"--", image: "https://image.tmdb.org/t/p/w500/"+castOnlyArray[a]["profile_path"]??"--", born: "1994", height: "", bio: "Bio Here"));
          }
          _visibile_cast_loading=false;
        }catch(e){
          print("error on actors "+e.toString());
          print(e);
        }
        return jsonDecode(responseTMDFF.body);
      }

    }

    return  WillPopScope(
      onWillPop: () async{
        if(visible_subscribe_dialog){
          setState(() {
            visible_subscribe_dialog = false;
          });
          return false;
        }
        if(visibileSourcesDialog){
          setState(() {
            visibileSourcesDialog = false;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: RawKeyboardListener(
          focusNode: movie_focus_node,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
              RawKeyDownEvent rawKeyDownEvent = event;
              RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data as RawKeyEventDataAndroid;
              print(rawKeyEventDataAndroid.toString());
              switch (rawKeyEventDataAndroid.keyCode) {
                case KEY_CENTER:
                  _openSource();
                  _goToReview();
                  _goToPlayer();
                  _goToComments();
                  _goToReviews();
                  _goToTrailer();
                  _goToMovieDetail();
                  _goToActorDetail();
                  _addMylist();
                  _getMovieDetails();
                  break;
                case KEY_UP:


                  if(visibileSourcesDialog){
                    (_focused_source  == 0 )? print("play sound") : _focused_source--;
                    break;
                  }
                  postx = 0;
                  if(posty == 0){
                    print("play sound");
                  }else{
                    posty--;
                    _scrollToIndexY(posty);
                  }
                  if(posty == 1){
                    _scrollToIndexCats(postx);
                  }
                  if(posty == 2){
                    _scrollToIndexMovie(postx);
                  }
                  break;
                case KEY_DOWN:
                  if(visibileSourcesDialog){
                    (_focused_source  == availableSubtitles.length -1 )? print("play sound") : _focused_source++;
                    break;
                  }
                  postx = 0;
                  if(posty == 2){
                    print("play sound");
                  }else {
                    posty++;
                    _scrollToIndexY(posty);
                  }
                  if(posty == 1){
                    _scrollToIndexCats(postx);
                  }
                  if(posty == 2){
                    _scrollToIndexMovie(postx);
                  }
                  break;
                case KEY_LEFT:
                  if(visibileSourcesDialog){
                    print("play sound");
                    break;
                  }
                  if(postx == 0){
                    print("play sound");
                  }else{
                    postx -- ;
                    if(posty == 1){
                      _scrollToIndexCats(postx);
                    }
                    if(posty == 2){
                      _scrollToIndexMovie(postx);
                    }
                  }
                  break;
                case KEY_RIGHT:
                  if(visibileSourcesDialog){
                    print("play sound");
                    break;
                  }
                  if(posty == 0){
                    if(postx == 5){
                      print("play sound");
                    }else{
                      postx ++;
                    }
                  }else if(posty == 1){
                    if(postx == actorsList.length-1){
                      print("play sound");
                    }else{
                      postx ++;
                      _scrollToIndexCats(postx);
                    }
                  }else if(posty == 2){
                    if(postx == movies.length-1){
                      print("play sound");
                    }else{
                      postx ++;
                      _scrollToIndexMovie(postx);
                    }
                  }
                  break;
                default:
                  break;
              }
              setState(() {

              });
              if(visibileSourcesDialog && _sourcesScrollController!= null){
                _sourcesScrollController.scrollTo(index: _focused_source,alignment: 0.43,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
              }
            }
          },
          child:MovieDetails!=null? Container(

            child: Stack(
              children: [
                FadeInImage(placeholder: MemoryImage(kTransparentImage), image: CachedNetworkImageProvider(MovieDetails["backdrop_path"]!=null?("https://image.tmdb.org/t/p/w500/"+MovieDetails["backdrop_path"]):(MovieDetails["poster_path"]!=null?  "https://image.tmdb.org/t/p/w500/"+MovieDetails["poster_path"]:widget.movie!.cover)),fit: BoxFit.cover,height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width),
                //ImageFade(image:CachedNetworkImageProvider(widget.movie!.cover),fit: BoxFit.cover,height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width),
                ClipRRect( // Clip it cleanly.
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Container(
                    child: ScrollConfiguration(
                      behavior: MyBehavior(),   //
                      child: ScrollablePositionedList.builder(
                          itemCount: 3,
                          itemScrollController: _scrollController,
                          itemBuilder: (context, index) {
                            switch(index){
                              case 0:

                                return Container(
                                  padding: EdgeInsets.only(left: 50,right: 50,bottom: 20,top: 100),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                  borderRadius: BorderRadius.circular(5),
                                                  child: CachedNetworkImage(
                                                    imageUrl:widget.movie!.image,
                                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                                    fit: BoxFit.cover,
                                                  )
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),


                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          padding: EdgeInsets.only(left: 20),
                                          child:  Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(  widget.movie!.title.contains(MovieDetails["title"])?MovieDetails["title"]: widget.movie!.title,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w900
                                                    ),
                                                  ),
                                                  if(imdbVarified)Padding(
                                                    padding: const EdgeInsets.only(left: 10),
                                                    child: Container(decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.redAccent ),child: Center(child:Icon(Icons.done ,color: Colors.white,),),),
                                                  ),
                                                  if(imdbVarified == false)Padding(
                                                    padding: const EdgeInsets.only(left: 10),
                                                    child: Container(decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.redAccent ),child: Center(child:Icon(Icons.question_mark_outlined ,color: Colors.white,),),),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 15),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  // Text("${widget.movie!.rating}/5", style: TextStyle(
                                                  //     color: Colors.white,
                                                  //     fontSize: 13,
                                                  //     fontWeight: FontWeight.w800
                                                  // ),),
                                                  RatingBar.builder(
                                                    initialRating: rating_r>0?rating_r:  MovieDetails["vote_average"],
                                                    minRating: 1,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 10,
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
                                                  SizedBox(width: 5),
                                                  Text(" •  ${rating_r>0?rating_r:  MovieDetails["vote_average"]} / 10 "
                                                    , style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w800
                                                    ),
                                                  )
                                                  ,
                                                  SizedBox(width: 2)
                                                  ,
                                                  Container(
                                                    padding: EdgeInsets.symmetric(vertical: 1,horizontal: 5),
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
                                                  ) ,

                                                  Container(margin: EdgeInsets.only(left: 10),
                                                    padding: EdgeInsets.symmetric(vertical: 1,horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                    child: Row(
                                                      children: [

                                                        Icon(Icons.thumb_up,size: 15,color: Colors.white,),
                                                        Padding(
                                                          padding:  EdgeInsets.only(left: 5),
                                                          child: Text( MovieDetails["vote_count"].toString(), style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w800
                                                          ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(margin: EdgeInsets.only(left: 10),
                                                    padding: EdgeInsets.symmetric(vertical: 1,horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                    child: Row(
                                                      children: [

                                                        Icon(Icons.calendar_month,size: 15,color: Colors.white,),
                                                        Padding(
                                                          padding:  EdgeInsets.only(left: 5),
                                                          child: Text(release_year_r.length>0?DateFormat("yyyy").format(DateTime.parse(release_year_r))    : DateFormat("yyyy").format(DateTime.parse( MovieDetails["release_date"].toString())) , style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w800
                                                          ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Text(" ${duration_r.length>0?duration_r:    MovieDetails["runtime"]} min ${gng_r.length>0? gng_r:  gng_r2}"
                                                , style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w900
                                                ),),
                                              SizedBox(height: 10),
                                              Text( movie_plot.length>0? movie_plot:MovieDetails["overview"]
                                                , style: TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 11,
                                                    height: 1.5,
                                                    fontWeight: FontWeight.normal
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: (){


                                                          // Navigator.push(
                                                          //   context,
                                                          //   PageRouteBuilder(
                                                          //     pageBuilder: (context, animation1, animation2) => VideoPlayer(sourcesList: widget.movie!.sources,selected_source:0,focused_source: 0,poster: widget.movie),
                                                          //     transitionDuration: Duration(seconds: 0),
                                                          //   ),
                                                          // );
                                                      //    _playSource();

                                                          setState(() {
                                                            posty = 0;
                                                            postx =0;
                                                            Future.delayed(Duration(milliseconds: 100),(){
                                                              // _goToPlayer();

                                                              _playSource();

                                                              Navigator.push(
                                                                context,
                                                                PageRouteBuilder(
                                                                  pageBuilder: (context, animation1, animation2) => VideoPlayer(subtitles: availableSubtitles,selected_subtitle: _focused_source,sourcesList: widget.movie!.sources,selected_source:_focused_source,focused_source: _focused_source,poster: widget.movie),
                                                                  transitionDuration: Duration(seconds: 0),
                                                                ),
                                                              );


                                                            });
                                                          });
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                                          height: 35,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.white,width: 0.3),
                                                            borderRadius: BorderRadius.circular(3),
                                                            color: (postx == 0 && posty == 0)? Colors.white:Colors.white30,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                height: 28,
                                                                width: 28,
                                                                child: Icon(
                                                                  FontAwesomeIcons.play,
                                                                  color: (postx == 0 && posty == 0)? Colors.black:Colors.white,
                                                                  size: 11,
                                                                ),
                                                              ),
                                                              Text(
                                                                  "Play Movie" ,
                                                                  style: TextStyle(
                                                                      color: (postx == 0 && posty == 0)? Colors.black:Colors.white,
                                                                      fontSize: 11,
                                                                      fontWeight: FontWeight.w500
                                                                  )
                                                              ),
                                                              SizedBox(width: 5),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      GestureDetector(
                                                        onTap: (){
                                                          setState(() {
                                                            posty = 0;
                                                            postx =1;
                                                            Future.delayed(Duration(milliseconds: 100),(){
                                                              _goToTrailer();
                                                            });
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 35,
                                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.white,width: 0.3),
                                                            borderRadius: BorderRadius.circular(3),
                                                            color: (postx == 1 && posty == 0)? Colors.white:Colors.white30,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                height: 28,
                                                                width: 28,
                                                                child: Icon(
                                                                  FontAwesomeIcons.bullhorn,
                                                                  color: (postx == 1 && posty == 0)? Colors.black:Colors.white,
                                                                  size: 11,
                                                                ),
                                                              ),
                                                              Text(
                                                                  "Watch Trailer" ,
                                                                  style: TextStyle(
                                                                      color: (postx == 1 && posty == 0)? Colors.black:Colors.white,
                                                                      fontSize: 11,
                                                                      fontWeight: FontWeight.w500
                                                                  )
                                                              ),
                                                              SizedBox(width: 5)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),

                                                      //  Text( widget.movie!.id.toString(),style: TextStyle(color: Colors.white),),






                                                      StreamBuilder<fire.QuerySnapshot>(
                                                          stream:fire.FirebaseFirestore.instance.collection("favourites").where("uid",isEqualTo: "4fe8679c08").where("x_id",isEqualTo: widget.movie!.id).snapshots(),
                                                          builder: (BuildContext context, AsyncSnapshot<fire.QuerySnapshot> snapshot) {

                                                            GestureDetector bR(bool status){


                                                              isAdded = status;
                                                              return  GestureDetector(
                                                                onTap: (){

                                                                  print("button pressed");
                                                                  // print(visibileSourcesDialog);


                                                                  if(status == false){

                                                                    print("shourd add");
                                                                    //add to

                                                                  }else{
                                                                    //remove from

                                                                  }


                                                                  setState(() {

                                                                    posty = 0;
                                                                    postx = 2;

                                                                  });
                                                                },
                                                                child: Container(
                                                                  height: 35,
                                                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                                                  decoration: BoxDecoration(
                                                                    border: Border.all(color: Colors.white,width: 0.3),
                                                                    borderRadius: BorderRadius.circular(3),
                                                                    color: (postx == 2 && posty == 0)? Colors.white:Colors.white30,
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      (my_list_loading)?
                                                                      Container(
                                                                          padding: EdgeInsets.all(9),
                                                                          height: 28,
                                                                          width: 28,
                                                                          child: Container(
                                                                              child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,)
                                                                          )
                                                                      )
                                                                          :
                                                                      Container(
                                                                        height: 28,
                                                                        width: 28,
                                                                        child: Icon(
                                                                          (added)? FontAwesomeIcons.solidTimesCircle:FontAwesomeIcons.plusCircle,
                                                                          color: (postx == 2 && posty == 0)? Colors.black:Colors.white,
                                                                          size: 11,
                                                                        ),
                                                                      ),
                                                                      (my_list_loading)?
                                                                      Text(
                                                                          "Loading ..." ,
                                                                          style: TextStyle(
                                                                              color: (postx == 2 && posty == 0)? Colors.black:Colors.white,
                                                                              fontSize: 11,
                                                                              fontWeight: FontWeight.w500
                                                                          )
                                                                      )
                                                                          :
                                                                      Text(
                                                                          (status)?
                                                                          "Remove from Favourites"
                                                                              :
                                                                          "Add to Favourites" ,
                                                                          style: TextStyle(
                                                                              color: (postx == 2 && posty == 0)? Colors.black:Colors.white,
                                                                              fontSize: 11,
                                                                              fontWeight: FontWeight.w500
                                                                          )
                                                                      ),
                                                                      SizedBox(width: 5)
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }

                                                            if(snapshot.hasData){

                                                              if(snapshot.data!.docs.length>0){
                                                                documentReference = snapshot.data!.docs.first.reference;
                                                                return bR(true);

                                                              }else{
                                                                return bR(false);
                                                              }
                                                            }else{
                                                              return bR(false);
                                                            }


                                                          }),





                                                      SizedBox(width: 5),
                                                      GestureDetector(
                                                        onTap: (){
                                                          setState(() {
                                                            posty = 0;
                                                            postx =3;
                                                            Future.delayed(Duration(milliseconds: 100),(){
                                                              _goToReview();
                                                            });
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 35,
                                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.white,width: 0.3),
                                                            borderRadius: BorderRadius.circular(3),
                                                            color: (postx == 3 && posty == 0)? Colors.white:Colors.white30,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                height: 28,
                                                                width: 28,
                                                                child: Icon(
                                                                  FontAwesomeIcons.starHalfAlt,
                                                                  color: (postx == 3 && posty == 0)? Colors.black:Colors.white,
                                                                  size: 11,
                                                                ),
                                                              ),
                                                              Text(
                                                                  "Rate Movie" ,
                                                                  style: TextStyle(
                                                                      color: (postx == 3 && posty == 0)? Colors.black:Colors.white,
                                                                      fontSize: 11,
                                                                      fontWeight: FontWeight.w500
                                                                  )
                                                              ),
                                                              SizedBox(width: 5)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: (){
                                                          setState(() {
                                                            posty = 0;
                                                            postx =4;
                                                            Future.delayed(Duration(milliseconds: 250),(){
                                                              _goToComments();
                                                            });
                                                          });
                                                        },
                                                        child: AnimatedContainer(
                                                          duration: Duration(milliseconds: 200),
                                                          height: 35,
                                                          width: (postx == 4 && posty == 0)? 98:35.6,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.white,width: 0.3),
                                                            borderRadius: BorderRadius.circular(3),
                                                            color: (postx == 4 && posty == 0)? Colors.white:Colors.white30,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                height: 35,
                                                                width: 35,
                                                                child: Icon(
                                                                  FontAwesomeIcons.comments,
                                                                  color: (postx == 4 && posty == 0)? Colors.black:Colors.white,
                                                                  size: 11,
                                                                ),
                                                              ),
                                                              Flexible(
                                                                child: Visibility(
                                                                  visible: (postx == 4 && posty == 0),
                                                                  child: Text(
                                                                    "Comments" ,
                                                                    style: TextStyle(
                                                                        color: (postx == 4 && posty == 0)? Colors.black:Colors.white,
                                                                        fontSize: 11,
                                                                        fontWeight: FontWeight.w500
                                                                    ),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      GestureDetector(
                                                        onTap: (){
                                                          setState(() {
                                                            posty = 0;
                                                            postx =5;
                                                            Future.delayed(Duration(milliseconds: 250),(){
                                                              _goToReviews();
                                                            });
                                                          });
                                                        },
                                                        child: AnimatedContainer(
                                                          duration: Duration(milliseconds: 200),
                                                          height: 35,
                                                          width: (postx == 5 && posty == 0)? 88:35.6,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.white,width: 0.3),
                                                            borderRadius: BorderRadius.circular(3),
                                                            color: (postx == 5 && posty == 0)? Colors.white:Colors.white30,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                height: 35,
                                                                width: 35,
                                                                child: Icon(
                                                                  FontAwesomeIcons.star,
                                                                  color: (postx == 5 && posty == 0)? Colors.black:Colors.white,
                                                                  size: 11,
                                                                ),
                                                              ),
                                                              Flexible(
                                                                child: Visibility(
                                                                  visible: (postx == 5 && posty == 0),
                                                                  child: Text(
                                                                    "Reviews" ,
                                                                    style: TextStyle(
                                                                      color: (postx == 5 && posty == 0)? Colors.black:Colors.white,
                                                                      fontSize: 11,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );

                                break;
                              case 1:
                                return Container(
                                  padding: EdgeInsets.symmetric(vertical: 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 50),
                                        child: Text("Full Cast & Crew"
                                          , style: TextStyle(
                                              color: (posty == 1)?Colors.white:Colors.white60,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      if(_visibile_cast_loading)
                                        Container(
                                            height: 70,
                                            child: CastLoadingWidget()
                                        )
                                      else
                                        Container(
                                          height: 70,
                                          child: ScrollConfiguration(
                                            behavior: MyBehavior(),   //
                                            child: ScrollablePositionedList.builder(
                                                itemCount: actorsList.length,
                                                itemScrollController: _castScrollController,
                                                scrollDirection: Axis.horizontal,
                                                itemBuilder: (context, index) {
                                                  return GestureDetector(
                                                      onTap: (){
                                                        setState(() async {
                                                          posty =1 ;
                                                          postx = index;

                                                          var r  = await apiRest. getPeopleInfoFromTMDB(id:actorsList[index].id.toString());

                                                            _goToActorDetail(data: r);

                                                        });
                                                      },
                                                      child: CastWidget(posty: posty,postx: postx,actor: actorsList[index],index: index,active_y: 1)
                                                  );
                                                }
                                            ),
                                          ),
                                        )

                                    ],
                                  ),
                                );
                                break;
                              case 2:
                                return  Container(
                                  padding: EdgeInsets.only(top: 5,bottom: 20),
                                  child: Column(
                                    children: [
                                      if(true || !_visibile_related_loading)
                                       // MoviesWidget(title: "Related Movies",size: 13,scrollController: _moviesScrollController,postx: postx,jndex: 2,posty: posty,posters: movies)
                                        RelatedVideoWidget(title: "Videos",size: 13,scrollController: _moviesScrollController,postx: postx,jndex: 2,posty: posty,posters: videosOrTrailers)
                                      else
                                        RelatedLoadingWidget(),
                                    ],
                                  ),
                                );
                                break;
                              default:
                                return Container();
                                break;
                            }
                          }),
                    )
                ),
               // SourcesDialog(sourcesScrollController2: _sourcesScrollController2,tmdb_id: TMDB,visibileSourcesDialog: visibileSourcesDialog,focused_source: _focused_source,selected_source: _selected_source,sourcesList: widget.movie!.sources,sourcesScrollController: _sourcesScrollController,close: closeSourceDialog,select: selectSource),
                SourcesDialog(subtitleSelect: selectSubtitleSource,subtitleList: availableSubtitles,sourcesScrollController2: _sourcesScrollController2,tmdb_id: TMDB,visibileSourcesDialog: visibileSourcesDialog,focused_source: _focused_source,selected_source: _selected_source,sourcesList:availableSubtitles,sourcesScrollController: _sourcesScrollController,close: closeSourceDialog,select: selectSource),
                SubscribeDialog(visible:visible_subscribe_dialog ,close:(){
                  setState(() {
                    visible_subscribe_dialog= false;
                  });
                }),
              ],
            ),
          ):Container(height: 0,width: 0,),
        ),
      ),
    );


  }
  void  _goToReview() async{
    if(posty == 0 && postx == 3){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? logged = prefs.getBool("LOGGED_USER");

      if(logged == true){
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ReviewAdd(image: widget.movie!.image,id: widget.movie!.id,type: "movie"),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      }else{
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => Auth(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      }

    }
  }
  void  _goToReviews(){
    if(posty == 0 && postx == 5){
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Reviews(id:widget.movie!.id,title: widget.movie!.title,image: widget.movie!.cover,type: "movie"),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    }
  }
  void  _goToComments(){
    if(posty == 0 && postx == 4){
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Comments(id:widget.movie!.id,enabled:widget.movie!.comment,title: widget.movie!.title,image: widget.movie!.cover,type: "movie"),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    }
  }
  void  _goToPlayer(){

    if(posty == 0 && postx  == 0){
      setState(() {
        visibileSourcesDialog= true;
      });
    }
  }
  void  _goToTrailer() async{
    if(posty == 0 && postx  == 1){
      String url = widget.movie!.trailer!.url;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
  Future _scrollToIndexY(int y) async {
    _scrollController.scrollTo(index: y,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
  }
  Future _scrollToIndexCats(int y) async {
    _castScrollController.scrollTo(index: y,alignment: 0.05,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
  }
  Future _scrollToIndexMovie(int y) async {
    _moviesScrollController.scrollTo(index: y,alignment: 0.04,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
  }

  void _openSource() async{
    if(visibileSourcesDialog) {
      visibileSourcesDialog = false;
      _selected_source = 0;
      _selected_subtitle_source = _focused_source;
     // SharedPreferences prefs = await SharedPreferences.getInstance();

      _playSource();
      // if(widget.movie!.sources[_selected_source].premium == "2" || widget.movie!.sources[_selected_source].premium == "3"){
      //   if(subscribed == "TRUE"){
      //     _playSource();
      //   }else{
      //     setState(() {
      //       visible_subscribe_dialog = true;
      //     });
      //   }
      // }else{
      //   _playSource();
      // }
      setState(() {

      });
    }
  }
  void _playSource() async {
    print("focused node at "+_focused_source.toString());
    if (widget.movie!.sources[_selected_source].type == "youtube" || widget.movie!.sources[_selected_source].type == "embed" ) {
      String url = widget.movie!.sources[_selected_source].url;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      int _new_selected_source =0;
      List<Source> _sources = [];
      int j = 0;
      for (var i = 0; i < widget.movie!.sources.length; i++) {

        if(widget.movie!.sources[i].type != "youtube"){

          _sources.add(widget.movie!.sources[i]);
          if(_selected_source == i){
            _new_selected_source = j;
          }
          j++;
        }
      }
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => VideoPlayer(subtitles:availableSubtitles,selected_subtitle: _focused_source,sourcesList: _sources,selected_source:0,focused_source: _focused_source,poster: widget.movie),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    }
  }
  void _goToActorDetail({dynamic data}) {
    if(posty == 1 ){
      if(actorsList.length>0){
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ActorDetail(data: data,actor:actorsList[postx]),
            transitionDuration: Duration(seconds: 0),
          ),
        );
        FocusScope.of(context).requestFocus(null);
      }

    }
  }
  void _goToMovieDetail() {
    if(posty == 2 ){
      if(movies.length>0){
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => (movies[postx].type == "serie")? Serie(serie:movies[postx]):Movie(movie:movies[postx]),
            transitionDuration: Duration(seconds: 0),
          ),
        );
        FocusScope.of(context).requestFocus(null);
      }

    }
  }
  void closeSourceDialog(){
    setState(() {
      visibileSourcesDialog = false;
    });
  }
  void selectSource(int selected_source_pick){
    setState(() {
      _focused_source =  selected_source_pick;
      _selected_subtitle_source = selected_source_pick;
      Future.delayed(Duration(milliseconds: 200),(){
       // _openSource();
      });
    });
  }
  void selectSubtitleSource(int selected_subtitle){
    setState(() {
      _focused_source =  selected_subtitle;
      _selected_subtitle_source = selected_subtitle;
      Future.delayed(Duration(milliseconds: 200),(){
       // _openSource();
      });
    });
  }

}


