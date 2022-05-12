import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fire;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_tv/api/api_rest.dart';
import 'package:flutter_app_tv/model/actor.dart';
import 'package:flutter_app_tv/model/episode.dart';
import 'package:flutter_app_tv/model/genre.dart';
import 'package:flutter_app_tv/model/poster.dart';
import 'package:flutter_app_tv/model/season.dart';
import 'package:flutter_app_tv/model/source.dart';
import 'package:flutter_app_tv/ui/actor/actor_detail.dart';
import 'package:flutter_app_tv/ui/actor/cast_loading_widget.dart';
import 'package:flutter_app_tv/ui/actor/cast_widget.dart';
import 'package:flutter_app_tv/ui/auth/auth.dart';
import 'package:flutter_app_tv/ui/comment/comments.dart';
import 'package:flutter_app_tv/ui/dialogs/sources_dialog.dart';
import 'package:flutter_app_tv/ui/dialogs/subscribe_dialog.dart';
import 'package:flutter_app_tv/ui/home/home.dart';
import 'package:flutter_app_tv/key_code.dart';
import 'package:flutter_app_tv/ui/movie/movie.dart';
import 'package:flutter_app_tv/ui/movie/related_loading_widget.dart';
import 'package:flutter_app_tv/ui/review/review_add.dart';
import 'package:flutter_app_tv/ui/player/video_player.dart';
import 'package:flutter_app_tv/ui/movie/movies_widget.dart';
import 'package:flutter_app_tv/ui/review/reviews.dart';
import 'package:flutter_app_tv/ui/serie/seasin_loading_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:convert' as convert;

import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
class Serie extends StatefulWidget {

  Poster? serie;
  String genres ="";
  String genres_id ="";
  String TMDB ="";

  Serie({ this.serie}){
    int i =0;
    for(Genre g in serie!.genres){
      genres = genres + " • "+g.title;
      if(i == serie!.genres.length-1)
        genres_id +=g.id.toString();
      else
        genres_id +=g.id.toString()+ ",";

      i++;
    }
  }


  @override
  _SerieState createState() => _SerieState();
}

class _SerieState extends State<Serie> {
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




    String tvSHowTMDB = "https://api.themoviedb.org/3/search/tv?api_key=103096910bbe8842c151f7cce00ab218&query="+key;
    print(tvSHowTMDB);

    var responseTMDB = await http.get(Uri.parse(tvSHowTMDB) );

    dynamic jsonTMDB = jsonDecode(responseTMDB.body);
    String tmdbId="";
    if(jsonTMDB["total_results"]>0){

      tmdbId = jsonTMDB["results"][0]["id"].toString();
      String tvSHowTMDBFull = "https://api.themoviedb.org/3/tv/$tmdbId?api_key=103096910bbe8842c151f7cce00ab218";
      print(tvSHowTMDBFull);

      var responseTMDFF = await http.get(Uri.parse(tvSHowTMDBFull), );
      print(responseTMDFF.body);

      //  await FirebaseFirestore.instance.collection("moreInfoSeries").doc(seriedID).set({"fullSeries":responseTMDFF.body});

      return jsonDecode(responseTMDFF.body);
    }else{
      String tvSHowTMDBFull = "https://api.themoviedb.org/3/tv/81292?api_key=103096910bbe8842c151f7cce00ab218";
      print(tvSHowTMDBFull);

      var responseTMDFF = await http.get(Uri.parse(tvSHowTMDBFull), );
      print(responseTMDFF.body);

      //  await FirebaseFirestore.instance.collection("moreInfoSeries").doc(seriedID).set({"fullSeries":responseTMDFF.body});

      return jsonDecode(responseTMDFF.body);
    }












  }
  int postx = 0;
  int posty = 0;
  int selected_season = 0;
  int? selected_episode;
  FocusNode movie_focus_node = FocusNode();
  ItemScrollController _scrollController = ItemScrollController();
  ItemScrollController _castScrollController = ItemScrollController();
  ItemScrollController _moviesScrollController = ItemScrollController();
  ItemScrollController _episodesScrollController = ItemScrollController();
  ItemScrollController _seasonsScrollController = ItemScrollController();
  ItemScrollController _sourcesScrollController = ItemScrollController();

  bool _visibile_season_loading= true;
  bool _visibile_cast_loading= true;
  bool _visibile_related_loading= true;
  bool visibileSourcesDialog= false;
  bool visible_subscribe_dialog = false;

  int _selected_source= 0;
  int _focused_source= 0;

  List<Actor> actorsList  = [];
  List<Poster> series =[];
  List<Season> seasons =[];
  List<Source> sources =[];

  bool? logged =false;
  bool added =false;

  bool my_list_loading = false;

  String? subscribed = "FALSE";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(movie_focus_node);
        _getRelatedList();
        _getCastList();
        _getSeasons();
        _checkLogged();
    });

  }
  void _checkLogged()  async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.logged = prefs.getBool("LOGGED_USER");
    this. subscribed =  prefs.getString("NEW_SUBSCRIBE_ENABLED");
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
      var data =  {"key":key_user,"user":id_user.toString(),"id": widget.serie?.id.toString(),"type":"poster"};
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

    if(posty ==  0 && postx  ==  2){
      if(logged == true){
          setState(() {
            my_list_loading = true;
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          int? id_user =  prefs.getInt("ID_USER");
          String? key_user =  prefs.getString("TOKEN_USER");
          var data =  {"key":key_user,"user":id_user.toString(),"id": widget.serie?.id.toString(),"type":"poster"};
          var response =await apiRest.addMyList(data);
          print(response.body);

          if(response != null){
            if(response.statusCode == 200){
              if(response.body.toString() == "200"){
                setState(() {
                  added = true;
                });
              }else{
                setState(() {
                  added = false;
                });
              }
            }
          }
          setState(() {
            my_list_loading = false;
          });
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
  void _getRelatedList()  async{

    series.clear();
    setState(() {
      _visibile_cast_loading=true;
    });
    var response =await apiRest.getMoviesByGenres(widget.genres_id);
    if(response != null){
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);
        for(Map<String,dynamic> i in jsonData){
          Poster _poster = Poster.fromJson(i);
          series.add(_poster);
        }
      }
    }
    setState(() {
      _visibile_cast_loading=false;
    });
  }
  void _getSeasons()  async{
    seasons.clear();
    setState(() {
      _visibile_season_loading=true;
    });
    String SERVER = "http://connect.proxytx.cloud";
    String PORT = "80";
    String EMAIL = "4fe8679c08";
    String PASSWORD = "2016";

    String id = (widget.serie!.id).toString();

    String TMDB = "";




    fire.DocumentSnapshot moreInfo = await  fire.FirebaseFirestore.instance.collection("moreInfoSeries").doc(id).get();

    Map<String, dynamic> ddddd = {};
   try{
     ddddd = moreInfo.data()! as Map<String, dynamic>;
   }catch(e){

   }

    if( moreInfo.exists &&  ddddd.containsKey("xtrInfo")){

     

      dynamic tmdbInfo = ddddd["tmdbInfo"];
      dynamic xtrInfo = ddddd["xtrInfo"];


      dynamic data = xtrInfo;

      data["episodes"].forEach((key, value) {
        List<Episode>allEpisodes = [];
        for(int i = 0 ; i < value.length; i++){
          String  old= SERVER+":$PORT"+"/"+"series"+"/"+EMAIL+"/"+PASSWORD.toString() +"/"+value[i]["id"].toString()+"."+value[i]["container_extension"];

          Source source = Source(id:  value[i]["episode_num"], type: value[i]["container_extension"], title: value[i]["container_extension"], quality: "HQ", size: "", kind: "", premium: "1", external: true, url: old);
          allEpisodes.add(Episode(id:int.parse(value[i]["id"]), title: value[i]["title"]??"----", downloadas: "", playas: "", description: "", duration:  value[i]["info"]["duration"], image: value[i]["info"]["movie_image"], sources: [source]));
        }
        seasons.add(Season(id: int.parse(key), title: "Season "+key.toString(), episodes: allEpisodes));

      });



    }else{






      String title =  widget.serie!.title;
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




      String tvSHowTMDB = "https://api.themoviedb.org/3/search/tv?api_key=103096910bbe8842c151f7cce00ab218&query="+key;
      print(tvSHowTMDB);

      var responseTMDB = await http.get(Uri.parse(tvSHowTMDB) );

      dynamic jsonTMDB = jsonDecode(responseTMDB.body);
      String tmdbId="";
      if(jsonTMDB["total_results"]>0){

        tmdbId = jsonTMDB["results"][0]["id"].toString();
        String tvSHowTMDBFull = "https://api.themoviedb.org/3/tv/$tmdbId?api_key=103096910bbe8842c151f7cce00ab218";
        print(tvSHowTMDBFull);
        TMDB = tmdbId;
        var responseTMDFF = await http.get(Uri.parse(tvSHowTMDBFull), );

        await  fire.FirebaseFirestore.instance.collection("moreInfoSeries").doc(id).set({"tmdbInfo":responseTMDFF.body});


      }


      String link = "$SERVER/player_api.php?username=$EMAIL&password=$PASSWORD&action=get_series_info&series_id=$id";
      print(link);
      var url = Uri.parse(link);
      var responseSeries = await http.get(url, );
      print(responseSeries.body);
      dynamic data = jsonDecode(responseSeries.body);

      data["episodes"].forEach((key, value) {
        List<Episode>allEpisodes = [];
        for(int i = 0 ; i < value.length; i++){
          String  old= SERVER+":$PORT"+"/"+"series"+"/"+EMAIL+"/"+PASSWORD.toString() +"/"+value[i]["id"].toString()+"."+value[i]["container_extension"];

          Source source = Source(id:  value[i]["episode_num"], type: value[i]["container_extension"], title: value[i]["container_extension"], quality: "HQ", size: "", kind: "", premium: "1", external: true, url: old);
          allEpisodes.add(Episode(id:int.parse(value[i]["id"]), title: value[i]["title"]??"----", downloadas: "", playas: "", description: "", duration:  value[i]["info"]["duration"], image: value[i]["info"]["movie_image"], sources: [source]));
        }
        seasons.add(Season(id: int.parse(key), title: "Season "+key.toString(), episodes: allEpisodes));

      });


//xtrInfo
      await  fire.FirebaseFirestore.instance.collection("moreInfoSeries").doc(id).update({"xtrInfo":data});

      // String link = "https://api.themoviedb.org/3/tv/$tmdbId/season/$season/episode/$e?api_key=103096910bbe8842c151f7cce00ab218";
      // print(link);
      //
      // final responseTMDB = await http.get(Uri.parse(link));
      // String s = responseTMDB.body;



      // String link = "$SERVER/player_api.php?username=$EMAIL&password=$PASSWORD&action=get_series_info&series_id=$seriedID";
      // print(link);
      // var url = Uri.parse(link);
      // var response = await http.get(url, );
      // dynamic data = jsonDecode(response.body);
      // data["tmdbId"] = tmdbId;


   //   await   fire.FirebaseFirestore.instance.collection("moreInfoSeries").doc(seriedID).update(data);
     // return data;
    }









    // var response =await apiRest.getSeasonsBySerie(widget.serie!.id);
    // if(response != null){
    //   if (response.statusCode == 200) {
    //     var jsonData =  convert.jsonDecode(response.body);
    //     for(Map<String,dynamic> i in jsonData){
    //       Season season = Season.fromJson(i);
    //       seasons.add(season);
    //     }
    //   }
    // }
    setState(() {
      _visibile_season_loading=false;
    });
  }

  void _getCastList()  async{
    actorsList.clear();
    setState(() {
      _visibile_related_loading=true;
    });
    var response =await apiRest.geCastByPoster(widget.serie!.id);
    if(response != null){
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);
        for(Map<String,dynamic> i in jsonData){
          Actor actor = Actor.fromJson(i);
          actorsList.add(actor);
        }
      }
    }
    setState(() {
      _visibile_related_loading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
        body: RawKeyboardListener(
          focusNode: movie_focus_node,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
              RawKeyDownEvent rawKeyDownEvent = event;
              RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data as RawKeyEventDataAndroid;
              switch (rawKeyEventDataAndroid.keyCode) {
                case KEY_CENTER:
                  _openSource();
                  _selectSeason();
                  _goToPlayer();
                  _goToReview();
                  _goToComments();
                  _goToReviews();
                  _goToTrailer();
                  _goToSerieDetail();
                  _goToPlayerEpisode();
                  _goToActorDetail();
                  _addMylist();
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
                    if(posty == 1 ){
                      _scrollToIndexY(0);
                    }else{
                      _scrollToIndexY(posty);
                    }
                  }
                  if(posty == 3){
                    _scrollToIndexCats(postx);
                  }
                  if(posty == 1){
                    _scrollToIndexSeason(postx);
                  }
                  if(posty == 2){
                    _scrollToIndexEpisode(postx);
                  }
                  if(posty == 4){
                    _scrollToIndexSerie(postx);
                  }
                  break;
                case KEY_DOWN:
                  if(visibileSourcesDialog){
                    (_focused_source  == sources.length -1 )? print("play sound") : _focused_source++;
                    break;
                  }
                  postx = 0;
                  if(posty == 4){
                    print("play sound");
                  }else {
                    posty++;
                    if(posty == 1 ){
                      _scrollToIndexY(0);
                    }else{
                      _scrollToIndexY(posty);
                    }
                  }
                  if(posty == 1){
                    _scrollToIndexSeason(postx);
                  }
                  if(posty == 2){
                    _scrollToIndexEpisode(postx);
                  }
                  if(posty == 3){
                    _scrollToIndexCats(postx);
                  }
                  if(posty == 4){
                    _scrollToIndexSerie(postx);
                  }

                  break;
                case KEY_LEFT:
                  if(visibileSourcesDialog){
                    print("play sound");
                    break;
                  }
                  if(seasons.length == 0 && posty == 0)
                    if(postx == 1)
                      break;

                  if(postx == 0){
                    print("play sound");
                  }else{
                    postx -- ;
                    if(posty == 1){
                      _scrollToIndexSeason(postx);
                    }
                    if(posty == 2){
                      _scrollToIndexEpisode(postx);
                    }
                    if(posty == 3){
                      _scrollToIndexCats(postx);
                    }
                    if(posty == 4){
                      _scrollToIndexSerie(postx);
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
                  }else if(posty == 3){
                    if(postx == actorsList.length -1){
                      print("play sound");
                    }else{
                      postx ++;
                      _scrollToIndexCats(postx);
                    }
                  }else if(posty == 1){
                    if(postx == seasons.length-1){
                      print("play sound");
                    }else{
                      postx ++;
                      _scrollToIndexSeason(postx);
                    }
                  }
                  else if(posty == 4){
                    if(postx == series.length -1){
                      print("play sound");
                    }else{
                      postx ++;
                      _scrollToIndexSerie(postx);
                    }
                  }else if(posty == 2 && seasons.length > 0){
                    if(postx == seasons[selected_season].episodes.length -1){
                      print("play sound");
                    }else{
                      postx ++;
                      _scrollToIndexEpisode(postx);
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
          child: Container(

            child: Stack(
              children: [

                FadeInImage(placeholder: MemoryImage(kTransparentImage),image:CachedNetworkImageProvider(widget.serie!.cover),fit: BoxFit.cover,height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width),
                ClipRRect( // Clip it cleanly.
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Container(
                    child:ScrollConfiguration(
                      behavior: MyBehavior(),
                      child: ScrollablePositionedList.builder(
                          itemCount: 5,
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
                                                    imageUrl: widget.serie!.image,
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
                                        child: FutureBuilder<dynamic>(
                                          future: searchMovieInTMDB(title:widget.serie!.title), // async work
                                          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

                                            if(snapshot.connectionState == ConnectionState.done  && snapshot.hasData){

                                              List genresA = snapshot.data["genres"];
                                              String gg = "";
                                              for(int i = 0 ; i < genresA.length ; i++){
                                                gg = gg + " • "+genresA[i]["name"].toString();
                                              }

                                              return Container(
                                                padding: EdgeInsets.only(left: 20),
                                                child:  Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(snapshot.data["original_name"],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 22,
                                                          fontWeight: FontWeight.w900
                                                      ),
                                                    ),
                                                    SizedBox(height: 15),
                                                    Row(
                                                      children: [
                                                        Text("${widget.serie!.rating}/5", style: TextStyle(
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
                                                          },
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(" •  ${widget.serie!.imdb} / 10 ",
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w800
                                                          ),
                                                        )
                                                        ,
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

                                                    Text("${snapshot.data["number_of_seasons"]} Seasons • ${snapshot.data["number_of_episodes"]} Episodes •  ${gg}"
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
                                                    ),
                                                    SizedBox(height: 10),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            if( seasons.length > 0)
                                                              if(seasons[0].episodes.length>0)
                                                                GestureDetector(

                                                                  onTap: (){


                                                                    setState(() {
                                                                      posty = 0;
                                                                      postx =0;
                                                                      Future.delayed(Duration(milliseconds: 100),(){
                                                                        _goToPlayer();
                                                                      });
                                                                    });
                                                                  },
                                                                  child: Container(
                                                                    height: 35,
                                                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(color: Colors.white,width: 0.3),
                                                                      borderRadius: BorderRadius.circular(5),
                                                                      color: (postx == 0 && posty == 0)? Colors.white:Colors.white30,
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height: 35,
                                                                          width: 35,
                                                                          child: Icon(
                                                                            Icons.play_arrow,
                                                                            color: (postx == 0 && posty == 0)? Colors.black:Colors.white,
                                                                            size: 18,
                                                                          ),
                                                                        ),
                                                                        // Text(
                                                                        //     seasons[0].title + " | "+ seasons[0].episodes[0].title ,
                                                                        //     style: TextStyle(
                                                                        //         color: (postx == 0 && posty == 0)? Colors.black:Colors.white,
                                                                        //         fontSize: 11,
                                                                        //         fontWeight: FontWeight.w500
                                                                        //     )
                                                                        // ),

                                                                        Text(
                                                                            seasons[0].title  ,
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
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  color: (postx == 1 && posty == 0)? Colors.white:Colors.white30,
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      height: 35,
                                                                      width: 35,
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
                                                            GestureDetector(
                                                              onTap: (){
                                                                print(visibileSourcesDialog);
                                                                setState(() {

                                                                  posty = 0;
                                                                  postx = 2;
                                                                  _addMylist();
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
                                                                        (added)?
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
                                                            ),
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
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  color: (postx == 3 && posty == 0)? Colors.white:Colors.white30,
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      height: 35,
                                                                      width: 35,
                                                                      child: Icon(
                                                                        FontAwesomeIcons.starHalfAlt,
                                                                        color: (postx == 3 && posty == 0)? Colors.black:Colors.white,
                                                                        size: 11,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                        "Rate Serie" ,
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
                                                                  borderRadius: BorderRadius.circular(5),
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
                                                                  borderRadius: BorderRadius.circular(5),
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
                                              );
                                            }else{
                                              return Text('Loading....');
                                            }

                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                );
                                break;
                              case 1:
                                if(_visibile_season_loading)
                                  return SeasonLoadingWidget();
                               else
                                 if(seasons.length>0)
                                    return Container(
                                      height: 35,
                                      margin: EdgeInsets.only(bottom: 20),
                                      child:ScrollConfiguration(
                                        behavior: MyBehavior(),
                                        child: ScrollablePositionedList.builder(
                                          itemCount: seasons.length,
                                          itemScrollController: _seasonsScrollController,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                              return GestureDetector(
                                                onTap: (){
                                                  setState(() {
                                                    posty =1 ;
                                                    postx = index;
                                                    Future.delayed(Duration(milliseconds: 200),(){
                                                     setState(() {
                                                       selected_season  =  index;
                                                     });
                                                    });
                                                  });
                                                },
                                                child: Container(
                                                  height: 40,
                                                  padding: EdgeInsets.only(left: 20,right: 20),
                                                  margin: EdgeInsets.only(left: (index == 0)? 50 :5,right: 5),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5),
                                                      color: ((postx == index && posty == 1) || selected_season == index)? Colors.white:Colors.white30,
                                                      border: (postx == index && posty == 1)?Border.all(color: Colors.purple,width: 2):Border.all(color: Colors.white30,width: 2),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: (postx == index && posty == 1)?Colors.purple.withOpacity(0.9):Colors.white.withOpacity(0),
                                                          offset: Offset(0,0),
                                                          blurRadius: 10
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      seasons[index].title,
                                                        style: TextStyle(
                                                          color: ((postx == index && posty == 1) || selected_season == index)? Colors.black:Colors.white,
                                                          fontWeight: FontWeight.w900,
                                                        ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                          }),
                                      ),
                                    );
                                 else
                                   return   Padding(
                                     padding: const EdgeInsets.only(left: 50,bottom: 10),
                                     child: Text("No Seasons Available"
                                       , style: TextStyle(
                                           color: (posty == 1)? Colors.white:Colors.white70,
                                           fontSize: 13,
                                           fontWeight: FontWeight.w900
                                       ),
                                     ),
                                   );
                                break;
                              case 2:
                                if(seasons.length > 0)
                                  return Container(
                                  height: 150,
                                  margin: EdgeInsets.only(bottom: 20),
                                  child:ScrollConfiguration(
                                    behavior: MyBehavior(),
                                    child: ScrollablePositionedList.builder(
                                        itemCount: seasons[selected_season].episodes.length,
                                        itemScrollController: _episodesScrollController,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                posty =2 ;
                                                postx = index;
                                                Future.delayed(Duration(milliseconds: 250),(){
                                                  setState(() {
                                                    selected_episode  =  index;
                                                    _goToPlayerEpisode();
                                                  });
                                                });
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                                              child: AnimatedContainer(
                                                duration: Duration(milliseconds: 200),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey,
                                                  borderRadius: BorderRadius.circular(7),
                                                  border: (postx == index && posty == 2)?Border.all(color: Colors.purple,width: 2):null,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: (postx == index && posty == 2)?Colors.purple.withOpacity(0.9):Colors.white.withOpacity(0),
                                                        offset: Offset(0,0),
                                                        blurRadius: 5
                                                    ),
                                                  ],
                                                ),
                                                margin: EdgeInsets.only(left: (index == 0)? 50 :5,right: 5),
                                                child: Stack(
                                                  children: [
                                                    
                                                    Positioned(

                                                      child: Container(
                                                        height: 150,
                                                        width: 250,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(5),
                                                            child: (seasons[selected_season].episodes[index].image != null)? CachedNetworkImage(
                                                                imageUrl: seasons[selected_season].episodes[index].image!,
                                                                fit: BoxFit.cover
                                                            ):
                                                            Image.asset(
                                                                "assets/images/background.jpeg",
                                                                fit: BoxFit.cover
                                                            )
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                        left:0,
                                                        right:0,
                                                        top:0,
                                                        bottom:0,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                            color: Colors.black54,
                                                          ),
                                                        )
                                                    ),
                                                    Positioned(
                                                      bottom:7,
                                                      left:7,
                                                      right:7,
                                                      child: Container(
                                                        width: 250,
                                                        child:  Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              crossAxisAlignment: CrossAxisAlignment.end,

                                                              children: [
                                                                Flexible(
                                                                  child: Text( seasons[selected_season].episodes[index].title
                                                                    , style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 11,
                                                                        fontWeight: FontWeight.w900
                                                                    ),
                                                                  ),
                                                                ),

                                                                Text(seasons[selected_season].episodes[index].duration
                                                                  , style: TextStyle(
                                                                      color: Colors.white70,
                                                                      fontSize: 10,
                                                                      fontWeight: FontWeight.w900
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(seasons[selected_season].episodes[index].description
                                                              , style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 7,
                                                                  height: 1.4,
                                                                  fontWeight: FontWeight.normal
                                                              ),
                                                              maxLines: 5,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                );
                                else
                                  return   Padding(
                                    padding: const EdgeInsets.only(left: 50,bottom: 10),
                                    child: Text("No Episodes Available"
                                      , style: TextStyle(
                                          color: (posty == 2)? Colors.white:Colors.white70,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900
                                      ),
                                    ),
                                  );
                                break;
                              case 3:
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
                                              color: (posty == 3)? Colors.white:Colors.white70,
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
                                          child:ScrollConfiguration(
                                            behavior: MyBehavior(),
                                            child: ScrollablePositionedList.builder(
                                                itemCount: actorsList.length,
                                                itemScrollController: _castScrollController,
                                                scrollDirection: Axis.horizontal,
                                                itemBuilder: (context, index) {
                                                  return GestureDetector(
                                                      onTap: (){
                                                        setState(() {
                                                          posty =3 ;
                                                          postx = index;
                                                          Future.delayed(Duration(milliseconds: 200),(){
                                                            _goToActorDetail();
                                                          });
                                                        });
                                                      },
                                                      child: CastWidget(posty: posty,postx: postx,actor: actorsList[index],index: index,active_y: 3));
                                                }
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                );
                                break;
                              case 4:
                                return  Container(
                                  padding: EdgeInsets.only(top: 5,bottom: 20),
                                  child: Column(
                                    children: [
                                      if(!_visibile_related_loading)
                                        MoviesWidget(title: "Related Series",size: 13,scrollController: _moviesScrollController,postx: postx,jndex: 4,posty: posty,posters: series)
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
                SourcesDialog(subtitleList: [],sourcesScrollController2: _sourcesScrollController,visibileSourcesDialog: visibileSourcesDialog,focused_source: _focused_source,selected_source: _selected_source,sourcesList: sources,sourcesScrollController: _sourcesScrollController,select: selectSource,close: closeSourceDialog),
                SubscribeDialog(visible:visible_subscribe_dialog ,close:(){
                  setState(() {
                    visible_subscribe_dialog= false;
                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future _scrollToIndexY(int y) async {
    _scrollController.scrollTo(index: y,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
  }
  Future _scrollToIndexCats(int y) async {
    _castScrollController.scrollTo(index: y,alignment: 0.05,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
  }
  Future _scrollToIndexSerie(int y) async {
    _moviesScrollController.scrollTo(index: y,alignment: 0.04,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
  }
  Future _scrollToIndexEpisode(int y) async {
    if(_episodesScrollController != null && seasons.length > 0)
     _episodesScrollController.scrollTo(index: y,alignment: 0.05,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
  }
  Future _scrollToIndexSeason(int y) async {
    if(_seasonsScrollController != null && seasons.length > 0)
    _seasonsScrollController.scrollTo(index: y,alignment: 0.05,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
  }
  void  _goToReview() async{
    if(posty == 0 && postx == 3){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? logged = prefs.getBool("LOGGED_USER");

      if(logged == true){
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ReviewAdd(image: widget.serie!.image,id: widget.serie!.id,type: "serie"),
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
          pageBuilder: (context, animation1, animation2) => Reviews(id:widget.serie!.id,title: widget.serie!.title,image: widget.serie!.cover,type: "movie"),
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
          pageBuilder: (context, animation1, animation2) => Comments(id:widget.serie!.id,enabled:widget.serie!.comment,title: widget.serie!.title,image: widget.serie!.cover,type: "movie"),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    }
  }
  void  _goToPlayer(){
    if(seasons.length > 0) {
      if(seasons[0].episodes.length > 0) {
        _focused_source = 0;
        _selected_source = 0;
        selected_episode  = postx;
        sources = seasons[selected_season].episodes[postx].sources;
        if (posty == 0 && postx == 0) {
          setState(() {
            visibileSourcesDialog = true;
          });
        }
      }
    }
  }
  void  _goToPlayerEpisode(){
    if(seasons.length > 0) {
      if(seasons[selected_season].episodes.length > 0) {
        _focused_source = 0;
        _selected_source = 0;
        selected_episode  = postx;
        sources = seasons[selected_season].episodes[postx].sources;
        if (posty == 2) {
          setState(() {
            visibileSourcesDialog = true;
          });
        }
      }
    }
  }
  void  _goToTrailer() async{
    if(posty == 0 && postx  == 1){
      String? url = widget.serie!.trailer?.url;
      if (await canLaunch(url!)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
  void _selectSeason() {
    if(posty == 1){
      selected_season = postx;
      setState(() {

      });
    }
  }

  void _playSource() async {
    if (sources[_selected_source].type == "youtube" || sources[_selected_source].type == "embed" ) {
      String url = sources[_selected_source].url;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      int _new_selected_source =0;
      List<Source> _sources = [];
      int j = 0;
      for (var i = 0; i < sources.length; i++) {

        if(sources[i].type != "youtube"){

          _sources.add(sources[i]);
          if(_selected_source == i){
            _new_selected_source = j;
          }
          j++;
        }
      }
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => VideoPlayer(subtitles: [],sourcesList: _sources,selected_source:_new_selected_source,focused_source: _new_selected_source,poster: widget.serie,episode:selected_episode!,season: selected_season,seasons:seasons ),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    }
  }
  void _openSource() async{
    if(visibileSourcesDialog) {
      visibileSourcesDialog = false;
      _selected_source = _focused_source;
      if(sources[_selected_source].premium == "2" || sources[_selected_source].premium == "3"){
        if(subscribed == "TRUE"){
          _playSource();
        }else{
          setState(() {
            visible_subscribe_dialog = true;
          });
        }
      }else{
        _playSource();
      }
      setState(() {

      });
    }
  }
  void _goToSerieDetail() {
    if(posty == 4 ){
      if(series.length>0){
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>(series[postx].type == "serie")? Serie(serie:series[postx]):Movie(movie:series[postx]),
            transitionDuration: Duration(seconds: 0),
          ),
        );
        FocusScope.of(context).requestFocus(null);
      }

    }
  }
  void _goToActorDetail() {
    if(posty == 3 ){
      if(actorsList.length>0){
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ActorDetail(actor:actorsList[postx]),
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
      Future.delayed(Duration(milliseconds: 200),(){
        _openSource();
      });
    });
  }
}
