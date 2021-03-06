import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../key_code.dart';





class MacAddress extends StatefulWidget {
  const MacAddress({Key? key}) : super(key: key);

  @override
  State<MacAddress> createState() => _HomeState();
}

class _HomeState extends State<MacAddress> {
  AndroidDeviceInfo? androidInfo;
  FocusNode main_focus_node = FocusNode();
  bool isTV = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initMacAddress();

  }
  String getDeviceType() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    return data.size.shortestSide < 600 ? 'Phone' :'Tablet';
  }
  String _deviceMAC = 'Please wait';
  // Platform messages are async in nature
  // that's why we made a async function.
  Future<void> initMacAddress() async {
    //DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
   // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
     //isTV = androidInfo.systemFeatures.contains('android.software.leanback_only');
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if(Platform.isAndroid){
         androidInfo = await deviceInfo.androidInfo;
        _deviceMAC=  androidInfo!.androidId!;
         isTV = androidInfo!.systemFeatures.contains('android.software.leanback_only');
        print(androidInfo!.toMap().toString());
        print(Platform.environment.toString());
        print(Platform.operatingSystem);
        print(Platform.operatingSystemVersion);
      }
      if(Platform.isIOS){
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceMAC=  iosInfo.identifierForVendor!;
      }
      if(kIsWeb){
        WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
        _deviceMAC=  "--";
      }

    } on PlatformException {
      _deviceMAC = 'Error getting the MAC address.';
    }


    // setState(() {
    //
    // });

    print("data return");

    return;
  }



  @override
  Widget build(BuildContext context) {

    // return Scaffold(backgroundColor: Colors.white,body: SingleChildScrollView( child: Padding(
    //   padding: const EdgeInsets.all(8.0),
    //   child: Text(_deviceMAC),
    // )),);

    return  FutureBuilder<dynamic>(
        future: initMacAddress(), // async work
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.connectionState == ConnectionState.done){
            return RawKeyboardListener(
              focusNode: main_focus_node,
              onKey: (RawKeyEvent event) {
                if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
                  RawKeyDownEvent rawKeyDownEvent = event;
                  RawKeyEventDataAndroid rawKeyEventDataAndroid =rawKeyDownEvent.data as RawKeyEventDataAndroid;
                  print("Focus Node 0 ${rawKeyEventDataAndroid.keyCode}");
                  switch (rawKeyEventDataAndroid.keyCode) {
                    case KEY_CENTER:
                      Navigator.pop(context);
                      break;
                    case KEY_UP:

                      break;

                    case KEY_DOWN:

                      break;
                    case KEY_LEFT:


                      print("play sound");

                      break;
                    case KEY_RIGHT:

                      print("play sound");
                      break;
                    default:
                      break;
                  }
                  setState(() {

                  });
                }
              },
              child: Scaffold(appBar: AppBar(leading: Icon(Icons.settings),title: Text("Device Info"),centerTitle: true,),backgroundColor: Colors.black,body: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Row(
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end,children: [
                        Text(
                          "Device ID :   ",
                          style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.015, fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                        Text(
                          "Model :   ",
                          style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.015, fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                        Text(
                          "Device Type :   ",
                          style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.015, fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                        Text(
                          "Device Brand :   ",
                          style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.015, fontWeight: FontWeight.bold,color: Colors.white),
                        )

                      ],)),


                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                        Text(_deviceMAC,
                          style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.015, fontWeight: FontWeight.bold,color: Colors.redAccent),
                        ),
                        Text((androidInfo!=null && androidInfo!.model!=null) ? androidInfo!.model!:"--",
                          style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.015, fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                        Text(Platform.operatingSystem.toUpperCase()+" - "+(isTV?"TV":getDeviceType()),
                          style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.015, fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                        Text(androidInfo!.brand!.toUpperCase(),
                          style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.015, fontWeight: FontWeight.bold,color: Colors.white),
                        )

                      ],)),

                    ],
                  ),

                  if(false) Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Device ID:",
                        style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.020, fontWeight: FontWeight.bold,color: Colors.white),
                      ),Text(
                        "   ",
                        style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.03, fontWeight: FontWeight.bold,color: Colors.redAccent),
                      ),
                      Text(
                        _deviceMAC,
                        style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.020, fontWeight: FontWeight.bold,color: Colors.redAccent),
                      ),
                    ],
                  ),
                  if(false)     Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Model:",
                        style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.020, fontWeight: FontWeight.bold,color: Colors.white),
                      ),Text(
                        "   ",
                        style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.03, fontWeight: FontWeight.bold,color: Colors.redAccent),
                      ),
                      Text(
                        androidInfo!.model!,
                        style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.020, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                    ],
                  ),
                  if(false)     Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Device Type:",
                        style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.020, fontWeight: FontWeight.bold,color: Colors.white),
                      ),Text(
                        "   ",
                        style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.03, fontWeight: FontWeight.bold,color: Colors.redAccent),
                      ),
                      Text(
                        androidInfo!.device!,
                        style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.020, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                    ],
                  ),
                  if(false)    Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Device Brand:",
                        style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.020, fontWeight: FontWeight.bold,color: Colors.white),
                      ),Text(
                        "   ",
                        style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.03, fontWeight: FontWeight.bold,color: Colors.redAccent),
                      ),
                      Text(
                        androidInfo!.brand!,
                        style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.020, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                    ],
                  ),
                  Padding(
                    padding:  EdgeInsets.only(top: MediaQuery.of(context).size.longestSide*0.02,bottom: MediaQuery.of(context).size.longestSide*0.001),
                    child: Center(
                      child: Text("Your unique device ID "+_deviceMAC,textAlign: TextAlign.center,
                        style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.015, fontWeight: FontWeight.normal,color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(top: MediaQuery.of(context).size.longestSide*0.000),
                    child: Center(
                      child: Text(
                        "(Provide this device id to your IPTV provider to compleate signup process with Sflix)",textAlign: TextAlign.center,
                        style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.015, fontWeight: FontWeight.normal,color: Colors.white),
                      ),
                    ),
                  ),

                  InkWell(onTap: (){
                    Navigator.pop(context);
                  },
                    child: Container(margin: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.02 ),width:MediaQuery.of(context).size.width*0.25 ,decoration: BoxDecoration(color: Colors.redAccent,borderRadius: BorderRadius.circular(MediaQuery.of(context).size.longestSide*0.003) ),child: Center(child: Padding(
                      padding:  EdgeInsets.only(left: MediaQuery.of(context).size.longestSide*0.01,right: MediaQuery.of(context).size.longestSide*0.01,bottom:  MediaQuery.of(context).size.longestSide*0.007,top:  MediaQuery.of(context).size.longestSide*0.007 ),
                      child: Text("Return",style:  TextStyle(fontSize: MediaQuery.of(context).size.longestSide*0.015, fontWeight: FontWeight.normal,color: Colors.white)),
                    ),),),
                  ),
                ],
              ),),
            );
          }else{
            return Scaffold(body: Center(child: CircularProgressIndicator(),),);

          }




    });





  }
}