



import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_tv/api/api_config.dart';
import 'package:flutter_app_tv/model/actor.dart';
import 'package:flutter_app_tv/model/poster.dart';
import 'package:flutter_app_tv/model/source.dart' as ss;
import 'package:flutter_app_tv/model/subtitle.dart';
import 'package:http/http.dart' as http;

class apiRest{
  static String EMAIL = "4fe8679c08";

  static String no_image = "https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg?20200913095930";
  static pushWatch({required int durationSeconds,dynamic data}) async {
    FirebaseFirestore  firestore =  FirebaseFirestore.instance;

    firestore.collection("watchHistory"+EMAIL).where("stream_id",isEqualTo: data["stream_id"]).get().then((value) {
      print("fff1");
      if(value.docs.length>0){
        print("fff222");
        value.docs.first.reference.update({"time":DateTime.now().millisecondsSinceEpoch,"duration":durationSeconds}).then((value) {
          print("fff333");
        });
      }else{
        firestore.collection("watchHistory"+EMAIL).add({"stream_id":data["stream_id"],"time":DateTime.now().millisecondsSinceEpoch,"type":"movie","duration":durationSeconds,"data":data}).then((value) => print("firebase note added"));

      }

    });



  }
  static getMovieCastAndCrew ({required String imdb}) async {
    List<Actor>actors = [];

    try{
      String castLink = "https://api.themoviedb.org/3/movie/$imdb/credits?api_key=103096910bbe8842c151f7cce00ab218";
      print(castLink);
      var responseCast = await http.get(Uri.parse(castLink), );
      print(responseCast.body);
      dynamic jRespon = jsonDecode(responseCast.body);
      List castOnlyArray = jRespon["cast"];

      for(int a = 0 ; a < castOnlyArray.length ; a++){
        print("actor "+castOnlyArray[a]["name"]);
        actors.add(Actor(id: castOnlyArray[a]["id"]??a, name: castOnlyArray[a]["name"]??"--", type: "", role: castOnlyArray[a]["character"]??"--", image: castOnlyArray[a]["profile_path"]!=null? ("https://image.tmdb.org/t/p/w500/"+castOnlyArray[a]["profile_path"]):no_image, born: "1994", height: "", bio: "Bio Here"));
      }

      print(actors);
      return actors;
      // _visibile_cast_loading=false;
    }catch(e){
      print("Empty actor");
      return actors;
    }
  }


  static getSubtitles ({required String imdb}) async {
    List subtitleAvailableList = [];
    List<Subtitle> subtitleAvailableListModel = [];

    try{
      String castLink = "https://sflix-edc5e.uc.r.appspot.com/subtitle?tmdbid=$imdb";


      print(castLink);
      var responseCast = await http.get(Uri.parse(castLink), );


      print("subtitle response");
      print(responseCast.body);




      subtitleAvailableList = jsonDecode(responseCast.body);

    //  print(subtitleAvailableList[0]["lang"]);
     // print(subtitleAvailableList[0]["file_name"]);

      if(subtitleAvailableList.length>0){
        Subtitle? subtitle =new Subtitle(id: -1, type: "", language: "", url: "", image: "");
        subtitleAvailableListModel.insert(0, subtitle);
        for(int i = 0 ; i < subtitleAvailableList.length ; i++){
          subtitleAvailableListModel.add(Subtitle(file_name:subtitleAvailableList[i]["file_name"] ,file_id:subtitleAvailableList[i]["file_id"] ,type: "",id: i,language:subtitleAvailableList[i]["lang"],url: "",image: "https://cdn.britannica.com/44/344-004-494CC2E8/Flag-England.jpg" ));
        }

      }

      return subtitleAvailableListModel;
      // _visibile_cast_loading=false;
    }catch(e){
      print(e);
      print("Empty subtitle");
      return subtitleAvailableListModel;
    }
  }

  static downloadubtitles ({required String fileName,required String fileId,required String lang}) async {
    try{
      String castLink = "https://sflix-edc5e.uc.r.appspot.com/download?file_id=$fileId&lang=$lang&file_name=$fileName";
      print(castLink);
      var responseCast = await http.get(Uri.parse(castLink), );
      return responseCast.body;
    }catch(e){
      print(e);
      print("Empty subtitle");
      return "";
    }
  }
  static getVidoesFromTMDB({required String id})async{






    String tvSHowTMDB = "https://api.themoviedb.org/3/movie/$id/videos?api_key=103096910bbe8842c151f7cce00ab218";
    print(tvSHowTMDB);

    var responseTMDB = await http.get(Uri.parse(tvSHowTMDB) );

    dynamic jsonTMDB = jsonDecode(responseTMDB.body);

    List<ss.Source> videos = [];


    if(jsonTMDB["results"].length>0){
      for(int i = 0 ; i < jsonTMDB["results"].length ; i ++){
        String id = jsonTMDB["results"][i]["key"];

        ss.Source source = ss.Source(id: i,title: jsonTMDB["results"][i]["type"],type: "https://img.youtube.com/vi/$id/hqdefault.jpg",quality: "HD",size: "",kind: "1",premium: "1",external: true,url: "https://www.youtube.com/watch?v="+jsonTMDB["results"][i]["key"]);

        videos.add(source);
      }
    }

    return videos;


  }



  static getPeopleInfoFromTMDB({required String id})async{






    String tvSHowTMDB = "https://api.themoviedb.org/3/person/$id?api_key=103096910bbe8842c151f7cce00ab218";
    print(tvSHowTMDB);

    var responseTMDB = await http.get(Uri.parse(tvSHowTMDB) );

    dynamic jsonTMDB = jsonDecode(responseTMDB.body);



    return jsonTMDB;


  }



  static searchMovieInTMDB({required String name,String? rTmdbId})async{
    dynamic MovieDetails;

    String TMDB = "";
    if(rTmdbId!=null){
      String tvSHowTMDBFull = "https://api.themoviedb.org/3/movie/$rTmdbId?api_key=103096910bbe8842c151f7cce00ab218";
      print(tvSHowTMDBFull);
      TMDB = rTmdbId;
      var responseTMDFF = await http.get(Uri.parse(tvSHowTMDBFull), );
      print(responseTMDFF.body);


      MovieDetails =  jsonDecode(responseTMDFF.body);
    }else{


      List alls = name.split("-");
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
      print(key);
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

        MovieDetails =  jsonDecode(responseTMDFF.body);
      }else{
        String tvSHowTMDBFull = "https://api.themoviedb.org/3/movie/414906?api_key=103096910bbe8842c151f7cce00ab218";
        print(tvSHowTMDBFull);
        TMDB = tmdbId;
        var responseTMDFF = await http.get(Uri.parse(tvSHowTMDBFull), );
        print(responseTMDFF.body);


        MovieDetails =  jsonDecode(responseTMDFF.body);
      }
    }



    return {"tmdb_id":TMDB,"movie":MovieDetails};


  }
  static  configUrl(String url) async{
    var response;
    Uri uri = Uri.http(apiConfig.api_url.replaceAll("https://", "").replaceAll("/api/", ""), "unencodedPath");
    try{
      if(apiConfig.api_url.contains("https"))
        uri = Uri.https(apiConfig.api_url.replaceAll("https://", "").replaceAll("/api/", ""),"/api"+  url +apiConfig.api_token+"/"+apiConfig.item_purchase_code +"/");
      else
        uri=  Uri.http(apiConfig.api_url.replaceAll("http://", "").replaceAll("/api/", ""),  "/api"+url +apiConfig.api_token+"/"+apiConfig.item_purchase_code +"/");
      response  = await http.get(uri);
    }catch(ex){
      response = null;
      print(ex);
    }
    print(uri);
    return  response;
  }
  static  configPost(String url,var data) async{
    var response;
    Uri uri = Uri.http(apiConfig.api_url.replaceAll("https://", "").replaceAll("/api/", ""), "unencodedPath");
    try{
      if(apiConfig.api_url.contains("https"))
        uri = Uri.https(apiConfig.api_url.replaceAll("https://", "").replaceAll("/api/", ""),"/api"+  url +apiConfig.api_token+"/"+apiConfig.item_purchase_code +"/");
      else
        uri=  Uri.http(apiConfig.api_url.replaceAll("http://", "").replaceAll("/api/", ""),  "/api"+url +apiConfig.api_token+"/"+apiConfig.item_purchase_code +"/");
      response  = await http.post(uri,body: data);
    }catch(ex){
      response = null;
    }
    print(uri);
    return  response;
  }

  static getMoviesByFiltres(int genre,String order,int page) async{
    return configUrl("/movie/by/filtres/${genre}/${order}/${page}/") ;
  }
  static getMoviesByGenres(genres) async{
    return configUrl("/movie/random/${genres}/") ;
  }
  static getSeriesByFiltres(int genre,String order,int page) async{
    return configUrl("/serie/by/filtres/${genre}/${order}/${page}/") ;
  }
  static getSeasonsBySerie(int id) async{
    return configUrl("/season/by/serie/${id}/") ;
  }
  static registerUser(var data) async{
    return configPost("/user/register/",data) ;
  }
  static loginUser(var data) async{
    return configPost("/user/login/",data) ;
  }
  static addCommentPoster(var data) async{

    return configPost("/comment/poster/add/",data) ;
  }
  static addCommentChannel(var data) async{
    return configPost("/comment/channel/add/",data) ;
  }
  static addReviewPoster(var data) async{
    return configPost("/rate/poster/add/",data) ;
  }
  static addReviewChannel(var data) async{
    return configPost("/rate/channel/add/",data) ;
  }
  static getGenres() async{
    return configUrl("/genre/all/") ;
  }

  static getCommentsByPoster(int id) async{
    return configUrl("/comments/by/poster/${id}/") ;
  }
  static getCommentsByChannel(int id) async{
    return configUrl("/comments/by/channel/${id}/") ;
  }

  static getReviewsByPoster(int id) async{
    return configUrl("/reviews/by/poster/${id}/") ;
  }
  static getReviewsByChannel(int id) async{
    return configUrl("/reviews/by/channel/${id}/") ;
  }
  static geCastByPoster(int id) async{
    return configUrl("/role/by/poster/${id}/") ;
  }
  static getSubtitlesByMovie(int id) async{
    return configUrl("/subtitles/by/movie/${id}/") ;
  }

  static getSubtitlesByEpisode(int id) async{
    return configUrl("/subtitles/by/episode/${id}/") ;
  }

  static getHomeData() async{
    return configUrl("/first/") ;
  }

  static getCountries() async{
    return configUrl("/country/all/") ;
  }

  static getCategories() async{
    return configUrl("/category/all/") ;
  }

  static getChannelsByFiltres(int country,int category, String order, int page) async{
    return configUrl("/channel/by/filtres/tv/${category}/${country}/${page}/${order}/") ;
  }

  static getChannelsByCategories(String categories) {
    return configUrl("/channel/random/${categories}/") ;
  }

  static getMoviesByActor(int id) {
    return configUrl("/movie/by/actor/${id}/") ;

  }

  static myList(int id,String key) {
    return configUrl("/mylist/${id}/${key}/") ;

  }

  static addMyList(var data) {
    return configPost("/add/mylist/",data) ;

  }

  static checkMyList(var data) {
    return configPost("/check/mylist/",data) ;

  }

  static searchByQuery(String query) {
    return configUrl("/search/${query}/") ;

  }

  static changePassword(int id, String old,String new_) {
    return configUrl("/user/password/${id}/${old}/${new_}/") ;

  }
  static check(int code, int user) {
    return configUrl("/version/check/${code}/${user}/") ;

  }
  static editProfile(var data) {

    return configPost("/user/edit/",data) ;

  }

  static getSubscriptions(var data) {
    return configPost("/subscription/user/",data) ;

  }

  static sendMessage(var data) {
    return configPost("/support/add/",data) ;

  }

}