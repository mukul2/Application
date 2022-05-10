class Subtitle{
  int id;
  String type;
  String language;
  String url;
  String image;
  String? file_name;
  int? file_id;


  Subtitle({required this.id,required this.type,required  this.language,required this.url,required this.image,this.file_id,this.file_name});



  factory Subtitle.fromJson(Map<String, dynamic> parsedJson){
    print(parsedJson);
    return Subtitle(
        id: parsedJson['id'],
        type : parsedJson['type'],
        language : parsedJson['language'],
        url : parsedJson['url'],
        image : parsedJson['image']
    );
  }

}

