import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_tv/model/poster.dart';
import 'package:flutter_app_tv/model/source.dart';

class RVWidget extends StatelessWidget {
  bool? isFocus ;
  Source? source ;
  RVWidget({this.isFocus,this.source});
  @override
  Widget build(BuildContext context) {
    print(source!.type);
    return Container(height:(isFocus!)?MediaQuery.of(context).size.width*0.15:  MediaQuery.of(context).size.width*0.12,
      width:MediaQuery.of(context).size.width*0.2,
      child: Padding(
        padding: const EdgeInsets.only(left: 5,right: 5),
        child: Center(
          child: Container(  height: MediaQuery.of(context).size.width*0.12 -5,
            width:MediaQuery.of(context).size.width*0.2,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  child: ClipRRect(child:CachedNetworkImage(
                    imageUrl: source!.type,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  ), borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.005)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.006),
                    color: Colors.blueGrey,
                    border: (isFocus!)?Border.all(color: Colors.purple,width: 2):Border.all(color: Colors.transparent,width: 0),
                    boxShadow: [
                      BoxShadow(
                          color: (isFocus!)?Colors.purple.withOpacity(0.9):Colors.white.withOpacity(0),
                          offset: Offset(0,0),
                          blurRadius: 5
                      ),
                    ],
                  ),
                  height:(isFocus!)?(MediaQuery.of(context).size.width*0.15 - 5):  MediaQuery.of(context).size.width*0.12 - 5,
                  width:MediaQuery.of(context).size.width*0.2,
                ),
                Positioned(
                  top: 10,
                  left: 0,
                  child: Container(
                    height: 15,
                    child: Row(
                      children: [
                        if(source!.title != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4,vertical: 2),
                            height: 15,
                            child:
                            Text(source!.title!,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.only(topRight: Radius.circular(7),bottomRight: Radius.circular(7)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: Offset(2,0),
                                    blurRadius: 1
                                ),
                              ],
                            ),
                          ),

                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(7),bottomRight: Radius.circular(7)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(2,0),
                            blurRadius: 1
                        ),
                      ],
                    ),
                  ),
                ),

                // if(false)  Align(alignment: Alignment.bottomCenter,child:  Padding(
                //   padding: const EdgeInsets.all(3.0),
                //   child: Container(width: 80,height: 5,child: Center(child: LinearProgressIndicator(value: 0.5,color:  Colors.purple,))),
                // ),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}