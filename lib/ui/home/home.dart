
import 'dart:convert';
import 'dart:io';
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
import 'package:need_resume/need_resume.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:convert' as convert;
import 'package:transparent_image/transparent_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../SlingTv/sling_scroll_tv.dart';
import '../../SlingTv/sling_tv.dart';
import '../../SlingTv/sling_tv_activity.dart';
import '../../TvGuide/tvguide.dart';
import '../../model/channel.dart';
import '../../model/country.dart';
import '../../model/source.dart';
import '../../series_like_home/home.dart';
import '../channel/channel_as_home.dart';

/// A [StatelessWidget] which demonstrates
/// how to consume and interact with a [CounterBloc].
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}




class _HomeState extends ResumableState<Home> {


  List<Genre> genres = [];
  List<Slide> slides = [];
  List<model.Channel> channels = [];


  int postx = 1;
  int posty = -2;
  int side_current = 0;
  CarouselController _carouselController = CarouselController();
  ItemScrollController _scrollController = ItemScrollController();
  List<ItemScrollController> _scrollControllers = [];
  List<int> _position_x_line_saver = [];
  List<int> _counts_x_line_saver = [];
  FocusNode home_focus_node = FocusNode();
  Poster? selected_poster;
  model.Channel? selected_channel;

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
    var response =await apiRest.getHomeData();
    if(response == null){
      _showTryAgain();
    }else{
      if (response.statusCode == 200) {


        bool showSlide = true;

        if(false){
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



            Genre gg = Genre(id: 1, title: "Recently added",posters:posters );

            genres.add(gg);
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

        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

        String? server =  sharedPreferences.getString("SERVER_URL");
        String? port =  sharedPreferences.getString("PORT");
        String? USER_ID =  sharedPreferences.getString("USER_ID");
        String? PASSWORD =  sharedPreferences.getString("PASSWORD");
        if(true ){
          //continue watching


          fire.QuerySnapshot recentWatch = await  fire.FirebaseFirestore.instance.collection("watchHistory"+USER_ID.toString()).where("type",isEqualTo: "movie").get();


          List<fire.QueryDocumentSnapshot> allData = recentWatch.docs;

          allData.sort((a, b) => a.get("time").compareTo(b.get("time")));

          allData = allData.reversed.toList();


          List<Poster> posters = [];
          for(int i = 0 ; i < recentWatch.docs.length ; i++){

            try{
              Map<String, dynamic> dataMap = allData[i].data() as Map<String, dynamic>;

             // String listStr = recentWatch.docs[i].get("data");
             // dynamic li = convert.jsonDecode(listStr);
              //  String SERVER = "http://connect.proxytx.cloud";
              //  String PORT = "80";
              //  String EMAIL = "4fe8679c08";
              //  String PASSWORD = "2016";
              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

              String? server =  sharedPreferences.getString("SERVER_URL");
              String? port =  sharedPreferences.getString("PORT");
              String? USER_ID =  sharedPreferences.getString("USER_ID");
              String? PASSWORD =  sharedPreferences.getString("PASSWORD");
                String link ="http://$server:$port"+"/"+dataMap["data"]["stream_type"]+"/"+USER_ID!+"/"+PASSWORD.toString() +"/"+dataMap["data"]["stream_id"].toString()+"."+dataMap["data"]["container_extension"];
                Poster poster1 = Poster(raw_data:dataMap["data"] ,id:dataMap["data"]["stream_id"],
                    title:dataMap["data"]["name"],
                    type: "type",
                    label: null,fromIsWaching: true,
                    resumeAt:dataMap["duration"] ,
                    total:dataMap["total_duration"] ,
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

          if(posters.length>0){
            Genre gg = Genre(id: 99, title: "Contiue watching",posters:posters );

            genres.add(gg);
            ItemScrollController controller = new ItemScrollController();
            _scrollControllers.add(controller);
            _position_x_line_saver.add(0);
            _counts_x_line_saver.add(gg.posters!.length);
          }













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
        if(true ){
          //continue watching


          fire.QuerySnapshot recentWatch = await  fire.FirebaseFirestore.instance.collection("favourites").where("type",isEqualTo: "movie").where("uid",isEqualTo: USER_ID).get();


          List<fire.QueryDocumentSnapshot> allData = recentWatch.docs;

          allData.sort((a, b) => a.get("time").compareTo(b.get("time")));

          allData = allData.reversed.toList();


          List<Poster> posters = [];
          for(int i = 0 ; i < recentWatch.docs.length ; i++){

            try{
              Map<String, dynamic> dataMap = allData[i].data() as Map<String, dynamic>;
              //dataMap = dataMap["raw"];

              // String listStr = recentWatch.docs[i].get("data");
              // dynamic li = convert.jsonDecode(listStr);
              //  String SERVER = "http://connect.proxytx.cloud";
              //  String PORT = "80";
              //  String EMAIL = "4fe8679c08";
              //  String PASSWORD = "2016";
              // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
              //
              // String? server =  sharedPreferences.getString("SERVER_URL");
              // String? port =  sharedPreferences.getString("PORT");
              // String? USER_ID =  sharedPreferences.getString("USER_ID");
              // String? PASSWORD =  sharedPreferences.getString("PASSWORD");
              String link ="http://$server:$port"+"/"+dataMap["raw"]["stream_type"]+"/"+USER_ID!+"/"+PASSWORD.toString() +"/"+dataMap["raw"]["stream_id"].toString()+"."+dataMap["raw"]["container_extension"];
              Poster poster1 = Poster(raw_data:dataMap["raw"] ,id:dataMap["raw"]["stream_id"],
                  title:dataMap["raw"]["name"],
                  type: "type",
                  label: null,
                  //fromIsWaching: true,
                 // resumeAt:dataMap["duration"] ,
                //  total:dataMap["total_duration"] ,
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
                  image: dataMap["raw"]["stream_icon"]??"https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png",
                  cover:dataMap["raw"]["stream_icon"]??"https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png",
                  trailer: null,
                  genres: [Genre(id: i, title: "My Favourites")],
                  sources:[Source(size: "",id: 1, type: dataMap["raw"]["container_extension"], title:dataMap["raw"]["container_extension"], quality: "FHD",  kind: "both", premium: "1", external: false, url:link)] );

              posters.add(poster1);








            }catch(e){

              print(e);
              print("cach recent");

            }


          }

          if(posters.length>0){
            Genre gg = Genre(id: 100, title:"My Favourites",posters:posters );

            genres.add(gg);
            ItemScrollController controller = new ItemScrollController();
            _scrollControllers.add(controller);
            _position_x_line_saver.add(0);
            _counts_x_line_saver.add(gg.posters!.length);
          }













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
        makeMoVieUI({required List allVodCategory}) async {

          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

          String? server =  sharedPreferences.getString("SERVER_URL");
          String? port =  sharedPreferences.getString("PORT");
          String? USER_ID =  sharedPreferences.getString("USER_ID");
          String? PASSWORD =  sharedPreferences.getString("PASSWORD");

          for(int i = 0 ; i < allVodCategory.length; i ++){

            //  List movies = await apiRest.getMoviesOfCategory(idCategory: allVodCategory[i]["category_id"]);
            List movies = allVodCategory[i]["list"];
            print("loop "+movies.length.toString());
            try{
              List li = movies;

              List<Poster> posters = [];

              for(int k = 0 ;k < li.length ;k++ ){
                print(li[k]);


                // String SERVER = "http://connect.proxytx.cloud";
                // String PORT = "80";
                // String EMAIL = "4fe8679c08";
                // String PASSWORD = "2016";

               String link ="http://$server:$port/"+li[k]["stream_type"]+"/"+USER_ID!+"/"+PASSWORD.toString() +"/"+li[k]["stream_id"].toString()+"."+li[k]["container_extension"];

                modelS.Source sss = Source(size: "",id: 1, type: li[k]["container_extension"], title:li[k]["container_extension"], quality: "FHD",  kind: "both", premium: "1", external: false, url:link);
                modelS.Source sss2 = Source(size: "",id: 2, type: li[k]["container_extension"], title:li[k]["container_extension"], quality: "FHD",  kind: "both", premium: "1", external: false, url:link);
                modelS.Source sss3 = Source(size: "",id: 3, type: li[k]["container_extension"], title:li[k]["container_extension"], quality: "FHD",  kind: "both", premium: "1", external: false, url:link);
                Poster poster1 = Poster(raw_data:li[k],id:li[k]["stream_id"],
                    title:li[k]["name"],
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
                    rating:0.0,
                    image: li[k]["stream_icon"]??"https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png",
                    cover:li[k]["stream_icon"]??"https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png",
                    trailer: null,
                    genres: [Genre(id: k, title:  allVodCategory[i]["name"])],
                    sources:[sss,sss2,sss3] );

                posters.add(poster1);





              }

              Genre gg = Genre(id: i, title: allVodCategory[i]["name"],posters:posters );

              genres.add(gg);
              ItemScrollController controller = new ItemScrollController();
              _scrollControllers.add(controller);
              _position_x_line_saver.add(0);
              _counts_x_line_saver.add(gg.posters!.length);
            }catch(e){
              print(e);

            }

          }
          print("Loop finished");
          _showData();
        }

        if(await  apiRest.checkFile("mc.json") == false){

          List allVodCategory =  await apiRest.getMovCateDetails();

          makeMoVieUI(allVodCategory: allVodCategory);



        }else{

          File f = await apiRest.localFile("mc.json");

          String data = await f.readAsString();
          try{
           // value = jsonDecode(data);

            makeMoVieUI(allVodCategory: jsonDecode(data));
          }catch(e){

          }
          apiRest.getMovCateDetails();

        }

        //<---------Recently Added starts  ----------->




      } else {
        _showTryAgain();
      }
    }
   try{
      if(mounted) setState(() {

      });
   }catch(e){

   }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
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
                //_goToMyList();
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
                  postx=1;
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
                if(genres.length-1==posty){
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
                  try{
                    _carouselController.previousPage();

                  }catch(e){

                  }
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
            if(genres.length>0){

                if(genres[0].id == -3 && posty == 0){
                  selected_poster = null;
                  selected_channel =  channels[postx];
                }

                if(genres[0].id != -3 && posty == 0){
                  selected_channel =null;
                  selected_poster =  genres[posty].posters![postx];
                }
                if(posty > 0){
                  selected_channel =null;
                  selected_poster =  genres[posty].posters![postx];
                }
            }
            setState(() {

            });
          }
        },
        child: Stack(
          children: [
            Positioned(
                right: 0,
                top: 0,
                left: MediaQuery.of(context).size.width/4,
               // bottom: MediaQuery.of(context).size.height/4,
                bottom: MediaQuery.of(context).size.height/8,
                child:AnimatedSwitcher(
                  child: getBackgroundImage(),
                  duration: Duration(seconds: 1),
                ),

            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.black,Colors.black,Colors.black54,Colors.black54,Colors.black54],
                       // colors: [Colors.black,Colors.black.withOpacity(0.4),Colors.black.withOpacity(0.2),Colors.black.withOpacity(0.1),Colors.transparent],
                      )
                  )
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                  height: MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height/3),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black,Colors.black, Colors.transparent, Colors.transparent],
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
            SlideWidget(poster:selected_poster,channel: selected_channel,posty:posty,postx:postx,carouselController: _carouselController,side_current:side_current,slides:slides,move :(value){
              setState(() {
                side_current = value;
              });
            }),
            if(_visibile_loading)
              HomeLoadingWidget(),
            if(_visibile_error)
              _tryAgainWidget(),
            if(_visibile_success)
            AnimatedPositioned(
              bottom: 0,
              left: 0,
              right: 0,
              duration: Duration(milliseconds: 200),
              height: MediaQuery.of(context).viewPadding.top ==0?  ((posty < 0)?(MediaQuery.of(context).size.height/2) + 20:(MediaQuery.of(context).size.height/2)+50):(MediaQuery.of(context).size.height/1)-(50+MediaQuery.of(context).viewPadding.top),

           //   height: (posty < 0)?(MediaQuery.of(context).size.height/2)  -50:(MediaQuery.of(context).size.height/2)+200,
              child: ScrollConfiguration(
                behavior: MyBehavior(),   // From this behaviour you can change the behaviour
                child: ScrollablePositionedList.builder(
                  itemCount: genres.length,
                  scrollDirection: Axis.vertical,
                  itemScrollController: _scrollController,
                  itemBuilder: (context, jndex) {
                    if(genres[jndex].id == -3){

                      return ChannelsWidget(jndex:jndex,postx: postx,posty: posty,scrollController: _scrollControllers[jndex],size: MediaQuery.of(context).size.longestSide*0.01,title: "TV Channels",channels: channels);
                    }else{
                      return MoviesWidget(jndex:jndex,posty: posty,postx: postx,scrollController: _scrollControllers[jndex],title: genres[jndex].title,posters : genres[jndex].posters);
                    }
                  },
                ),
              ),
            ),
            NavigationWidget(postx:postx,posty:posty,selectedItem : 1,image : image, logged : logged),
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
         // pageBuilder: (context, animation1, animation2) => TVSLING(),
          pageBuilder: (context, animation1, animation2) => SLING_TV_S(),
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
  void  _goToTVGUIDE(){
    if(posty == -2 && postx == 5){

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => TVGUIDE(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
        FocusScope.of(context).requestFocus(null);

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
  Future<void>  _goToChannels() async {
    if(posty == -2 && postx == 4){
      SharedPreferences s = await SharedPreferences.getInstance();
      int? t = s.getInt("tv_type");

      // tv_type

      if(t!=null && t==1){
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => TvChannelsHome(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      }else{
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => SlingTv(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      }
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
    if(posty >= 0 ){
      if(genres[posty] != null){

        if(genres[posty].posters![postx].type == "serie"){

        }else{
          // Fluttertoast.showToast(
          //   msg: genres[posty].posters![postx].title,
          //   gravity: ToastGravity.BOTTOM,
          //   backgroundColor: Colors.green,
          //   textColor: Colors.white,
          // );
        }


        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => (genres[posty].posters![postx].type == "serie")?Serie(serie:genres[posty].posters![postx]):Movie(movie:genres[posty].posters![postx]),
            transitionDuration: Duration(seconds: 0),
          ),
        );
        FocusScope.of(context).requestFocus(null);
      }
    }
  }
  void _goToChannelDetail() {
    if(posty == 0 && channels.length > 0 ){
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => ChannelDetail(channel:channels[postx]),
          transitionDuration: Duration(seconds: 0),
        ),
      );
      FocusScope.of(context).requestFocus(null);
    }
  }

  Future _scrollToIndexXY(int x,int y) async {
    _scrollControllers[y].scrollTo(index: x,duration: Duration(milliseconds: 500),alignment: 0.04,curve: Curves.fastOutSlowIn);
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
   try{
     if(mounted) setState(() {
       _visibile_loading = false;
       _visibile_error= false;
       _visibile_success= true;
     });

   }catch(e){
     print(e);

   }
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
  Widget getBackgroundImage() {

    if(posty < 0 && slides.length>0 )
      return  CachedNetworkImage(imageUrl:  slides[side_current].image , fit: BoxFit.cover,width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,fadeInDuration: Duration(seconds: 1));
    if(posty == 0 && channels.length>0)
      return  CachedNetworkImage(imageUrl:channels[postx].image,fit: BoxFit.cover,width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,fadeInDuration: Duration(seconds: 1));
    if(posty > 0 && genres.length>0)
      return  Container(
        color: Colors.black,
        child: CachedNetworkImage(imageUrl:genres[posty].posters![postx].cover,fit: BoxFit.cover,width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,fadeInDuration: Duration(seconds: 1)),
      );

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