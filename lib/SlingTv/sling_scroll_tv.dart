
import 'dart:convert';
import 'dart:io';
import 'package:flutter_app_tv/SlingTv/sling_small_widget.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fire;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_tv/api/api_config.dart';
import 'package:flutter_app_tv/api/api_rest.dart';
import 'package:flutter_app_tv/model/category.dart';
import 'package:flutter_app_tv/model/genre.dart';
import 'package:flutter_app_tv/model/poster.dart';
import 'package:flutter_app_tv/model/channel.dart' as model;
import 'package:flutter_app_tv/model/source.dart' as modelS;
import 'package:flutter_app_tv/model/slide.dart';
import 'package:flutter_app_tv/ui/auth/auth.dart';
import 'package:flutter_app_tv/ui/auth/profile.dart';
import 'package:flutter_app_tv/ui/channel/channel_detail.dart';
import 'package:flutter_app_tv/ui/channel/channels.dart';
import 'package:flutter_app_tv/key_code.dart';
import 'package:flutter_app_tv/ui/home/home_loading_widget.dart';
import 'package:flutter_app_tv/ui/home/mylist.dart';
import 'package:flutter_app_tv/ui/movie/movie.dart';
import 'package:flutter_app_tv/ui/movie/movies.dart' as mmm;
import 'package:flutter_app_tv/ui/search/search.dart';
import 'package:flutter_app_tv/ui/serie/serie.dart';
import 'package:flutter_app_tv/ui/serie/series.dart';
import 'package:flutter_app_tv/ui/setting/settings.dart';
import 'package:flutter_app_tv/ui/channel/channels_widget.dart';
import 'package:flutter_app_tv/ui/movie/movies_widget.dart';
import 'package:flutter_app_tv/widget/navigation_widget.dart';
import 'package:flutter_app_tv/widget/slide_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:need_resume/need_resume.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:convert' as convert;
import 'package:transparent_image/transparent_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../SlingTv/sling_tv.dart';
import '../../model/channel.dart';
import '../../model/country.dart';
import '../../model/gnre_as_channel.dart';
import '../../model/source.dart';
import '../../series_like_home/home.dart';
import 'package:video_player/video_player.dart' as vP;

import '../model/slingChannel.dart';
import '../ui/channel/channel_as_home.dart';
/// A [StatelessWidget] which demonstrates
/// how to consume and interact with a [CounterBloc].
class SLING_TV_S extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}




class _HomeState extends ResumableState<SLING_TV_S> {


  // List<Genre> genres = [];
  List<GenreAsSlingChannel> genresAsC = [];
  List<Slide> slides = [];
  List<model.Channel> channels = [];
  bool controllerInited = false;

  List epgs = [];

  String nowInitialingLink = "";
  late vP.VideoPlayerController? _controller;
  int postx = 2;
  int posty = -2;
  int side_current = 0;
  CarouselController _carouselController = CarouselController();
  ItemScrollController _scrollController = ItemScrollController();
  List<ItemScrollController> _scrollControllers = [];
  List<int> _position_x_line_saver = [];
  List<int> _counts_x_line_saver = [];
  FocusNode home_focus_node = FocusNode();
  SlingChannel? selected_poster;
  SlingChannel? selected_channel;

  List<Poster> postersList = [];


  bool _visibile_loading = false;
  bool _visibile_error = false;
  bool _visibile_success = false;
  bool? logged;
  Image image = Image.asset("assets/images/profile.jpg");
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(home_focus_node);
      _getList();
      getLogged();
    });


  }

  @override
  void onResume() {
    // TODO: implement onResume
    super.onResume();
    getLogged();

  }
  getLogged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    logged = await prefs.getBool("LOGGED_USER");

    if(logged == true) {
      image = Image.network(await prefs.getString("IMAGE_USER")!);
    }else{
      logged = false;
      image = Image.asset("assets/images/profile.jpg");
    }
    setState(() {
      print(logged);
    });
  }

  void _getList()  async{
    _counts_x_line_saver.clear();
    _position_x_line_saver.clear();
    _scrollControllers.clear();
    _showLoading();


    if (true) {

      print("Downloading");


      bool showSlide = false;

      if(showSlide){
        fire.QuerySnapshot recentMovies = await  fire.FirebaseFirestore.instance.collection("recentMovies").get();

        fire.QueryDocumentSnapshot qsS = recentMovies.docs.first;


        try {
          String listStr = qsS.get("data");

          listStr.replaceAll("'", '"');

          List li = convert.jsonDecode(listStr);

          List<Poster> posters = [];

          for (int k = 0; k < li.length; k++) {
            String SERVER = "http://connect.proxytx.cloud";
            String PORT = "80";
            String EMAIL = "4fe8679c08";
            String PASSWORD = "2016";















            String link = SERVER + ":$PORT" + "/" + li[k]["stream_type"] +
                "/" + EMAIL + "/" + PASSWORD.toString() + "/" +
                li[k]["stream_id"].toString() + "." +
                li[k]["container_extension"];



            String titleForSearch =  li[k]["name"];

            // List alls = title.split("-");
            // String second = alls.last;
            //
            // List qq = second.split("(");
            //
            // List kk = qq.first.toString().split(" ");
            // String key ="" ;
            // for(int i = 0 ; i < kk.length ; i++){
            //
            //   if(kk[i].toString().trim()!="4K"){
            //     if(i==1){
            //       if(kk[i].toString().length>0) key = kk[i];
            //     }else{
            //       if(kk[i].toString().length>0) key = key+"+"+kk[i];
            //     }
            //
            //   }
            //
            //
            //
            //
            // }
            //
            // key = key.replaceAll("++", "+");
            // key = key.replaceAll(":", "");
            // key = key.replaceAll("(", "");
            // key = key.replaceAll(")", "");
            //
            // print(key);
            //
            //
            //
            //
            // String tvSHowTMDB = "https://api.themoviedb.org/3/search/movie?api_key=103096910bbe8842c151f7cce00ab218&query="+key;
            // print(tvSHowTMDB);
            //
            // var responseTMDB = await http.get(Uri.parse(tvSHowTMDB) );
            //
            // dynamic jsonTMDB = jsonDecode(responseTMDB.body);
            // String tmdbId="";
            // if(jsonTMDB["total_results"]>0){
            //
            //   tmdbId = jsonTMDB["results"][0]["id"].toString();
            //   String tvSHowTMDBFull = "https://api.themoviedb.org/3/movie/$tmdbId?api_key=103096910bbe8842c151f7cce00ab218";
            //   print(tvSHowTMDBFull);
            //   TMDB = tmdbId;
            //   var responseTMDFF = await http.get(Uri.parse(tvSHowTMDBFull), );
            //   print(responseTMDFF.body);
            //
            //   //  await FirebaseFirestore.instance.collection("moreInfoSeries").doc(seriedID).set({"fullSeries":responseTMDFF.body});
            //
            //   return jsonDecode(responseTMDFF.body);
            // }else{
            //   String tvSHowTMDBFull = "https://api.themoviedb.org/3/movie/414906?api_key=103096910bbe8842c151f7cce00ab218";
            //   print(tvSHowTMDBFull);
            //   TMDB = tmdbId;
            //   var responseTMDFF = await http.get(Uri.parse(tvSHowTMDBFull), );
            //   print(responseTMDFF.body);
            //
            //   //  await FirebaseFirestore.instance.collection("moreInfoSeries").doc(seriedID).set({"fullSeries":responseTMDFF.body});
            //
            //   return jsonDecode(responseTMDFF.body);
            // }





            Poster poster1 = Poster(id: li[k]["stream_id"],
                title: li[k]["name"],
                type: "type",
                label: null,
                sublabel: null,
                imdb: 0.0,
                // imdb: double.parse(movieContents[_selected_genre][i]["rating"]),
                downloadas: "1",
                comment: false,
                playas: "1",
                description: link,
                classification: "--",
                year: 000,
                duration: "--:--",
                // rating: double.parse(movieContents[_selected_genre][i]["rating"]),
                rating: 0.0,
                image: li[k]["stream_icon"] ??
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png",
                cover: li[k]["stream_icon"] ??
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png",
                trailer: null,
                genres: [Genre(id: k, title: "Recently added")],
                sources: [
                  Source(size: "",
                      id: 1,
                      type: li[k]["container_extension"],
                      title: li[k]["container_extension"],
                      quality: "FHD",
                      kind: "both",
                      premium: "1",
                      external: false,
                      url: link)
                ]);

            posters.add(poster1);

            modelS.Source source = modelS.Source(size: "",id: 1, type: li[k]["container_extension"], title:li[k]["container_extension"], quality: "FHD",  kind: "both", premium: "1", external: false, url:link);
            Channel channel = model.Channel(id: k, title: li[k]["name"], type: "", label: "", sublabel: "", downloadas: "", comment: false, playas: "", description: "Description", classification: "", duration: "02:02:02", rating: 9.9, image: li[k]["stream_icon"] ??
                "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png", website: "", countries: [], categories: [], sources: [source]);

            Slide slide = Slide(id: k, title: li[k]["name"], type: "", image: li[k]["stream_icon"] ??
                "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png", url: "", category: null, genre: Genre(id: k, title: "Recently added",posters: [poster1]), channel: null);
            slides.add(slide);
          }

          // Genre gg = Genre(id: 1, title: "Recently added", posters: posters);

          //  genres.add(gg);



          // GenreAsChannel gg = GenreAsChannel(id: 1, title: "Recently added",posters:posters );

          //  genresAsC.add(gg);
          //    ItemScrollController controller = new ItemScrollController();
          //   _scrollControllers.add(controller);
          //  _position_x_line_saver.add(0);
          //  _counts_x_line_saver.add(gg.posters!.length);



          ItemScrollController controller = new ItemScrollController();
          _scrollControllers.add(controller);
          _position_x_line_saver.add(0);
          _counts_x_line_saver.add(slides.length);
        } catch (e) {
          print(e);
          print("cach recent");
        }
      }


      if(false ){
        //continue watching


        fire.QuerySnapshot recentWatch = await  fire.FirebaseFirestore.instance.collection("watchHistory4fe8679c08").where("type",isEqualTo: "movie").get();


        List<fire.QueryDocumentSnapshot> allData = recentWatch.docs;

        allData.sort((a, b) => a.get("time").compareTo(b.get("time")));

        allData = allData.reversed.toList();


        List<Poster> posters = [];
        for(int i = 0 ; i < recentWatch.docs.length ; i++){

          try{
            Map<String, dynamic> dataMap = allData[i].data() as Map<String, dynamic>;

            // String listStr = recentWatch.docs[i].get("data");
            // dynamic li = convert.jsonDecode(listStr);






            String SERVER = "http://connect.proxytx.cloud";
            String PORT = "80";
            String EMAIL = "4fe8679c08";
            String PASSWORD = "2016";

            String link =SERVER+":$PORT"+"/"+dataMap["data"]["stream_type"]+"/"+EMAIL+"/"+PASSWORD.toString() +"/"+dataMap["data"]["stream_id"].toString()+"."+dataMap["data"]["container_extension"];
            Poster poster1 = Poster(id:dataMap["data"]["stream_id"],
                title:dataMap["data"]["name"],
                type: "type",
                label: null,fromIsWaching: true,
                sublabel: null,
                imdb: 0.0,
                // imdb: double.parse(movieContents[_selected_genre][i]["rating"]),
                downloadas: "1",
                comment: false,
                playas: "1",
                description: link,
                classification: "--",
                year: 000,
                duration: "--:--",
                // rating: double.parse(movieContents[_selected_genre][i]["rating"]),
                rating:0.0,
                image: dataMap["data"]["stream_icon"]??"https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png",
                cover:dataMap["data"]["stream_icon"]??"https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png",
                trailer: null,
                genres: [Genre(id: i, title: "Recently watched")],
                sources:[Source(size: "",id: 1, type: dataMap["data"]["container_extension"], title:dataMap["data"]["container_extension"], quality: "FHD",  kind: "both", premium: "1", external: false, url:link)] );

            posters.add(poster1);








          }catch(e){

            print(e);
            print("cach recent");

          }


        }


        Genre gg = Genre(id: 99, title: "Contiue watching",posters:posters );

        //genres.add(gg);
        ItemScrollController controller = new ItemScrollController();
        _scrollControllers.add(controller);
        _position_x_line_saver.add(0);
        _counts_x_line_saver.add(gg.posters!.length);










        // for(Map<String,dynamic> genre_map  in jsonData["genres"]){
        //   Genre genre = Genre.fromJson(genre_map);
        //   if(genre.posters!.length >0) {
        //     genres.add(genre);
        //     ItemScrollController controller = new ItemScrollController();
        //     _scrollControllers.add(controller);
        //     _position_x_line_saver.add(0);
        //     _counts_x_line_saver.add(genre.posters!.length);
        //   }
        // }
      }

      if(true){
        makeUI({required List dataMap}) async {
          int limit = 10;

          List newsChannels = [];
          List entertainChannels = [];
          List kidsChannel = [];
          List sportsChannel = [];
          List MovieChannel = [];



          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

          String? server =  sharedPreferences.getString("SERVER_URL");
          String? port =  sharedPreferences.getString("PORT");
          String? USER_ID =  sharedPreferences.getString("USER_ID");
          String? PASSWORD =  sharedPreferences.getString("PASSWORD");


          for(int i = 0 ; i < dataMap.length ; i ++){
            if(dataMap[i]["name"].toString().contains("NEWS") | dataMap[i]["name"].toString().contains("DOCUMENTARY") ){
              // newsGroup.add(dataMap[i]);
              newsChannels.addAll(dataMap[i]["list"]);
            }
            if(dataMap[i]["name"].toString().contains("ENTERTAINMENT") | dataMap[i]["name"].toString().contains("GENERAL") | dataMap[i]["name"].toString().contains("TUDN")| dataMap[i]["name"].toString().contains("LATINO")| dataMap[i]["name"].toString().contains("PRIME VIDEO") | dataMap[i]["name"].toString().contains("PLUTO") | dataMap[i]["name"].toString().contains("MOVIES") | dataMap[i]["name"].toString().contains("SERIES")| dataMap[i]["name"].toString().contains("MUSIC") ){
              //entertainmentGroup.add(dataMap[i]);
              entertainChannels.addAll(dataMap[i]["list"]);
            }
            if(dataMap[i]["name"].toString().contains("MOVIE") | dataMap[i]["name"].toString().contains("Movie") | dataMap[i]["name"].toString().contains("Series")| dataMap[i]["name"].toString().contains("Show")| dataMap[i]["name"].toString().contains("SERIES") | dataMap[i]["name"].toString().contains("SHOW")  ){
              //entertainmentGroup.add(dataMap[i]);
              MovieChannel.addAll(dataMap[i]["list"]);
            }
            if(dataMap[i]["category_name"].toString().contains("KIDS")  ){
              // kidsGroup.add(dataMap[i]);
              print(dataMap[i]["category_name"]);
              kidsChannel.addAll(dataMap[i]["list"]);
            }

            if(dataMap[i]["name"].toString().contains("sports") | dataMap[i]["name"].toString().contains("MLB") | dataMap[i]["name"].toString().contains("ESPN") | dataMap[i]["name"].toString().contains("NCAA") | dataMap[i]["name"].toString().contains("NFL")| dataMap[i]["name"].toString().contains("NHL") | dataMap[i]["name"].toString().contains("NBA") | dataMap[i]["name"].toString().contains("NBC NETWORK")  | dataMap[i]["name"].toString().contains("MLS")  | dataMap[i]["name"].toString().contains("PPV")  |dataMap[i]["name"].toString().contains("SPORTS")|dataMap[i]["name"].toString().contains("ESPN") |dataMap[i]["name"].toString().contains("PLAY")|dataMap[i]["name"].toString().contains("HOCKEY") |dataMap[i]["name"].toString().contains("LEAGUE") ){
              // sportsGroup.add(dataMap[i]);
              sportsChannel.addAll(dataMap[i]["list"]);
            }


          }
          print(newsChannels.length);
          print(entertainChannels.length);
          print("KIDS channel "+kidsChannel.length.toString());
          print(sportsChannel.length);

          newsChannels.shuffle();
          entertainChannels.shuffle();
          kidsChannel.shuffle();
          sportsChannel.shuffle();
          MovieChannel.shuffle();



          int newCollectedCount = 0;
          int index = 0;
          List<SlingChannel> channelsAsSling = [];
          getNewsData({required List listToWork}) async {


            List epgs = [];
            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

            String? server =  sharedPreferences.getString("SERVER_URL");
            String? port =  sharedPreferences.getString("PORT");
            String? USER_ID =  sharedPreferences.getString("USER_ID");
            String? PASSWORD =  sharedPreferences.getString("PASSWORD");

            String castLink = "http://$server/player_api.php?username=$USER_ID&password=$PASSWORD&action=get_short_epg&stream_id="+listToWork[index]["stream_id"].toString()+"&limit=1";

            var responseEPG = await http.get(Uri.parse(castLink), );

            try{
              dynamic dd  =  jsonDecode(responseEPG.body);
              //  print(responseEPG.body);
              epgs  =dd["epg_listings"];
              if(epgs.length>0){
                String m3 = "http://$server:80/live/$USER_ID/$PASSWORD/"+entertainChannels[index]["stream_id"].toString()+".m3u8";
                print(m3);
                String m3uFile = "http://$server:$port/"+listToWork[index]["stream_type"]+"/"+USER_ID!+"/"+PASSWORD!.toString() +"/"+listToWork[index]["stream_id"].toString()+".m3u8";
                print(m3uFile);

                SlingChannel channel = SlingChannel(thumbBig: "https://clarity.global/wp-content/uploads/2018/03/news.jpg",epgs: epgs,
                    countries: [Country(id: 1,title: "UK", image: '')],id: listToWork[index]["stream_id"],comment: false,title:listToWork[index]["name"],image:(listToWork[index]["stream_icon"].toString().length>0)? listToWork[index]["stream_icon"]: "https://i5.walmartimages.com/asr/74d5a667-7df8-44f2-b9db-81f26878d316_1.c7233452b7b19b699ef96944c8cbbe74.jpeg", categories: [Category(id: 1, title: dataMap[index]["name"])], duration: '', classification: '', rating: 4.3, sources:
                    [
                      Source(id: 1,
                          type: "LIVE",
                          title: listToWork[index]["name"],
                          size: null,
                          quality: "FHD",  kind: "both",
                          premium: "1",
                          external: false,
                          url: m3uFile)
                    ], description: 'Description', sublabel: null, type: '', playas: '', website: '', downloadas: '', label: '' );

                channelsAsSling.add(channel);
                newCollectedCount++;

                print("one epg added "+channelsAsSling.length.toString()+" "+newCollectedCount.toString());
                // String image = "https://us-central1-sflix-edc5e.cloudfunctions.net/takeScreenShot?link="+"https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";
                // String image = "https://us-central1-sflix-edc5e.cloudfunctions.net/takeScreenShot?link="+m3;
                // print(image);

                // try{
                //   var responseThumb= await http.get(Uri.parse(image), );
                //   print(responseThumb.body);
                //   memoryImageOne = base64Decode(responseThumb.body);
                // }catch(e){
                //   index++;
                //   if(index<newsChannels.length-1){
                //     getData();
                //   }
                // }









                setState(() {

                });
                index++;
                if(index<listToWork.length-1 && newCollectedCount<limit){
                  getNewsData(listToWork: listToWork);
                }else{
                  print("now setting");
                  print(channelsAsSling.length);
                  GenreAsSlingChannel gg = GenreAsSlingChannel(id: 0, title: "News" ,posters:channelsAsSling );

                  genresAsC.add(gg);
                  ItemScrollController controller = new ItemScrollController();
                  _scrollControllers.add(controller);
                  _position_x_line_saver.add(0);
                  _counts_x_line_saver.add(gg.posters!.length);
                  setState(() {

                  });
                }

                print(epgs);
              }else{
                //print("epg not found.tryi ng again");
                index++;
                if(index<listToWork.length-1 && newCollectedCount<limit){
                  getNewsData(listToWork: listToWork);
                }else{
                  print("now setting");
                  print(channelsAsSling.length);
                  GenreAsSlingChannel gg = GenreAsSlingChannel(id: 0, title: "News" ,posters:channelsAsSling );

                  genresAsC.add(gg);
                  ItemScrollController controller = new ItemScrollController();
                  _scrollControllers.add(controller);
                  _position_x_line_saver.add(0);
                  _counts_x_line_saver.add(gg.posters!.length);
                  setState(() {

                  });
                }
              }
            }catch(e){
              print(castLink);
              print(e);
              getNewsData(listToWork: listToWork);
            }



          }


          if(index<newsChannels.length-1 && newCollectedCount<limit){
            getNewsData(listToWork: newsChannels);
          }

          //--------------
          int newCollectedCount2 = 0;
          int index2 = 0;
          List<SlingChannel> channelsAsSling2 = [];
          getNewsData2({required List listToWork}) async {


            List epgs = [];
            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

            String? server =  sharedPreferences.getString("SERVER_URL");
            String? port =  sharedPreferences.getString("PORT");
            String? USER_ID =  sharedPreferences.getString("USER_ID");
            String? PASSWORD =  sharedPreferences.getString("PASSWORD");

            String castLink = "http://$server/player_api.php?username=$USER_ID&password=$PASSWORD&action=get_short_epg&stream_id="+listToWork[index2]["stream_id"].toString()+"&limit=1";

            var responseEPG = await http.get(Uri.parse(castLink), );

            try{
              dynamic dd  =  jsonDecode(responseEPG.body);
              //  print(responseEPG.body);
              epgs  =dd["epg_listings"];


              if(epgs.length>0){
                String m3 = "http://$server:80/live/$USER_ID/$PASSWORD/"+entertainChannels[index2]["stream_id"].toString()+".m3u8";
                print(m3);
                String m3uFile = "http://$server:$port/"+listToWork[index2]["stream_type"]+"/"+USER_ID!+"/"+PASSWORD!.toString() +"/"+listToWork[index2]["stream_id"].toString()+".m3u8";
                print(m3uFile);

                SlingChannel channel = SlingChannel(thumbBig: "https://www.e-spincorp.com/wp-content/uploads/2017/10/industry-media-entertainment.jpg",epgs: epgs,
                    countries: [Country(id: 1,title: "UK", image: '')],id: listToWork[index2]["stream_id"],comment: false,title:listToWork[index2]["name"],image:(listToWork[index2]["stream_icon"].toString().length>0)? listToWork[index2]["stream_icon"]: "https://i5.walmartimages.com/asr/74d5a667-7df8-44f2-b9db-81f26878d316_1.c7233452b7b19b699ef96944c8cbbe74.jpeg", categories: [Category(id: 1, title: dataMap[index2]["name"])], duration: '', classification: '', rating: 4.3, sources:
                    [
                      Source(id: 1,
                          type: "LIVE",
                          title: listToWork[index2]["name"],
                          size: null,
                          quality: "FHD",  kind: "both",
                          premium: "1",
                          external: false,
                          url: m3uFile)
                    ], description: 'Description', sublabel: null, type: '', playas: '', website: '', downloadas: '', label: '' );

                channelsAsSling2.add(channel);
                newCollectedCount2++;

                print("one epg added "+channelsAsSling2.length.toString()+" "+newCollectedCount2.toString());










                setState(() {

                });
                index2++;
                if(index2<listToWork.length-1 && newCollectedCount2<limit){
                  getNewsData2(listToWork: listToWork);
                }else{
                  print("now setting");
                  print(channelsAsSling2.length);
                  GenreAsSlingChannel gg = GenreAsSlingChannel(id: 0, title: "Entertainments" ,posters:channelsAsSling2 );

                  genresAsC.add(gg);
                  ItemScrollController controller = new ItemScrollController();
                  _scrollControllers.add(controller);
                  _position_x_line_saver.add(0);
                  _counts_x_line_saver.add(gg.posters!.length);
                  setState(() {

                  });
                }

                print(epgs);
              }else{
               // print("epg not found.tryi ng again");
                index2++;
                if(index2<listToWork.length-1 && newCollectedCount2<limit){
                  getNewsData2(listToWork: listToWork);
                }else{
                  print("now setting");
                  print(channelsAsSling2.length);
                  GenreAsSlingChannel gg = GenreAsSlingChannel(id: 0, title: "Entertainments" ,posters:channelsAsSling2 );

                  genresAsC.add(gg);
                  ItemScrollController controller = new ItemScrollController();
                  _scrollControllers.add(controller);
                  _position_x_line_saver.add(0);
                  _counts_x_line_saver.add(gg.posters!.length);
                  setState(() {

                  });
                }
              }
            }catch(e){
              print(castLink);
              print(e);
              getNewsData2(listToWork: listToWork);
            }



          }


          if(index2<entertainChannels.length-1 && newCollectedCount2<limit){
            getNewsData2(listToWork: entertainChannels);
          }
//---------------
          //--------------
          int newCollectedCount3 = 0;
          int index3 = 0;
          List<SlingChannel> channelsAsSling3 = [];
          getNewsData3({required List listToWork}) async {


            List epgs = [];
            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

            String? server =  sharedPreferences.getString("SERVER_URL");
            String? port =  sharedPreferences.getString("PORT");
            String? USER_ID =  sharedPreferences.getString("USER_ID");
            String? PASSWORD =  sharedPreferences.getString("PASSWORD");

            String castLink = "http://$server/player_api.php?username=$USER_ID&password=$PASSWORD&action=get_short_epg&stream_id="+listToWork[index3]["stream_id"].toString()+"&limit=1";

            var responseEPG = await http.get(Uri.parse(castLink), );

            try{
              dynamic dd  =  jsonDecode(responseEPG.body);
              //  print(responseEPG.body);
              epgs  =dd["epg_listings"];


              if(epgs.length>0){
                String m3 = "http://$server:80/live/$USER_ID/$PASSWORD/"+entertainChannels[index3]["stream_id"].toString()+".m3u8";
                print(m3);
                String m3uFile = "http://$server:$port/"+listToWork[index3]["stream_type"]+"/"+USER_ID!+"/"+PASSWORD!.toString() +"/"+listToWork[index3]["stream_id"].toString()+".m3u8";
                print(m3uFile);

                SlingChannel channel = SlingChannel(thumbBig: "https://mongooseagency.com/files/3415/9620/1413/Return_of_Sports.jpg",epgs: epgs,
                    countries: [Country(id: 1,title: "UK", image: '')],id: listToWork[index3]["stream_id"],comment: false,title:listToWork[index3]["name"],image:(listToWork[index3]["stream_icon"].toString().length>0)? listToWork[index3]["stream_icon"]: "https://i5.walmartimages.com/asr/74d5a667-7df8-44f2-b9db-81f26878d316_1.c7233452b7b19b699ef96944c8cbbe74.jpeg", categories: [Category(id: 1, title: dataMap[index3]["name"])], duration: '', classification: '', rating: 4.3, sources:
                    [
                      Source(id: 1,
                          type: "LIVE",
                          title: listToWork[index3]["name"],
                          size: null,
                          quality: "FHD",  kind: "both",
                          premium: "1",
                          external: false,
                          url: m3uFile)
                    ], description: 'Description', sublabel: null, type: '', playas: '', website: '', downloadas: '', label: '' );

                channelsAsSling3.add(channel);
                newCollectedCount3++;

                print("one epg added "+channelsAsSling3.length.toString()+" "+newCollectedCount3.toString());










                setState(() {

                });
                index3++;
                if(index3<listToWork.length-1 && newCollectedCount3<limit){
                  getNewsData3(listToWork: listToWork);
                }else{
                  print("now setting");
                  print(channelsAsSling3.length);
                  GenreAsSlingChannel gg = GenreAsSlingChannel(id: 0, title: "Watch a game" ,posters:channelsAsSling3 );

                  genresAsC.add(gg);
                  ItemScrollController controller = new ItemScrollController();
                  _scrollControllers.add(controller);
                  _position_x_line_saver.add(0);
                  _counts_x_line_saver.add(gg.posters!.length);
                  setState(() {

                  });
                }

                print(epgs);
              }else{
               // print("epg not found.tryi ng again");
                index3++;
                if(index3<listToWork.length-1 && newCollectedCount3<limit){
                  getNewsData3(listToWork: listToWork);
                }else{
                  print("now setting");
                  print(channelsAsSling3.length);
                  GenreAsSlingChannel gg = GenreAsSlingChannel(id: 0, title: "Watch a game" ,posters:channelsAsSling3 );

                  genresAsC.add(gg);
                  ItemScrollController controller = new ItemScrollController();
                  _scrollControllers.add(controller);
                  _position_x_line_saver.add(0);
                  _counts_x_line_saver.add(gg.posters!.length);
                  setState(() {

                  });
                }
              }
            }catch(e){
              print(castLink);
              print(e);
              getNewsData3(listToWork: listToWork);
            }



          }


          if(index3<sportsChannel.length-1 && newCollectedCount3<limit){
            getNewsData3(listToWork: sportsChannel);
          }
//---------------

          //--------------
          int newCollectedCount4 = 0;
          int index4 = 0;
          List<SlingChannel> channelsAsSling4 = [];
          getNewsData4({required List listToWork}) async {


            List epgs = [];
            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

            String? server =  sharedPreferences.getString("SERVER_URL");
            String? port =  sharedPreferences.getString("PORT");
            String? USER_ID =  sharedPreferences.getString("USER_ID");
            String? PASSWORD =  sharedPreferences.getString("PASSWORD");

            String castLink = "http://$server/player_api.php?username=$USER_ID&password=$PASSWORD&action=get_short_epg&stream_id="+listToWork[index4]["stream_id"].toString()+"&limit=1";

            var responseEPG = await http.get(Uri.parse(castLink), );

            try{
              dynamic dd  =  jsonDecode(responseEPG.body);
              //  print(responseEPG.body);
              epgs  =dd["epg_listings"];


              if(epgs.length>0){
                String m3 = "http://$server:80/live/$USER_ID/$PASSWORD/"+entertainChannels[index4]["stream_id"].toString()+".m3u8";
                print(m3);
                String m3uFile = "http://$server:$port/"+listToWork[index4]["stream_type"]+"/"+USER_ID!+"/"+PASSWORD!.toString() +"/"+listToWork[index4]["stream_id"].toString()+".m3u8";
                print(m3uFile);

                SlingChannel channel = SlingChannel(epgs: epgs,
                    countries: [Country(id: 1,title: "UK", image: '')],id: listToWork[index4]["stream_id"],comment: false,title:listToWork[index4]["name"],image:(listToWork[index4]["stream_icon"].toString().length>0)? listToWork[index4]["stream_icon"]: "https://i5.walmartimages.com/asr/74d5a667-7df8-44f2-b9db-81f26878d316_1.c7233452b7b19b699ef96944c8cbbe74.jpeg", categories: [Category(id: 1, title: dataMap[index4]["name"])], duration: '', classification: '', rating: 4.3, sources:
                    [
                      Source(id: 1,
                          type: "LIVE",
                          title: listToWork[index4]["name"],
                          size: null,
                          quality: "FHD",  kind: "both",
                          premium: "1",
                          external: false,
                          url: m3uFile)
                    ], description: 'Description', sublabel: null, type: '', playas: '', website: '', downloadas: '', label: '' );

                channelsAsSling4.add(channel);
                newCollectedCount4++;











                setState(() {

                });
                index4++;
                if(index4<listToWork.length-1 && newCollectedCount4<limit){
                  getNewsData4(listToWork: listToWork);
                }else{
                  print("now setting");
                  print(channelsAsSling4.length);
                  GenreAsSlingChannel gg = GenreAsSlingChannel(id: 0, title: "Watch a game" ,posters:channelsAsSling4 );

                  genresAsC.add(gg);
                  ItemScrollController controller = new ItemScrollController();
                  _scrollControllers.add(controller);
                  _position_x_line_saver.add(0);
                  _counts_x_line_saver.add(gg.posters!.length);
                  setState(() {

                  });
                }

                print(epgs);
              }else{
             //   print("epg not found.tryi ng again");
                index4++;
                if(index4<listToWork.length-1 && newCollectedCount4<limit){
                  getNewsData4(listToWork: listToWork);
                }else{
                  print("now setting");
                  print(channelsAsSling4.length);
                  GenreAsSlingChannel gg = GenreAsSlingChannel(id: 0, title: "Watch a game" ,posters:channelsAsSling4 );

                  genresAsC.add(gg);
                  ItemScrollController controller = new ItemScrollController();
                  _scrollControllers.add(controller);
                  _position_x_line_saver.add(0);
                  _counts_x_line_saver.add(gg.posters!.length);
                  setState(() {

                  });
                }
              }
            }catch(e){
              print(castLink);
              print(e);
              getNewsData4(listToWork: listToWork);
            }



          }


          if(index4<kidsChannel.length-1 && newCollectedCount4<limit){
            getNewsData4(listToWork: kidsChannel);
          }else{
            print("did not started");
            print(kidsChannel.length);
            print(newCollectedCount4);
          }
//---------------
// --------------
          int newCollectedCount5 = 0;
          int index5 = 0;
          List<SlingChannel> channelsAsSling5 = [];
          getNewsData5({required List listToWork}) async {


            List epgs = [];
            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

            String? server =  sharedPreferences.getString("SERVER_URL");
            String? port =  sharedPreferences.getString("PORT");
            String? USER_ID =  sharedPreferences.getString("USER_ID");
            String? PASSWORD =  sharedPreferences.getString("PASSWORD");

            String castLink = "http://$server/player_api.php?username=$USER_ID&password=$PASSWORD&action=get_short_epg&stream_id="+listToWork[index5]["stream_id"].toString()+"&limit=1";

            var responseEPG = await http.get(Uri.parse(castLink), );

            try{
              dynamic dd  =  jsonDecode(responseEPG.body);
              //  print(responseEPG.body);
              epgs  =dd["epg_listings"];


              if(epgs.length>0){
                String m3 = "http://$server:80/live/$USER_ID/$PASSWORD/"+entertainChannels[index5]["stream_id"].toString()+".m3u8";
                print(m3);
                String m3uFile = "http://$server:$port/"+listToWork[index5]["stream_type"]+"/"+USER_ID!+"/"+PASSWORD!.toString() +"/"+listToWork[index5]["stream_id"].toString()+".m3u8";
                print(m3uFile);

                SlingChannel channel = SlingChannel(thumbBig: "https://hips.hearstapps.com/hmg-prod/images/bestteenmovies-1612822987.jpg",epgs: epgs,
                    countries: [Country(id: 1,title: "UK", image: '')],id: listToWork[index5]["stream_id"],comment: false,title:listToWork[index5]["name"],image:(listToWork[index5]["stream_icon"].toString().length>0)? listToWork[index5]["stream_icon"]: "https://i5.walmartimages.com/asr/74d5a667-7df8-44f2-b9db-81f26878d316_1.c7233452b7b19b699ef96944c8cbbe74.jpeg", categories: [Category(id: 1, title: dataMap[index5]["name"])], duration: '', classification: '', rating: 4.3, sources:
                    [
                      Source(id: 1,
                          type: "LIVE",
                          title: listToWork[index5]["name"],
                          size: null,
                          quality: "FHD",  kind: "both",
                          premium: "1",
                          external: false,
                          url: m3uFile)
                    ], description: 'Description', sublabel: null, type: '', playas: '', website: '', downloadas: '', label: '' );

                channelsAsSling5.add(channel);
                newCollectedCount5++;











                setState(() {

                });
                index5++;
                if(index5<listToWork.length-1 && newCollectedCount5<limit){
                  getNewsData5(listToWork: listToWork);
                }else{
                  print("now setting Movies and TV Shows");
                  print(channelsAsSling5.length);
                  GenreAsSlingChannel gg = GenreAsSlingChannel(id: 0, title: "Movies and TV Shows" ,posters:channelsAsSling5 );

                  genresAsC.add(gg);
                  ItemScrollController controller = new ItemScrollController();
                  _scrollControllers.add(controller);
                  _position_x_line_saver.add(0);
                  _counts_x_line_saver.add(gg.posters!.length);
                  setState(() {

                  });
                }

                print(epgs);
              }else{
             //   print("epg not found.tryi ng again");
                index5++;
                if(index5<listToWork.length-1 && newCollectedCount5<limit){
                  getNewsData5(listToWork: listToWork);
                }else{
                  print("now setting Movies and TV Shows");
                  print(channelsAsSling5.length);
                  GenreAsSlingChannel gg = GenreAsSlingChannel(id: 0, title: "Movies and TV Shows" ,posters:channelsAsSling5 );

                  genresAsC.add(gg);
                  ItemScrollController controller = new ItemScrollController();
                  _scrollControllers.add(controller);
                  _position_x_line_saver.add(0);
                  _counts_x_line_saver.add(gg.posters!.length);
                  setState(() {

                  });
                }
              }
            }catch(e){
              print(castLink);
              print(e);
              getNewsData5(listToWork: listToWork);
            }



          }


          if(index5<MovieChannel.length-1 && newCollectedCount5<limit){
            getNewsData5(listToWork: MovieChannel);
          }else{
            print("did not started");
            print(MovieChannel.length);
            print(newCollectedCount5);
          }
//---------------
          print(newsChannels.length);
          print(entertainChannels.length);
          print(kidsChannel.length);
          print(sportsChannel.length);

          if(false)  for(int i = 0 ; i < dataMap.length ; i++){



            //String data = dataMap["data"];
            //   dynamic d = convert.jsonDecode(data);
            List someChannelList = [];
            try{
              someChannelList = dataMap[i]["list"];
            }catch(e){
              print(e);
              print(dataMap[i]);

            }
            //  List someChannelList = qS.docs[i].get("list");

            // dynamic da =  convert.jsonDecode(data);
            List<SlingChannel> oneCategoryChannels = [];




            // String SERVER = "http://connect.proxytx.cloud";
            // String PORT = "80";
            // String EMAIL = "4fe8679c08";
            // String PASSWORD = "2016";
            // List someChannelList = da["list"];


            for(int j = 0 ; j < someChannelList.length ; j++){

              String m3uFile = "http://$server:$port/"+someChannelList[j]["stream_type"]+"/"+USER_ID!+"/"+PASSWORD!.toString() +"/"+someChannelList[j]["stream_id"].toString()+".m3u8";
              print(m3uFile);

              SlingChannel channel = SlingChannel(
                  countries: [Country(id: 1,title: "UK", image: '')],id: someChannelList[j]["stream_id"],comment: false,title:someChannelList[j]["name"],image:(someChannelList[j]["stream_icon"].toString().length>0)? someChannelList[j]["stream_icon"]: "https://i5.walmartimages.com/asr/74d5a667-7df8-44f2-b9db-81f26878d316_1.c7233452b7b19b699ef96944c8cbbe74.jpeg", categories: [Category(id: 1, title: dataMap[i]["name"])], duration: '', classification: '', rating: 4.3, sources:
              [
                Source(id: 1,
                    type: "LIVE",
                    title: someChannelList[j]["name"],
                    size: null,
                    quality: "FHD",  kind: "both",
                    premium: "1",
                    external: false,
                    url: m3uFile)
              ], description: 'Description', sublabel: null, type: '', playas: '', website: '', downloadas: '', label: '' );

              // allChannel.add(channel);
              oneCategoryChannels.add(channel);
            }








            String name = "";
            try{
              name = dataMap[i]["name"]??"--";
            }catch(e){
              print(e);
            }
            GenreAsSlingChannel gg = GenreAsSlingChannel(id: i, title: name ,posters:oneCategoryChannels );

            genresAsC.add(gg);
            ItemScrollController controller = new ItemScrollController();
            _scrollControllers.add(controller);
            _position_x_line_saver.add(0);
            _counts_x_line_saver.add(gg.posters!.length);


          }
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










      }

      //<---------Recently Added starts  ----------->


      _showData();

    } else {
      _showTryAgain();
    }

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:RawKeyboardListener(
        focusNode: home_focus_node,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
            RawKeyDownEvent rawKeyDownEvent = event;
            RawKeyEventDataAndroid rawKeyEventDataAndroid =rawKeyDownEvent.data as RawKeyEventDataAndroid;

            switch (rawKeyEventDataAndroid.keyCode) {
              case KEY_CENTER:
                _goToSearch();
                _openSlide();
                _goToMovies();
                _goToSeries();
                _goToChannels();
                // _goToMyList();
                _goToTVGUIDE();
                _goToSettings();
                _goToProfile();
                _tryAgain();
                _goToMovieDetail();
                _goToChannelDetail();
                break;
              case KEY_UP:
                if(_visibile_loading){
                  print("playing sound ");
                  break;
                }
                if(_visibile_error){
                  if(posty ==  -2){
                    print("playing sound ");
                  }else if(posty == -1){
                    posty--;
                    postx=0;
                  }
                  break;
                }
                if(posty ==  -2){
                  print("playing sound ");
                }else if(posty == -1){
                  posty--;
                  postx=2;
                }else if(posty == 0){
                  posty--;
                  postx=0;
                }
                else{
                  posty--;
                  postx = _position_x_line_saver[posty];
                  _scrollToIndexXY(postx,posty);
                }
                break;
              case KEY_DOWN:
                if(_visibile_error){
                  if(posty < -1)
                    posty++;
                  else
                    print("playing sound ");
                  break;
                }
                if(_visibile_loading){
                  print("playing sound ");
                  break;
                }
                if(genresAsC.length-1==posty){
                  print("playing sound ");
                }else{
                  posty++;
                  if(posty >= 0){
                    postx = _position_x_line_saver[posty];
                    _scrollToIndexXY(postx,posty);
                  }

                }
                break;
              case KEY_LEFT:
                controllerInited = false;
                if(_visibile_error){
                  if(posty < -1)
                    posty++;
                  else
                    print("playing sound ");
                  break;
                }
                if(posty == -2){
                  if(postx == 0){
                    print("playing sound ");
                  }else{
                    postx--;
                  }
                }else if (posty == -1){
                  _carouselController.previousPage();
                }else{
                  if(postx == 0){
                    print("playing sound ");
                  }else{
                    postx--;
                    _position_x_line_saver[posty]=postx;
                    _scrollToIndexXY(postx,posty);
                  }
                }
                break;
              case KEY_RIGHT:
                switch(posty){
                  case -1:
                    if(_visibile_loading || _visibile_error){
                      print("playing sound ");
                      break;
                    }
                    _carouselController.nextPage();
                    break;
                  case -2:
                    if(postx == 7)
                      print("playing sound ");
                    else
                      postx++;
                    break;
                  default:
                    if(_counts_x_line_saver[posty]-1 == postx){
                      print("playing sound ");
                    }else{
                      postx++;
                      _position_x_line_saver[posty]=postx;
                      _scrollToIndexXY(postx,posty);
                    }
                    break;
                }

                break;
              default:
                break;
            }
            if(genresAsC.length>0){
              controllerInited = false;
              if( posty == 0){
                selected_poster = null;
                selected_channel =  null;
              }

              if( posty == 0){
                controllerInited = false;
                // selected_channel =null;
                selected_channel =  genresAsC[posty].posters![postx];
              }
              if(posty > 0){
                controllerInited = false;
                //  selected_channel =null;
                selected_channel =  genresAsC[posty].posters![postx];
              }
            }
            setState(() {

            });
          }
        },
        child: Stack(
          children: [
           if(false) Positioned(
              right: 0,
              top: 0,
              // left: MediaQuery.of(context).size.width/4,
              // bottom: MediaQuery.of(context).size.height/4,
              bottom:0,
              child:getBackgroundImage(),

            ),
            if(false)   Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.black,Colors.black54.withOpacity(0.5),Colors.black54.withOpacity(0.2),Colors.transparent],
                        // colors: [Colors.black,Colors.black.withOpacity(0.4),Colors.black.withOpacity(0.2),Colors.black.withOpacity(0.1),Colors.transparent],
                      )
                  )
              ),
            ),
            if(false)     Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                  height: MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height/3),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black, Colors.transparent, Colors.transparent],
                        // colors: [Colors.black,Colors.black.withOpacity(0.4),Colors.black.withOpacity(0.2),Colors.black.withOpacity(0.1),Colors.transparent],

                      )
                  )
              ),
            ),
            Positioned(
              top:  10,
              left: 50,
              right: 50,
              child: AnimatedOpacity(
                opacity: (posty < 0)? 0 : 1,
                duration: Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: (){
                    setState(() {
                      posty = -1;
                    });
                  },
                  child: Container(
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
            if(_visibile_success)
            // SlideWidget(poster:selected_poster,channel: selected_channel,posty:posty,postx:postx,carouselController: _carouselController,side_current:side_current,slides:slides,move :(value){
            //   setState(() {
            //     side_current = value;
            //   });
            // }),
              if(_visibile_loading)
                HomeLoadingWidget(),
            if(_visibile_error)
              _tryAgainWidget(),
            if(true || _visibile_success)
              AnimatedPositioned(
                bottom: 0,
                left: 0,
                right: 0,
                duration: Duration(milliseconds: 200),
                height: (posty < 0)?(MediaQuery.of(context).size.height/1)  -(50+MediaQuery.of(context).viewPadding.top):(MediaQuery.of(context).size.height/1)-(50+MediaQuery.of(context).viewPadding.top),
                child: Container(
                  height: (posty < 0)?(MediaQuery.of(context).size.height/1) -(50+MediaQuery.of(context).viewPadding.top):(MediaQuery.of(context).size.height/1)-(50+MediaQuery.of(context).viewPadding.top),
                  child: ScrollConfiguration(
                    behavior: MyBehavior(),   // From this behaviour you can change the behaviour
                    child: ScrollablePositionedList.builder(
                      itemCount: genresAsC.length,
                      scrollDirection: Axis.vertical,
                      itemScrollController: _scrollController,
                      itemBuilder: (context, jndex) {
                        if(true|| genresAsC[jndex].id == -3){



                          // return M_C_Widget(jndex:jndex,posty: posty,postx: postx,scrollController: _scrollControllers[jndex],title: genres[jndex].title,posters : genres[jndex].posters);
                          return SlingWidgetWidget(jndex:jndex,postx: postx,posty: posty,scrollController: _scrollControllers[jndex],size: MediaQuery.of(context).size.longestSide*0.018,title:genresAsC[jndex].title,channels: genresAsC[jndex].posters!);
                        }else{
                          return Text("NN",style: TextStyle(color: Colors.white),);
                          //   return MoviesWidget(jndex:jndex,posty: posty,postx: postx,scrollController: _scrollControllers[jndex],title: genresAsC[jndex].title,posters : genresAsC[jndex].posters);
                        }
                      },
                    ),
                  ),
                ),
              ),
            NavigationWidget(postx:postx,posty:posty,selectedItem : 2,image : image, logged : logged),
          if(false)  if(posty > -1 && genresAsC.length>0) Positioned(bottom: MediaQuery.of(context).size.height*0.45,left: MediaQuery.of(context).size.width*0.027,child: Column(mainAxisAlignment: MainAxisAlignment.end,crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(selected_channel!.title,style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.longestSide*0.020),),

                // if(epgs.length>0)  Row(
                //   children: [
                //
                //     Container(width: MediaQuery.of(context).size.width*0.2,child: LinearProgressIndicator(color: Colors.grey,value: ((( ((int.parse(epgs[0]["stop_timestamp"])*1000)-(DateTime.now().millisecondsSinceEpoch)-(60*60*1000)))))/( (int.parse(epgs[0]["stop_timestamp"])-int.parse(epgs[0]["start_timestamp"]))/60),),),
                //     if(epgs.length>0) Padding(
                //       padding:  EdgeInsets.only(left: MediaQuery.of(context).size.width*0.01),
                //       child: Text("Now "+utf8.decode(base64.decode(epgs[0]["title"]))+" "+((( ((int.parse(epgs[0]["stop_timestamp"])*1000)-(DateTime.now().millisecondsSinceEpoch)-(60*60*1000))))/6000000).toStringAsFixed(0)+" min remaining",style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.longestSide*0.015),),
                //     ),
                //
                //
                //   ],
                // ),
                if(epgs.length>0) Row(crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(utf8.decode(base64.decode(epgs[0]["title"]))
                      // +" "+((( ((int.parse(epgs[0]["stop_timestamp"])*1000)-(DateTime.now().millisecondsSinceEpoch))))/(1000*60*60)).toStringAsFixed(0)+" min remaining"
                      ,style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.longestSide*0.015),),
                    Text(" (now)"
                      // +" "+((( ((int.parse(epgs[0]["stop_timestamp"])*1000)-(DateTime.now().millisecondsSinceEpoch))))/(1000*60*60)).toStringAsFixed(0)+" min remaining"
                      ,style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.longestSide*0.009),)
                  ],
                ),

                if(epgs.length>0)  Row(
                  children: [
                    Text(   DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(-(60*60*0)+int.parse(epgs[0]["start_timestamp"])*1000)),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
                    Text(  " - ",style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
                    Text(   DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(-(60*60*0)+int.parse(epgs[0]["stop_timestamp"])*1000)),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),


                  ],
                ),


                if(epgs.length>1) Row(crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(utf8.decode(base64.decode(epgs[1]["title"]))
                      // +" "+((( ((int.parse(epgs[0]["stop_timestamp"])*1000)-(DateTime.now().millisecondsSinceEpoch))))/(1000*60*60)).toStringAsFixed(0)+" min remaining"
                      ,style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.longestSide*0.015),),
                    Text(" (Up next)"
                      // +" "+((( ((int.parse(epgs[0]["stop_timestamp"])*1000)-(DateTime.now().millisecondsSinceEpoch))))/(1000*60*60)).toStringAsFixed(0)+" min remaining"
                      ,style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.longestSide*0.009),)
                  ],
                ),

                if(epgs.length>1)  Row(
                  children: [
                    Text(   DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(-(60*60*0)+int.parse(epgs[1]["start_timestamp"])*1000)),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
                    Text(  " - ",style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
                    Text(   DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(-(60*60*0)+int.parse(epgs[1]["stop_timestamp"])*1000)),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),


                  ],
                ),

                if(epgs.length>2) Row(crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(utf8.decode(base64.decode(epgs[2]["title"]))
                      // +" "+((( ((int.parse(epgs[0]["stop_timestamp"])*1000)-(DateTime.now().millisecondsSinceEpoch))))/(1000*60*60)).toStringAsFixed(0)+" min remaining"
                      ,style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.longestSide*0.015),),
                    Text(" (Later)"
                      // +" "+((( ((int.parse(epgs[0]["stop_timestamp"])*1000)-(DateTime.now().millisecondsSinceEpoch))))/(1000*60*60)).toStringAsFixed(0)+" min remaining"
                      ,style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.longestSide*0.009),)
                  ],
                ),

                if(epgs.length>2)  Row(
                  children: [
                    Text(   DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(-(60*60*0)+int.parse(epgs[2]["start_timestamp"])*1000)),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
                    Text(  " - ",style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),
                    Text(   DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(-(60*60*0)+int.parse(epgs[2]["stop_timestamp"])*1000)),style:  TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.height*0.015),),


                  ],
                ),


                if(false)  if(epgs.length>0)  Row(
                  children: [



                    Container(width: MediaQuery.of(context).size.width*0.2,child: LinearProgressIndicator(value:(((( ((int.parse(epgs[0]["stop_timestamp"])*1000)-(DateTime.now().millisecondsSinceEpoch)-(60*60*1000))))/6000000))/(( (int.parse(epgs[0]["stop_timestamp"])-int.parse(epgs[0]["start_timestamp"]))/60))),),
                    if(epgs.length>0) Padding(
                      padding:  EdgeInsets.only(left: MediaQuery.of(context).size.width*0.01),
                      child: Text("Now "+utf8.decode(base64.decode(epgs[0]["title"]))+" "+((( ((int.parse(epgs[0]["stop_timestamp"])*1000)-(DateTime.now().millisecondsSinceEpoch)-(60*60*1000))))/6000000).toStringAsFixed(0)+" min remaining",style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.longestSide*0.015),),
                    ),


                  ],
                ),

                //  Container(width: 100,child: LinearProgressIndicator(value: 0.1,)),
                //  if(epgs.length>0) Text("Now "+utf8.decode(base64.decode(epgs[0]["title"]))+" "+( (int.parse(epgs[0]["stop_timestamp"])-int.parse(epgs[0]["start_timestamp"]))/60).toStringAsFixed(0)+" min",style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.longestSide*0.015),),
                //  if(epgs.length>1)   Text("Later "+utf8.decode(base64.decode(epgs[1]["title"])),style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.longestSide*0.015),),
                // if(epgs.length>1)   Text(epgs[0]["stop_timestamp"]+" --  "+DateTime.now().millisecondsSinceEpoch.toString(),style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.longestSide*0.015),),

                Container(margin: EdgeInsets.only(top:MediaQuery.of(context).size.longestSide*0.015 ),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        child: Center(child: Icon(Icons.play_arrow,size: 30,color: Colors.white)),
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1,color:Colors.black12))
                        ),
                      ),
                      Expanded(
                          child: Center(
                              child: Text(
                                "Watch Now",
                                style: TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.011,
                                    color:Colors.white,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          )
                      )
                    ],
                  ),
                  height: 40,
                  width: MediaQuery.of(context).size.longestSide*0.14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white30,
                  ),
                ),
              ],
            ),),
          ],
        ),
      ),
    );
  }
  void  _goToMovies(){
    if(posty == -2 && postx == 2){
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>SLING_TV_S(),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    }
  }



  void  _goToSearch(){
    if(posty == -2 && postx == 0){
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Search(),
          transitionDuration: Duration(seconds: 0),
        ),
      );
      FocusScope.of(context).requestFocus(null);
    }
  }

  void  _goToTVGUIDE(){
    if(posty == -2 && postx == 5){

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => MyList(),
          transitionDuration: Duration(seconds: 0),
        ),
      );
      FocusScope.of(context).requestFocus(null);

    }
  }
  void  _goToMyList(){
    if(posty == -2 && postx == 5){
      if(logged == true){
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => MyList(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
        FocusScope.of(context).requestFocus(null);
      }else{
        push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => Auth(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      }
    }
  }
  void  _goToProfile(){

    if(posty == -2 && postx == 7){
      if(logged == true){
        push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => Profile(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      }else{
        push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => Auth(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      }

    }
  }
  void  _goToSeries(){
    if(posty == -2 && postx == 3){
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SeriesAsHome(),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    }
  }
  void  _goToChannels(){
    if(posty == -2 && postx == 4){
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => TvChannelsHome(),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    }
  }
  void  _goToSettings(){
    if(posty == -2 && postx == 6){
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Settings(),
          transitionDuration: Duration(seconds: 0),
        ),
      );
      FocusScope.of(context).requestFocus(null);
    }
  }
  void _goToMovieDetail() {
    // if(posty >= 0 ){
    //   if(genres[posty] != null){
    //     Navigator.push(
    //       context,
    //       PageRouteBuilder(
    //         pageBuilder: (context, animation1, animation2) => (genres[posty].posters![postx].type == "serie")?Serie(serie:genres[posty].posters![postx]):Movie(movie:genres[posty].posters![postx]),
    //         transitionDuration: Duration(seconds: 0),
    //       ),
    //     );
    //     FocusScope.of(context).requestFocus(null);
    //   }
    // }
  }
  void _goToChannelDetail() {
    // if(selected_channel!=null ){
    //   Navigator.push(
    //     context,
    //     PageRouteBuilder(
    //       pageBuilder: (context, animation1, animation2) => ChannelDetail(channel:selected_channel),
    //       transitionDuration: Duration(seconds: 0),
    //     ),
    //   );
    //   FocusScope.of(context).requestFocus(null);
    // }
  }

  Future _scrollToIndexXY(int x,int y) async {
    _scrollControllers[y].scrollTo(index: x>0? x:x,duration: Duration(milliseconds: 500),alignment: 0.40,curve: Curves.fastOutSlowIn);
    _scrollController.scrollTo(index: y,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
  }


  void _showLoading() {
    setState(() {
      _visibile_loading = true;
      _visibile_error= false;
      _visibile_success= false;

    });
  }
  void _showTryAgain() {
    setState(() {
      _visibile_loading = false;
      _visibile_error= true;
      _visibile_success= false;

    });
  }
  void _showData() {
    setState(() {
      _visibile_loading = false;
      _visibile_error= false;
      _visibile_success= true;
    });
  }
  void _tryAgain(){
    if(_visibile_error && posty == -1){
      _getList();
    }
  }
  void _openSlide(){
    if(!_visibile_error && posty == -1){
      Slide slide = slides[side_current];
      if(slide.channel != null){
        Future.delayed(Duration(milliseconds: 50),(){
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => ChannelDetail(channel: slide.channel),
              transitionDuration: Duration(seconds: 0),
            ),
          );
        });
      }
      if(slide.poster != null){
        Future.delayed(Duration(milliseconds: 50),(){
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => ( slide.poster?.type == "serie")? Serie(serie: slide.poster):Movie(movie: slide.poster),
              transitionDuration: Duration(seconds: 0),
            ),
          );
        });
      }
    }
  }
  Widget _tryAgainWidget(){
    return Positioned(
      bottom: 0,
      left: 45,
      right: 45,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height:  MediaQuery.of(context).size.height -70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error,
                  color: Colors.white,
                ),
                SizedBox(width: 5),
                Text("Something wrong !",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text("Please check your internet connexion and try again  !",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: (){
                setState(() {
                  posty = - 1;
                  Future.delayed(Duration(milliseconds: 100),(){
                    _tryAgain();
                    posty = - 2;
                  });
                });
              },
              child: Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 40,
                  width: 250,
                  decoration: BoxDecoration(
                    border:Border.all(color: Colors.white54,width: 1),
                    color:(_visibile_error && posty == -1)? Colors.white: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          height:40,
                          width: 40,
                          decoration: BoxDecoration(
                            color:(_visibile_error && posty == -1)?Colors.black: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon( Icons.refresh ,color:(_visibile_error && posty == -1)?Colors.white: Colors.black,)
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Try Again",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color:(_visibile_error && posty == -1)?Colors.black: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget getBackgroundImage()  {
    String SERVER = "http://connect.proxytx.cloud";
    String PORT = "80";
    String EMAIL = "4fe8679c08";
    String PASSWORD = "2016";
    Widget tvSmall  = Container(child: Center(),);

    if(selected_channel!=null && selected_channel!.id!=null ){
      String castLink = "http://connect.proxytx.cloud/player_api.php?username=4fe8679c08&password=2016&action=get_short_epg&stream_id="+selected_channel!.id.toString()+"&limit=3";
      print(castLink);
      http.get(Uri.parse(castLink), ).then((value) {

        print("sort epg res "+ value.body);
        String  epg = value.body;
        dynamic dd = jsonDecode(epg);

        setState(() {
          epgs = dd["epg_listings"];
        });

      });
    }










    if(false ||  posty < 0 && slides.length>0 )
      return  CachedNetworkImage(imageUrl:  slides[side_current].image , fit: BoxFit.cover,width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,fadeInDuration: Duration(seconds: 1));
    if(false ||posty == 0 && channels.length>0)
      return  CachedNetworkImage(imageUrl:channels[postx].image,fit: BoxFit.cover,width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,fadeInDuration: Duration(seconds: 1));
    if(posty > -1 && genresAsC.length>0 && nowInitialingLink!=selected_channel!.sources.first.url){

      print("master");
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

          nowInitialingLink = selected_channel!.sources.first.url;
          _controller = vP.VideoPlayerController.network(selected_channel!.sources.first.url)
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
          nowInitialingLink = selected_channel!.sources.first.url;
          _controller = vP.VideoPlayerController.network(selected_channel!.sources.first.url)
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


      print("if else finish");
      tvSmall =   (controllerInited==true && _controller!=null &&   _controller!.value.isInitialized == true)? Container(width: MediaQuery.of(context).size.width,height:  MediaQuery.of(context).size.height,child: vP.VideoPlayer(_controller!)) : CupertinoActivityIndicator(color: Colors.white,);




    }else{
      return  (controllerInited==true && _controller!=null &&   _controller!.value.isInitialized == true)? Container(width: MediaQuery.of(context).size.width,height:  MediaQuery.of(context).size.height,child: vP.VideoPlayer(_controller!)): CupertinoActivityIndicator(color: Colors.redAccent,);
    }
    return  tvSmall;
    return Container(color: Colors.black,);




  }
}


class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

