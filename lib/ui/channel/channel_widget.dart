
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_tv/model/channel.dart';

class ChannelWidget extends StatelessWidget {
  bool isFocus ;
  Channel channel ;
  ChannelWidget({required this.isFocus,required this.channel});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.longestSide*0.002,vertical: MediaQuery.of(context).size.longestSide*0.004),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        child: ClipRRect(
            child: CachedNetworkImage(
              imageUrl: channel.image,
              errorWidget: (context, url, error) => Icon(Icons.error),
             // fit: !isFocus? BoxFit.cover:BoxFit.none,
            ),
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.004)
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.004),
          color: Colors.white,
          border: (isFocus)?Border.all(color: Colors.purple,width: MediaQuery.of(context).size.longestSide*0.001):Border.all(color: Colors.transparent,width: 0),
          boxShadow: [
            BoxShadow(
                color: (isFocus)?Colors.purple:Colors.white.withOpacity(0),
                offset: Offset(0,0),
                blurRadius: MediaQuery.of(context).size.longestSide*0.002
            ),
          ],
        ),

        width: MediaQuery.of(context).size.longestSide*0.09,
      ),
    );
  }
}