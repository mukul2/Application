import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_tv/model/source.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../model/subtitle.dart';

class SubtitleTileSourceWidget extends StatelessWidget {

  bool isFocused;

  Subtitle subtitleSource;

  SubtitleTileSourceWidget({required this.isFocused, required this.subtitleSource});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  height:  MediaQuery.of(context).size.longestSide*0.02,
                  width:  MediaQuery.of(context).size.longestSide*0.02,
                  color: (isFocused)? Colors.black.withOpacity(0.9) : Colors.white10,
                  margin: EdgeInsets.all(2),
                  child: getIcon(context),
                ),
                Expanded(
                  child: Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                              margin: EdgeInsets.only(left:10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(subtitleSource.language,
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.longestSide*0.012,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),

                                ],
                              ),
                          ),
                        ),

                      ],
                    ),
                    height: 50,
                    color: (isFocused)? Colors.black.withOpacity(0.9) : Colors.white10,
                    margin: EdgeInsets.all(2),
                  ),
                ),
                Container(
                  height:  MediaQuery.of(context).size.longestSide*0.02,
                  width:  MediaQuery.of(context).size.longestSide*0.02,
                  color: (isFocused)? Colors.black.withOpacity(0.9) : Colors.white10,
                  margin: EdgeInsets.all(2),
                  child: Icon(Icons.play_arrow,
                      size:   MediaQuery.of(context).size.longestSide*0.01,
                      color: Colors.white,
                  ),
                ),
              ],
            ),

          ],
        ),
    );
  }

  Widget getIcon(BuildContext context) {
    return  Icon(Icons.closed_caption,
      size: MediaQuery.of(context).size.longestSide*0.02,
      color: Colors.white,
    );

  }
}
