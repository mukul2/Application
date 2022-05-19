
import 'dart:convert';
import 'dart:typed_data';

import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fire;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_tv/api/api_rest.dart';
import 'package:flutter_app_tv/model/genre.dart';
import 'package:flutter_app_tv/model/poster.dart';
import 'package:flutter_app_tv/model/source.dart' as sss;
import 'package:flutter_app_tv/ui/auth/auth.dart';
import 'package:flutter_app_tv/ui/auth/profile.dart';
import 'package:flutter_app_tv/ui/channel/channels.dart';
import 'package:flutter_app_tv/ui/dialogs/genres_dialog.dart';
import 'package:flutter_app_tv/ui/home/home.dart';
import 'package:flutter_app_tv/key_code.dart';
import 'package:flutter_app_tv/ui/home/mylist.dart';
import 'package:flutter_app_tv/ui/movie/movie.dart';
import 'package:flutter_app_tv/ui/movie/movie_loading_widget.dart';
import 'package:flutter_app_tv/ui/movie/movie_widget.dart';
import 'package:flutter_app_tv/ui/search/search.dart';
import 'package:flutter_app_tv/ui/serie/series.dart';
import 'package:flutter_app_tv/ui/setting/settings.dart';

import 'package:flutter_app_tv/ui/movie/movie_short_detail_mini.dart';

import 'package:flutter_app_tv/widget/navigation_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:need_resume/need_resume.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../series_like_home/home.dart';
import '../ui/channel/channel_as_home.dart';



/// A [StatelessWidget] which demonstrates
/// how to consume and interact with a [CounterBloc].
class TVSLING extends StatefulWidget {
  @override
  _MoviesState createState() => _MoviesState();
}



class _MoviesState extends ResumableState<TVSLING> {
  int postx = 2;
  int posty = -2;



  List<String> order = [
    "created",
    "views",
    "rating",
    "imdb",
    "title",
    "year",
  ];

  List<Genre> genres = [];
  List<Poster> movies = [];

  List movieContents = [];



  int page = 0;

  int selected_sort = 1;

  int _focused_poster =0 ;
  int _focused_genre =0 ;
  int _selected_genre =0 ;
  ItemScrollController _scrollController = ItemScrollController();
  ItemScrollController _genresScrollController = ItemScrollController();

  List<ItemScrollController> _scrollControllers = [];
  List<int> _position_x_line_saver = [];
  List<int> _counts_x_line_saver = [];
  FocusNode home_focus_node = FocusNode();
  Uint8List? memoryImg ;


  bool _visibile_genres_dialog = false;
  bool _visibile_loading = false;
  bool _visibile_error = false;
  bool _visibile_success = false;
  bool? logged;
  Image image = Image.asset("assets/images/profile.jpg");

  dynamic epgOne;
  Uint8List? memoryImageOne;

  List selectedTopNews = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(home_focus_node);
     // _getGenres();

        _scrollControllers.clear();


        ItemScrollController controller =  new ItemScrollController();
        _scrollControllers.add(controller);
        _position_x_line_saver.add(0);
        _counts_x_line_saver.add(5);


     // getLogged();
    });

  download();
  }
Future download() async {



  String castLink = "http://line.liveott.ru/player_api.php?username=4fe8679c08&password=2016&action=get_live_categories";
  print(castLink);
  var responseCast = await http.get(Uri.parse(castLink), );

  List allCategory = convert.jsonDecode(responseCast.body);

  List newsGroup = [];
  List entertainmentGroup = [];
  List kidsGroup = [];
  List sportsGroup = [];


  List newsChannels = [];
  List entertainChannels = [];
  List kidsChannel = [];
  List sportsChannel = [];



  for(int i = 0 ; i < allCategory.length ; i ++){
    if(allCategory[i]["category_name"].toString().contains("NEWS") ){
      newsGroup.add(allCategory[i]);
    }
    if(allCategory[i]["category_name"].toString().contains("ENTERTAINMENT") | allCategory[i]["category_name"].toString().contains("MOVIES") | allCategory[i]["category_name"].toString().contains("SERIES")| allCategory[i]["category_name"].toString().contains("MUSIC") ){
      entertainmentGroup.add(allCategory[i]);
    }
    if(allCategory[i]["category_name"].toString().contains("KIDS")  ){
      kidsGroup.add(allCategory[i]);
    }

    if(allCategory[i]["category_name"].toString().contains("sports")  |allCategory[i]["category_name"].toString().contains("SPORTS")|allCategory[i]["category_name"].toString().contains("ESPN") |allCategory[i]["category_name"].toString().contains("PLAY")|allCategory[i]["category_name"].toString().contains("HOCKEY") |allCategory[i]["category_name"].toString().contains("LEAGUE") ){
      sportsGroup.add(allCategory[i]);
    }
  }


  print(newsGroup.length);
  print(entertainmentGroup.length);
  print(kidsGroup.length);
  print(sportsGroup.length);







  if(newsGroup.length>0){
    for(int i = 0 ; i < newsGroup.length ; i++){
      String link2 = "http://line.liveott.ru/player_api.php?username=4fe8679c08&password=2016&action=get_live_streams&category_id="+newsGroup[i]["category_id"];

      var responseCast = await http.get(Uri.parse(link2), );

      List allChannels = convert.jsonDecode(responseCast.body);

      newsChannels.addAll(allChannels);


    }
  }

  if(entertainmentGroup.length>0){
    for(int i = 0 ; i < entertainmentGroup.length ; i++){
      String link2 = "http://line.liveott.ru/player_api.php?username=4fe8679c08&password=2016&action=get_live_streams&category_id="+entertainmentGroup[i]["category_id"];

      var responseCast = await http.get(Uri.parse(link2), );

      List allChannels = convert.jsonDecode(responseCast.body);

      entertainChannels.addAll(allChannels);


    }
  }
  if(kidsGroup.length>0){
    for(int i = 0 ; i < kidsGroup.length ; i++){
      String link2 = "http://line.liveott.ru/player_api.php?username=4fe8679c08&password=2016&action=get_live_streams&category_id="+kidsGroup[i]["category_id"];

      var responseCast = await http.get(Uri.parse(link2), );

      List allChannels = convert.jsonDecode(responseCast.body);

      kidsChannel.addAll(allChannels);


    }
  }

  if(sportsGroup.length>0){
    for(int i = 0 ; i < sportsGroup.length ; i++){
      try{
        String link2 = "http://line.liveott.ru/player_api.php?username=4fe8679c08&password=2016&action=get_live_streams&category_id="+sportsGroup[i]["category_id"];

        var responseCast = await http.get(Uri.parse(link2), );

        List allChannels = convert.jsonDecode(responseCast.body);

        sportsChannel.addAll(allChannels);
      }catch(e){

      }


    }
  }
  print(newsChannels.length);
  print(entertainChannels.length);
  print(kidsChannel.length);
  print(sportsChannel.length);

  newsChannels.shuffle();
  entertainChannels.shuffle();
  kidsChannel.shuffle();
  sportsChannel.shuffle();

  int index = 0;

  int countNews = 0;

  getData() async {

    List epgs = [];
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? server =  sharedPreferences.getString("SERVER_URL");
    String? port =  sharedPreferences.getString("PORT");
    String? USER_ID =  sharedPreferences.getString("USER_ID");
    String? PASSWORD =  sharedPreferences.getString("PASSWORD");

    String castLink = "http://$server/player_api.php?username=$USER_ID&password=$PASSWORD&action=get_short_epg&stream_id="+newsChannels[index]["stream_id"].toString()+"&limit=1";

    var responseEPG = await http.get(Uri.parse(castLink), );

   try{
     dynamic dd  =  jsonDecode(responseEPG.body);
     print(responseEPG.body);
     epgs  =dd["epg_listings"];
   }catch(e){
     print(castLink);
     print(e);

   }

    if(epgs.length>0){
      String m3 = "http://$server:80/live/$USER_ID/$PASSWORD/"+newsChannels[index]["stream_id"].toString()+".m3u8";
      print(m3);
      epgOne = epgs[0];
     // String image = "https://us-central1-sflix-edc5e.cloudfunctions.net/takeScreenShot?link="+"https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";
     // String image = "https://us-central1-sflix-edc5e.cloudfunctions.net/takeScreenShot?link="+m3;
     // print(image);
      countNews++;
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




      var cha = newsChannels[index];
      cha["epgs"] = epgOne;

      selectedTopNews.add(cha);
      setState(() {

      });
      index++;
      if(index<newsChannels.length-1 && selectedTopNews.length<1){
        getData();
      }

      print(epgs);
    }else{
      index++;
      if(index<newsChannels.length-1 && selectedTopNews.length<1){
        getData();
      }
    }

  }


  if(index<newsChannels.length-1 && selectedTopNews.length<1){
    getData();
  }







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
      String? img  = await prefs.getString("IMAGE_USER");
      image = Image.network(img!);
    }else{
      logged = false;
      image = Image.asset("assets/images/profile.jpg");
    }
    setState(() {
      print(logged);
    });
  }
  void _getGenres()  async{
    genres.clear();
    //Genre genre = Genre(id: 0,title:  "Please wait");

    // genres.add(genre);
    //var response =await apiRest.getGenres();

    fire.FirebaseFirestore firestore =   fire.FirebaseFirestore.instance;

    fire.QuerySnapshot category = await  firestore.collection("movies").get();
    // Genre genre0 = Genre(id: 0,title:  category.docs[0].get("name"));

    // genres.add(genre0);
    for(int i = 0 ; i < category.docs.length; i++){

      Genre genre = Genre(id:  i, title:  category.docs[i].get("name"));
      genres.add(genre);


      try{
        String d = category.docs[i].get("list");

        List listData = convert.jsonDecode(d);


        movieContents.add(listData);
      }catch(e){
        movieContents.add([]);
      }

    }

    _getList();




    // if(response != null){
    //   if (response.statusCode == 200) {
    //     var jsonData =  convert.jsonDecode(response.body);
    //
    //
    //     Genre genre = Genre(id: 1, title: "Sunny Leone Videos");
    //     Genre genre2 = Genre(id: 1, title: "Mia Khalifa Videos");
    //   //  genres.add(genre);
    //   //  genres.add(genre2);
    //
    //   if(false) for(Map<String,dynamic> i in jsonData){
    //      // Genre genre = Genre.fromJson(i);
    //       Genre genre = Genre(id: 1, title: "Sunny Leone Videos");
    //       Genre genre2 = Genre(id: 1, title: "Mia Khalifa Videos");
    //       genres.add(genre);
    //     }
    //   }
    // }
  }
  void _getList()  async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? server =  sharedPreferences.getString("SERVER_URL");
    String? port =  sharedPreferences.getString("PORT");
    String? USER_ID =  sharedPreferences.getString("USER_ID");
    String? PASSWORD =  sharedPreferences.getString("PASSWORD");
    movies.clear();
    page =0;
    _showLoading();
    // var response =await apiRest.getMoviesByFiltres(genres[_selected_genre].id, order[selected_sort -1],page);


    // List ddd =convert.jsonDecode(response.body);
    // print("trailer  ");
    // print(ddd[0]["trailer"]);



    for(int i = 0 ; i < movieContents[genres[_selected_genre].id].length ; i++){
      // String SERVER = "http://connect.proxytx.cloud";
      // String PORT = "80";
      // String EMAIL = "4fe8679c08";
      // String PASSWORD = "2016";

      String link ="http://$server+:$port"+"/"+movieContents[_selected_genre][i]["stream_type"]+"/"+USER_ID!+"/"+PASSWORD.toString() +"/"+movieContents[_selected_genre][i]["stream_id"].toString()+"."+movieContents[_selected_genre][i]["container_extension"];
      print( movieContents[_selected_genre]);
      Poster poster1 = Poster(id:movieContents[_selected_genre][i]["stream_id"],
          title: movieContents[_selected_genre][i]["name"],
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
          image: movieContents[_selected_genre][i]["stream_icon"]??"https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png",
          cover: movieContents[_selected_genre][i]["stream_icon"]??"https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png",
          trailer: null,
          genres: [Genre(id: genres[_selected_genre].id, title: genres[_selected_genre].title)],
          sources:[sss.Source(size: "",id: 1, type: movieContents[_selected_genre][i]["container_extension"], title:movieContents[_selected_genre][i]["container_extension"], quality: "FHD",  kind: "both", premium: "1", external: false, url:link)] );

      movies.add(poster1);
    }





    _showData();

    if(false){

      //
      // if(response == null){
      //   _showTryAgain();
      // }else{
      //   if (response.statusCode == 200) {
      //     var jsonData =  convert.jsonDecode(response.body);
      //     for(Map<String,dynamic> i in jsonData){
      //       Poster poster = Poster.fromJson(i);
      //       movies.add(poster);
      //     }
      //     //print(movies.first.sources.first.url);
      //     //print(movies.first.genres.first.);
      //     _showData();
      //     page++;
      //   } else {
      //     _showTryAgain();
      //   }
      // }
    }

    _scrollControllers.clear();
    for(int jndex = 0;jndex < ((movies.length/8).ceil());jndex++){
      int items_line_count = (movies.length -  ((jndex+1) * 8) > 0)? 8:  (movies.length -  (jndex * 8)).abs();

      ItemScrollController controller =  new ItemScrollController();
      _scrollControllers.add(controller);
      _position_x_line_saver.add(0);
      _counts_x_line_saver.add(items_line_count);
    }
  }

  void _loadMore()  async{

    var response =await apiRest.getMoviesByFiltres(genres[_selected_genre].id, order[selected_sort -1],page);
    if(response != null){
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);
        for(Map<String,dynamic> i in jsonData){
          Poster poster = Poster.fromJson(i);
          movies.add(poster);
        }
        page++;
      }
    }
    _scrollControllers.clear();
    for(int jndex = 0;jndex < ((movies.length/8).ceil());jndex++){
      int items_line_count = (movies.length -  ((jndex+1) * 8) > 0)? 8:  (movies.length -  (jndex * 8)).abs();

      ItemScrollController controller =  new ItemScrollController();
      _scrollControllers.add(controller);
      _position_x_line_saver.add(0);
      _counts_x_line_saver.add(items_line_count);
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{

        if(_visibile_genres_dialog){
          setState(() {
            _visibile_genres_dialog = false;
          });

          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body:RawKeyboardListener(
          focusNode: home_focus_node,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
              RawKeyDownEvent rawKeyDownEvent = event;
              RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data as RawKeyEventDataAndroid;
              print(rawKeyEventDataAndroid.toString());

              print(postx.toString()+" , "+posty.toString());

              switch (rawKeyEventDataAndroid.keyCode) {

                case KEY_CENTER:
                  _selectFilter();

                  _goToSearch();
                  _goToHome();
                  _goToSeries();
                  _goToChannels();
                  _goToMyList();
                  _goToSettings();
                  _goToProfile();

                  _goToMovieDetail();
                  _tryAgain();
                  if(_visibile_genres_dialog == true) {
                    _selectedGenre();
                  }else{
                    _showGenresDialog();
                  }
                  break;
                case KEY_UP:


                  if(posty ==  -2){
                    print("playing sound ");
                  }else if(posty == -1){

                    posty--;
                    postx = 2;

                  }
                  break;
                case KEY_DOWN:

                  if(posty==-2){
                    posty++;
                    postx = 0;
                    _scrollToIndexXY(postx,0);
                   // _scrollControllers[0].scrollTo(index: postx,duration: Duration(milliseconds: 500),alignment: 0.04,curve: Curves.fastOutSlowIn);



                  }
                  if(posty==-1){



                  }

                  else{
                    print("stop");
                  }


                  break;
                case KEY_LEFT:



                  switch(posty){

                    case -2:
                      if(postx == 0)
                        print("playing sound ");
                      else
                        postx--;

                      break;
                    case -1:
                      if(postx == 0)
                        print("playing sound ");
                      else
                        postx--;
                      _scrollToIndexXY(postx,0);
                       //_scrollControllers[0].scrollTo(index: postx,duration: Duration(milliseconds: 500),alignment: 0.04,curve: Curves.fastOutSlowIn);

                      break;




                  }
                  break;
                case KEY_RIGHT:

                  switch(posty){


                    case -2:
                      if(postx == 7)
                        print("playing sound ");
                      else
                        postx++;
                      break;

                      case -1:
                      if(postx == selectedTopNews.length-1)
                        print("playing sound ");
                      else
                        postx++;
                        _scrollToIndexXY(postx,0);
                       // _scrollControllers[0].scrollTo(index: postx,duration: Duration(milliseconds: 500),alignment: 0.04,curve: Curves.fastOutSlowIn);

                      break;








                  }


                  break;
                default:
                  break;
              }

              setState(() {

              });
              if(_visibile_genres_dialog && _genresScrollController!= null){
                _genresScrollController.scrollTo(index: _focused_genre,alignment: 0.43,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
              }
            }
          },


          child: true? Stack(
            children: [
              AnimatedPositioned(
                bottom: 0,
                left: 0,
                right: 0,
                duration: Duration(milliseconds: 200),
                height: (posty < 0)?(MediaQuery.of(context).size.height/1)  -80:(MediaQuery.of(context).size.height/1)+250,
                child: Container(
                  height: (posty < 0)?(MediaQuery.of(context).size.height/1) -80:(MediaQuery.of(context).size.height/1)+250,
                  child: ScrollConfiguration(
                      behavior: MyBehavior(),   // From this behaviour you can change the behaviour
                      child: selectedTopNews.length>0? ScrollablePositionedList.builder(
                          itemCount: 1,
                          scrollDirection: Axis.vertical,
                          itemScrollController: _scrollController,
                          itemBuilder: (context, jndex) {

                            return  Container(height:MediaQuery.of(context).size.longestSide*0.11,
                              child: ScrollConfiguration(
                                  behavior: MyBehavior(),   // From this behaviour you can change the behaviour
                                  child: ScrollablePositionedList.builder(
                                      itemCount: selectedTopNews.length,
                                      scrollDirection: Axis.horizontal,
                                      itemScrollController: _scrollControllers.first,
                                      itemBuilder: (context, jndex2) {



                                        return Container(height:(MediaQuery.of(context).size.longestSide*0.23) ,width: (MediaQuery.of(context).size.longestSide*0.3), margin: EdgeInsets.all(MediaQuery.of(context).size.longestSide*0.005),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.0015),color: (jndex2==postx && posty == -1)?Colors.red:Colors.white,

                                        ),child: Center(
                                          child: Container(color: Colors.black,  margin: EdgeInsets.all(MediaQuery.of(context).size.longestSide*0.001),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Stack(
                                                children: [
                                                 Align(alignment: Alignment.bottomLeft,child:  Text(selectedTopNews[jndex2]["name"],style: TextStyle(color: Colors.white,fontSize:MediaQuery.of(context).size.longestSide*0.012 ),),),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        );




                                      })),
                            );


                          }):CupertinoActivityIndicator(color: Colors.red,)),
                ),
              ),
              NavigationWidget(postx:postx,posty:posty,selectedItem : 2,image : image, logged : logged),
            ],
          ): Stack(
            children: [
              if(!movies.isEmpty)
                Positioned(
                    right: 0,
                    top: 0,
                    left: MediaQuery.of(context).size.width/4,
                    bottom: MediaQuery.of(context).size.height*0.05,
                    child:CachedNetworkImage(imageUrl:movies[_focused_poster].cover,fit: BoxFit.cover,width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,fadeInDuration: Duration(seconds: 1))
                  //child: FadeInImage(placeholder: MemoryImage(kTransparentImage),image:(movies.length > 0)? CachedNetworkImageProvider(movies[_focused_poster].cover):CachedNetworkImageProvider(""),fit: BoxFit.cover)
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
                        )
                    )
                ),
              ),
              NavigationWidget(postx:postx,posty:posty,selectedItem : 2,image : image, logged : logged),
              if(_visibile_loading )
                MovieLoadingWidget(),
              if(_visibile_error )
                _tryAgainWidget(),
              if(movies.length>0 && !_visibile_loading && !_visibile_error)
                AnimatedPositioned(
                    top: (posty < 0)? 180 : 150,
                    left: 0,
                    right: 0,
                    duration: Duration(milliseconds: 200),
                    child: MovieShortDetailMiniWidget(movie :  movies[_focused_poster])
                ),
              Positioned(
                top:  10,
                left: 45,
                right: 45,
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

                AnimatedPositioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  duration: Duration(milliseconds: 200),
                  height: (posty < 0)?(MediaQuery.of(context).size.height*0.3) + 20:(MediaQuery.of(context).size.height*0.3)+50,
                  child: Column(
                    children: [




                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 45),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              margin: EdgeInsets.symmetric(vertical: 7),
                              height: 50,
                              child:
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    posty = -1;
                                    postx =0;
                                    Future.delayed(Duration(milliseconds: 50),(){
                                      _showGenresDialog();
                                    });
                                  });
                                },
                                child: Row(
                                  children: [
                                    //genres[_selected_genre].title
                                    Text(genres[_selected_genre].title,
                                      style: TextStyle(
                                          color: (posty == -1 && postx == 0)? Colors.black:Colors.white70,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: (posty == -1 && postx == 0)? Colors.black:Colors.white70,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: (posty == -1 && postx == 0)? Colors.white:Colors.transparent,
                                  border: Border.all(color: Colors.white70,width: 2),
                                  borderRadius: BorderRadius.circular(5)
                              ),
                            ),
                            if(false)    AnimatedOpacity(
                              opacity: (posty == -1 && postx >0)? 1 :0.8,
                              duration: Duration(milliseconds: 250),
                              child: Container(
                                height: 50,
                                margin: EdgeInsets.symmetric(vertical: 7),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white,width: 2),
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          posty = -1;
                                          postx =1;
                                          Future.delayed(Duration(milliseconds: 50),(){
                                            _selectFilter();
                                          });
                                        });

                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        height: 50,
                                        color: ((posty == -1 && postx == 1) || selected_sort == 1)? Colors.white:Colors.transparent,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              color: ((posty == -1 && postx == 1) || selected_sort == 1)? Colors.black:Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Newest",
                                              style: TextStyle(
                                                  color: ((posty == -1 && postx == 1) || selected_sort == 1)? Colors.black:Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          posty = -1;
                                          postx =2;
                                          Future.delayed(Duration(milliseconds: 50),(){
                                            _selectFilter();
                                          });
                                        });

                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        height: 50,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.remove_red_eye,
                                              color: ((posty == -1 && postx == 2) || selected_sort == 2)? Colors.black:Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Views",
                                              style: TextStyle(
                                                  color: ((posty == -1 && postx == 2) || selected_sort == 2)? Colors.black:Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700
                                              ),
                                            ),
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(left: BorderSide(color: Colors.white,width: 1)),
                                          color: ((posty == -1 && postx == 2) || selected_sort == 2)? Colors.white:Colors.transparent,

                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          posty = -1;
                                          postx =3;
                                          Future.delayed(Duration(milliseconds: 50),(){
                                            _selectFilter();
                                          });
                                        });

                                      },
                                      child: Container(
                                        height: 50,
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.star_half,
                                              color: ((posty == -1 && postx == 3) || selected_sort == 3)? Colors.black:Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Rating",
                                              style: TextStyle(
                                                  color:((posty == -1 && postx == 3) || selected_sort == 3)? Colors.black:Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700
                                              ),
                                            ),

                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(left: BorderSide(color: Colors.white,width: 1)),
                                          color: ((posty == -1 && postx == 3) || selected_sort == 3)? Colors.white:Colors.transparent,

                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          posty = -1;
                                          postx =4;
                                          Future.delayed(Duration(milliseconds: 50),(){
                                            _selectFilter();
                                          });
                                        });

                                      },
                                      child: Container(
                                        height: 50,
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.imdb,
                                              color: ((posty == -1 && postx == 4) || selected_sort == 4)? Colors.black:Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Imdb Rating",
                                              style: TextStyle(
                                                  color: ((posty == -1 && postx == 4) || selected_sort == 4)? Colors.black:Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700
                                              ),
                                            ),

                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(left: BorderSide(color: Colors.white,width: 1)),
                                          color: ((posty == -1 && postx == 4) || selected_sort == 4)? Colors.white:Colors.transparent,

                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          posty = -1;
                                          postx =5;
                                          Future.delayed(Duration(milliseconds: 50),(){
                                            _selectFilter();
                                          });
                                        });

                                      },
                                      child: Container(
                                        height: 50,
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.text_fields,
                                              color: ((posty == -1 && postx == 5) || selected_sort == 5)? Colors.black:Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Title",
                                              style: TextStyle(
                                                  color: ((posty == -1 && postx == 5) || selected_sort == 5)? Colors.black:Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700
                                              ),
                                            ),

                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(left: BorderSide(color: Colors.white,width: 1)),
                                          color: ((posty == -1 && postx == 5) || selected_sort == 5)? Colors.white:Colors.transparent,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          posty = -1;
                                          postx =6;
                                          Future.delayed(Duration(milliseconds: 50),(){
                                            _selectFilter();
                                          });
                                        });

                                      },
                                      child: Container(
                                        height: 50,
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.date_range,
                                              color: ((posty == -1 && postx == 6) || selected_sort == 6)? Colors.black:Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Year",
                                              style: TextStyle(
                                                  color: ((posty == -1 && postx == 6) || selected_sort == 6)? Colors.black:Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700
                                              ),
                                            ),
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(left: BorderSide(color: Colors.white,width: 1)),
                                          color: ((posty == -1 && postx == 6) || selected_sort == 6)? Colors.white:Colors.transparent,

                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: ScrollConfiguration(
                            behavior: MyBehavior(),   // From this behaviour you can change the behaviour
                            child: ScrollablePositionedList.builder(
                              itemCount: (movies.length / 8).ceil(),
                              scrollDirection: Axis.vertical,
                              itemScrollController: _scrollController,
                              itemBuilder: (context, jndex) {
                                int items_line_count = (movies.length -  ((jndex+1) * 8) > 0)? 8:  (movies.length -  (jndex * 8)).abs();
                                return _moviesLineGridWidget(jndex,items_line_count);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              GenresDialog(genresScrollController: _genresScrollController,visibile: _visibile_genres_dialog,genresList: genres,focused_genre: _focused_genre,selected_genre:_selected_genre,select: selectGenre,close: closeGenreDialog),
            ],
          ),
        ),
      ),
    );
  }

  Future _scrollToIndexXY(int x,int y) async {

    try{
      _scrollControllers[y].scrollTo(index: x,duration: Duration(milliseconds: 500),alignment: 0.04,curve: Curves.fastOutSlowIn);
    }catch(ex){

    }
    _scrollController.scrollTo(index: y,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
  }

  void _selectFilter() {
    if(posty == -1 && postx > 0 && postx <7){
      setState(() {
        selected_sort = postx;
      });
      _getList();
    }
  }
  void  _goToHome(){
    if(posty == -2 && postx == 1){
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Home(),
          transitionDuration: Duration(seconds: 0),
        ),
      );
      FocusScope.of(context).requestFocus(null);
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
  void _goToMovieDetail() {
    if(posty >= 0 ){
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Movie(movie:movies[_focused_poster]),
          transitionDuration: Duration(seconds: 0),
        ),
      );
      FocusScope.of(context).requestFocus(null);
    }
  }
  void _showGenresDialog() {
    if (posty == -1 && postx == 0) {
      setState(() {
        _visibile_genres_dialog = true;
      });
      Future.delayed(Duration(milliseconds: 100),(){
        _genresScrollController.scrollTo(index: _selected_genre,alignment: 0.43,duration: Duration(milliseconds: 500),curve: Curves.easeInOutQuart);
      });
    }

  }

  void _selectedGenre() {
    _selected_genre = _focused_genre;
    setState(() {
      _visibile_genres_dialog = false;
    });
    _getList();
  }

  Widget _moviesLineGridWidget( jndex, int itemCount) {
    return Container(
      height: MediaQuery.of(context).size.width*0.18,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            height: MediaQuery.of(context).size.width*0.18,
            width: double.infinity,
            child: ScrollablePositionedList.builder(
              itemCount: itemCount,
              itemScrollController: _scrollControllers[jndex],
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: (){
                      setState(() {
                        posty = jndex;
                        postx =index;
                        Future.delayed(Duration(milliseconds: 250),(){
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration(seconds: 0),
                              pageBuilder: (context, animation1, animation2) => Movie(movie: movies[(jndex*8)+index]),
                            ),
                          );
                        });
                      });
                    },
                    child: MovieWidget(isFocus:  ((posty == jndex && postx == index)),movie: movies[(jndex*8)+index])
                );
              },
            ),
          )
        ],
      ),
    );
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
  void closeGenreDialog(){
    setState(() {
      _visibile_genres_dialog = false;
    });
  }
  void selectGenre(int selected_genre_pick){
    setState(() {
      _focused_genre =  selected_genre_pick;
      Future.delayed(Duration(milliseconds: 200),(){
        _selectedGenre();
      });
    });
  }
}




class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}