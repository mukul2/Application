import 'package:flutter_app_tv/model/channel.dart';
import 'package:flutter_app_tv/model/poster.dart';

class GenreAsChannel{
  int id;
  String title;
  List<Channel>? posters;

  GenreAsChannel({required this.id, required this.title,this.posters});

  factory GenreAsChannel.fromJson(Map<String, dynamic> parsedJson){


    List<Channel> posters =  [];
    if(parsedJson['posters'] != null)
      for(Map<String,dynamic> i in parsedJson['posters']){
        Channel poster = Channel.fromJson(i);
        posters.add(poster);
      }

    return GenreAsChannel(
        id: parsedJson['id'],
        title : parsedJson['title'],
        posters : posters
    );
  }
}