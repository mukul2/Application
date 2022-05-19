



import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_tv/api/api_config.dart';
import 'package:flutter_app_tv/model/actor.dart';
import 'package:flutter_app_tv/model/poster.dart';
import 'package:flutter_app_tv/model/source.dart' as ss;
import 'package:flutter_app_tv/model/subtitle.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
class apiRest{

  static String no_image = "https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg?20200913095930";

  static  checkFile(String name) async {
   try{
     final directory = await getApplicationDocumentsDirectory();
     final path = await directory.path;
     // bool d = await File('$path/$name').exists();
     // print(name+"  "+d.toString());
     print('$path/$name');
     return await io.File('$path/$name').exists();

   }catch(e){
     print(name+"  missing");
     return false;
   }
  }
  static  localFile(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = await directory.path;
    return File('$path/$name');
  }
  static get_epg_full () async {
    try{
      //String castLink = "http://connect.proxytx.cloud/xmltv.php?username=4fe8679c08&password=2016";
      String castLink = "http://connect.proxytx.cloud/player_api.php?username=4fe8679c08&password=2016&action=get_short_epg&stream_id=879355";
      print(castLink);
      var responseCast = await http.get(Uri.parse(castLink), );
      return responseCast.body;
    }catch(e){
      print(e);
      print("Empty subtitle");
      return "";
    }
  }

  static getMovies () async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? server =  sharedPreferences.getString("SERVER_URL");
    String? port =  sharedPreferences.getString("PORT");
    String? USER_ID =  sharedPreferences.getString("USER_ID");
    String? PASSWORD =  sharedPreferences.getString("PASSWORD");
    try{
      
     // String gc_link = "https://us-central1-sflix-edc5e.cloudfunctions.net/live";
     // String gc_link = "https://sflix-edc5e.uc.r.appspot.com/playlist";
      //String castLink = "http://connect.proxytx.cloud/xmltv.php?username=4fe8679c08&password=2016";
      String mov_category = "http://$server:$port/player_api.php?username=$USER_ID&password=$PASSWORD&action=get_vod_categories";
      //print(mov_category);


      var b =  jsonEncode(<String, String>{"link":"$server:$port","user":USER_ID!,"password":PASSWORD!,"action":"get_vod_categories"});
      var responseCast = await http.get(Uri.parse(mov_category));
      print("get_vod_categories response");
      print(responseCast.body);
      return jsonDecode(responseCast.body);
    }catch(e){
      print(e);
      print("Empty subtitle");
      return "";
    }
  }

  static getMovCateDetails () async {
    print("going to download from cloud");

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? server =  sharedPreferences.getString("SERVER_URL");
    String? port =  sharedPreferences.getString("PORT");
    String? USER_ID =  sharedPreferences.getString("USER_ID");
    String? PASSWORD =  sharedPreferences.getString("PASSWORD");
    try{

     // String gc_link = "https://us-central1-sflix-edc5e.cloudfunctions.net/live";
     // String gc_link = "https://sflix-edc5e.uc.r.appspot.com/playlist";
      //String castLink = "http://connect.proxytx.cloud/xmltv.php?username=4fe8679c08&password=2016";
      String mov_category = "http://$server:$port/player_api.php?username=$USER_ID&password=$PASSWORD&action=get_vod_categories";
      //print(mov_category);

      String g_link = "https://europe-west2-staht-connect-322113.cloudfunctions.net/testM";


      //var b =  jsonEncode(<String, String>{"link":"$server:$port","user":USER_ID!,"password":PASSWORD!,"action":"get_vod_categories"});
      var b =  jsonEncode(<String, String>{"link":"http://$server","user":USER_ID!,"password":PASSWORD!});

      print(b);
      var responseCast = await http.post(Uri.parse(g_link),body: b,headers: { 'Content-type': 'application/json'});
      print("get_vod_categories response");
      print(responseCast.body);

      List l = jsonDecode(responseCast.body);
      if(l.length>0){
        final fileTV = await localFile("mc.json");
        await fileTV.writeAsString(responseCast.body);
      }
      return l;

    }catch(e){
      print(e);
      print("Empty subtitle");
      return "";
    }
  }
  static getSeriesCateDetails () async {
    print("getting series from cloud");

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? server =  sharedPreferences.getString("SERVER_URL");
    String? port =  sharedPreferences.getString("PORT");
    String? USER_ID =  sharedPreferences.getString("USER_ID");
    String? PASSWORD =  sharedPreferences.getString("PASSWORD");
    try{

      // String gc_link = "https://us-central1-sflix-edc5e.cloudfunctions.net/live";
      // String gc_link = "https://sflix-edc5e.uc.r.appspot.com/playlist";
      //String castLink = "http://connect.proxytx.cloud/xmltv.php?username=4fe8679c08&password=2016";
      String mov_category = "http://$server/player_api.php?username=$USER_ID&password=$PASSWORD&action=get_vod_categories";
      //print(mov_category);

      String g_link = "https://europe-west2-staht-connect-322113.cloudfunctions.net/testS";


      //var b =  jsonEncode(<String, String>{"link":"$server:$port","user":USER_ID!,"password":PASSWORD!,"action":"get_vod_categories"});
      var b =  jsonEncode(<String, String>{"link":"http://$server","user":USER_ID!,"password":PASSWORD!});
      var responseCast = await http.post(Uri.parse(g_link),body: b,headers: { 'Content-type': 'application/json'});
      print(" response");
      print(responseCast.body);

      List ll = jsonDecode(responseCast.body);

      if(ll.length>0){
        final fileTV = await localFile("series.json");
        await fileTV.writeAsString(responseCast.body);
      }


      return ll;
    }catch(e){
      print(e);
      print("Empty subtitle");
      return "";
    }
  }

  static getTVCateDetails () async {
    print("getting tv from cloud");

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? server =  sharedPreferences.getString("SERVER_URL");
    String? port =  sharedPreferences.getString("PORT");
    String? USER_ID =  sharedPreferences.getString("USER_ID");
    String? PASSWORD =  sharedPreferences.getString("PASSWORD");
    try{

      // String gc_link = "https://us-central1-sflix-edc5e.cloudfunctions.net/live";
      // String gc_link = "https://sflix-edc5e.uc.r.appspot.com/playlist";
      //String castLink = "http://connect.proxytx.cloud/xmltv.php?username=4fe8679c08&password=2016";
      String mov_category = "http://$server/player_api.php?username=$USER_ID&password=$PASSWORD&action=get_vod_categories";
      //print(mov_category);

      String g_link = "https://europe-west2-staht-connect-322113.cloudfunctions.net/test";


      //var b =  jsonEncode(<String, String>{"link":"$server:$port","user":USER_ID!,"password":PASSWORD!,"action":"get_vod_categories"});
      var b =  jsonEncode(<String, String>{"link":"http://$server","user":USER_ID!,"password":PASSWORD!});
      var responseCast = await http.post(Uri.parse(g_link),body: b,headers: { 'Content-type': 'application/json'});
      print(" response");
      print(responseCast.body);

      List ll = jsonDecode(responseCast.body);

      if(ll.length>0){
        final fileTV = await localFile("tv.json");
        await fileTV.writeAsString(responseCast.body);
      }


      return ll;
    }catch(e){
      print(e);
      print("Empty subtitle");
      return "";
    }
  }

  static getMoviesOfCategory ({required String idCategory}) async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? server =  sharedPreferences.getString("SERVER_URL");
    String? port =  sharedPreferences.getString("PORT");
    String? USER_ID =  sharedPreferences.getString("USER_ID");
    String? PASSWORD =  sharedPreferences.getString("PASSWORD");
    try{

     // String gc_link = "https://us-central1-sflix-edc5e.cloudfunctions.net/live";
      //String castLink = "http://connect.proxytx.cloud/xmltv.php?username=4fe8679c08&password=2016";
      String mov_category = "http://$server:$port/player_api.php?username=$USER_ID&password=$PASSWORD&action=get_vod_streams&category_id="+idCategory;
      print(mov_category);
      var responseCast = await http.get(Uri.parse(mov_category));
      return jsonDecode(responseCast.body);
    }catch(e){
      print(e);
      print("Empty subtitle");
      return "";
    }
  }

  static pushWatch({required int durationSeconds,dynamic data}) async {
    FirebaseFirestore  firestore =  FirebaseFirestore.instance;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();


    String? USER_ID =  sharedPreferences.getString("USER_ID");
    var value =    await firestore.collection("watchHistory"+USER_ID!).where("stream_id",isEqualTo: data["stream_id"]).get();

    if(value.docs.length>0){

      await value.docs.first.reference.update({"time":DateTime.now().millisecondsSinceEpoch,"duration":durationSeconds});
      return;
    }else{
      await firestore.collection("watchHistory"+USER_ID).add({"stream_id":data["stream_id"],"time":DateTime.now().millisecondsSinceEpoch,"type":"movie","duration":durationSeconds,"data":data}).then((value) => print("firebase note added"));
      return;

    }

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

  static searchMovieInTMDB({required String name,String? rTmdbId,required String posterID})async{
    dynamic MovieDetails;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? server =  sharedPreferences.getString("SERVER_URL");
    String? port =  sharedPreferences.getString("PORT");
    String? USER_ID =  sharedPreferences.getString("USER_ID");
    String? PASSWORD =  sharedPreferences.getString("PASSWORD");
    String  LinkMovieInfo = "http://$server/player_api.php?username=$USER_ID&password=$PASSWORD&action=get_vod_info&vod_id="+posterID;

    http.get(Uri.parse(LinkMovieInfo), ).then((value) {

      FirebaseFirestore.instance.collection("moreInfo"+server!).add(jsonDecode(value.body));

    });







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

        for(int i  = 0 ; i < jsonTMDB["total_results"] ; i++){

          if(jsonTMDB["title"].toString().contains(name)){
            tmdbId = jsonTMDB["results"][i]["id"].toString();
            print("choosing "+i.toString());
            break;
          }

        }


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

  static get_epg({required String channelId})async{

    print("epg api");

    String tvSHowTMDB = "http://connect.proxytx.cloud/player_api.php?username=4fe8679c08&password=2016&action=get_simple_data_table&stream_id=$channelId";
    print(tvSHowTMDB);

    var responseTMDB = await http.get(Uri.parse(tvSHowTMDB) );
    print(responseTMDB.body);
    dynamic dd =  jsonDecode(responseTMDB.body);
    return dd["epg_listings"];



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
  static loginUser({required String email,required String password}) async{
 //  var url = Uri.parse('http://line.liveott.ru/player_api.php?username=$email&password=$password');
    var url = Uri.parse('http://line.myprotv.net/player_api.php?username=$email&password=$password');
    http.Response response;
    response = await http.get( url, );
    print(response.body);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String,dynamic> r =  jsonDecode(response.body);

    if(r.containsKey("user_info")){
      Map<String,dynamic> user_info =  r["user_info"];

      if( user_info.containsKey("status")){
        if( user_info["status"]=="Active"){
          print("success");






          prefs.setString("SERVER_URL", r["server_info"]["url"]);
          prefs.setString("USER_ID", email);
          prefs.setString("PASSWORD", password);
          prefs.setString("PORT", r["server_info"]["port"]);
          prefs.setBool("auth", true);

          return true;







        }else{
          prefs.setBool("auth", false);
          return false;
          print("fail");
        }
      }else{
        prefs.setBool("auth", false);
        return false;
      }
    }else{
      prefs.setBool("auth", false);
      return false;
    }
    //return configPost("/user/login/",data) ;
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