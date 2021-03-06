import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_tv/api/api_rest.dart';
import 'package:flutter_app_tv/key_code.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert' as convert;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../SettingFolder/LoginSettings.dart';
import '../home/home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FocusNode main_focus_node = FocusNode();
  FocusNode username_focus_node= FocusNode();
  FocusNode password_focus_node= FocusNode();
  TextEditingController usernameController = new TextEditingController(text: "4fe8679c08");
  TextEditingController passwordController = new TextEditingController(text: "2016");
  bool emailvalide = true;
  bool passwordvalide = true;
  bool loading = false;
  String _message_error = "";
  bool _visibile_error =false;
  int pos_y = 0;
  int pos_x = 0;

  @override
  void initState() {
    // TODO: implement initState
  super.initState();
  Future.delayed(Duration.zero, () {
  FocusScope.of(context).requestFocus(username_focus_node);
  });
}
  _login(String email,String password) async{

    // Navigator.pushReplacement(
    //   context,
    //   PageRouteBuilder(
    //     pageBuilder: (context, animation1, animation2) => Home(),
    //     transitionDuration: Duration(seconds: 0),
    //   ),
    // );


    setState(() {
      loading = true;
      _visibile_error = false;

    });
    bool response;

    response = await apiRest.loginUser( email: email,password: password);

    if(response){
      Fluttertoast.showToast(
        msg: "You have logged in successfully !",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      _visibile_error = false;

      Future.delayed(Duration(milliseconds: 200)).then((value) {

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => Home(),
            transitionDuration: Duration(seconds: 0),
          ),
        );

      });
    }else{
      Fluttertoast.showToast(
        msg: "Login Failed",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
    setState(() {
      loading = false;
    });





  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:  RawKeyboardListener(
        focusNode: main_focus_node,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
            RawKeyDownEvent rawKeyDownEvent = event;
            RawKeyEventDataAndroid rawKeyEventDataAndroid =rawKeyDownEvent.data as RawKeyEventDataAndroid;
            print("Focus Node 0 ${rawKeyEventDataAndroid.keyCode}");
            switch (rawKeyEventDataAndroid.keyCode) {
              case KEY_CENTER:
                if(!loading)
                  _goToValidate();

                if(pos_y == 2 && pos_x == 0){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MacAddress()),
                  );
                }
                break;
              case KEY_UP:
                if(pos_y  ==  0){
                  print("play sound");
                }else{
                  pos_y --;
                }
                if(pos_y == 0){
                  FocusScope.of(context).requestFocus(null);
                  FocusScope.of(context).requestFocus(username_focus_node);
                }
                break;

              case KEY_DOWN:
                if(pos_y  ==  2){
                  print("play sound");
                }else{
                  pos_y ++;
                }
                break;
              case KEY_LEFT:

                if(pos_y == 2 && pos_x == 1){
                  pos_x --;
                }
                print("play sound");

                break;
              case KEY_RIGHT:
                if(pos_y == 2 && pos_x == 0){
                  pos_x ++;
                }
                print("play sound");
                break;
              default:
                break;
            }
            setState(() {

            });
          }
        },
        child: Stack(
          children: [
            FadeInImage(placeholder: MemoryImage(kTransparentImage),image:AssetImage("assets/images/background.jpeg"),fit: BoxFit.cover),
            ClipRRect( // Clip it cleanly.
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  alignment: Alignment.center,
                ),
              ),
            ),
           
            Positioned(
              right: 0,
              bottom: -5,
              top: -5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  boxShadow: [
                    BoxShadow(
                        color:Colors.black,
                        offset: Offset(0,0),
                        blurRadius: 5
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width/2.5,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(MediaQuery.of(context).size.shortestSide*0.05),
                  color: Colors.black54,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(child: Image.asset( "assets/images/logo.png",height: 40,color: Colors.white)),
                      SizedBox(height: MediaQuery.of(context).size.height*0.005),
                      Text(
                        "Sign in to your account !",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.shortestSide*0.05,
                            fontWeight: FontWeight.w900
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.shortestSide*0.05),
                      TextFormField(
                        controller: usernameController,
                        focusNode: username_focus_node,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          focusColor: Colors.white,
                          labelText: 'Username',
                          labelStyle: TextStyle(
                              color: (emailvalide)?Colors.white:Colors.red
                          ),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0),borderSide: BorderSide(color: (emailvalide)?Colors.white:Colors.red,width: 1)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0),borderSide: BorderSide(color: (emailvalide)?Colors.white54:Colors.red,width: 1)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0),borderSide: BorderSide(color: (emailvalide)?Colors.white:Colors.red,width: 1)),
                          contentPadding: new EdgeInsets.symmetric(vertical: 4.0, horizontal: 15.0),
                          suffixIcon: Icon(
                            Icons.email,
                            size: MediaQuery.of(context).size.shortestSide*0.05,
                            color: (emailvalide)?Colors.white70:Colors.red,
                          ),
                        ),
                        style: TextStyle(
                          color: (emailvalide)?Colors.white:Colors.red,
                        ),
                        maxLines: 1,
                        minLines: 1,
                        scrollPadding: EdgeInsets.zero,
                        cursorColor: Colors.white,
                        onFieldSubmitted: (v){
                          if(checkEmail(usernameController.text)){
                            emailvalide = true;
                          }else{
                            emailvalide = false;
                          }

                          setState(() {

                          });
                          FocusScope.of(context).requestFocus(password_focus_node);
                        }
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        focusNode: password_focus_node,
                        obscureText:true,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          focusColor: Colors.white,
                          labelText: 'Password',
                          labelStyle: TextStyle(
                              color: (passwordvalide)?Colors.white:Colors.red
                          ),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0),borderSide: BorderSide(color: (passwordvalide)?Colors.white:Colors.red,width: 1)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0),borderSide: BorderSide(color: (passwordvalide)?Colors.white54:Colors.red,width: 1)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0),borderSide: BorderSide(color: (passwordvalide)?Colors.white:Colors.red,width: 1)),
                          contentPadding: new EdgeInsets.symmetric(vertical: 4.0, horizontal: 15.0),
                          suffixIcon: Icon(
                            Icons.vpn_key_rounded,
                            size: MediaQuery.of(context).size.shortestSide*0.05,
                            color: (passwordvalide)?Colors.white70:Colors.red,
                          ),
                        ),
                        style: TextStyle(
                          color: (passwordvalide)?Colors.white70:Colors.red,
                        ),
                        maxLines: 1,
                        minLines: 1,
                        scrollPadding: EdgeInsets.zero,
                        cursorColor: Colors.white,

                        onFieldSubmitted: (v){

                          if(passwordController.text.length>=6){
                            passwordvalide = true;
                          }else{
                            passwordvalide = false;

                          }
                          setState(() {

                          });
                          FocusScope.of(context).requestFocus(main_focus_node);
                          pos_y= 1;
                          setState(() {

                          });
                        },
                      ),
                      if(_visibile_error)
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red,width: 0.3),
                            borderRadius: BorderRadius.circular(5),
                            color:  Colors.redAccent,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5.0),
                                height: 28,
                                width: 28,
                                child: Icon(
                                  Icons.warning,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      _message_error ,
                                      style: TextStyle(
                                        color:Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      )
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      GestureDetector(
                        onTap: (){
                          pos_y = 1;
                          setState(() {

                          });
                          _goToValidate();
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 15),
                          height: MediaQuery.of(context).size.shortestSide*0.1,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border:Border.all(color: (pos_y == 1)? Colors.white:  Colors.deepPurple,width: 2),
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              (loading)?
                              Container(
                                  height:40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.only(bottomLeft:  Radius.circular(4),topLeft: Radius.circular(4))
                                  ),
                                  child: Center(
                                    child: Container(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        )
                                    ),
                                  )
                              )
                                  :
                              Container(margin: EdgeInsets.only(left: MediaQuery.of(context).size.shortestSide*0.02),
                                  height:MediaQuery.of(context).size.shortestSide*0.05,
                                  width: MediaQuery.of(context).size.shortestSide*0.05,
                                  decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.only(bottomLeft:  Radius.circular(4),topLeft: Radius.circular(4))
                                  ),
                                  child: Icon( FontAwesomeIcons.envelope ,color: Colors.white)
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    (loading)?
                                    "Operation in progress ..."
                                        :
                                    "Sign in to your account !",
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.shortestSide*0.03,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),


                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(focusColor: Colors.red,onTap: (){
                            //MacAddress


                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MacAddress()),
                            );



                          },
                            child: Container(
                                margin: EdgeInsets.only(top: 10),
                                padding:  EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  "Settings",
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.shortestSide*0.035,
                                      fontWeight: FontWeight.bold,
                                      color:(pos_y == 2 && pos_x ==0)? Colors.redAccent:Colors.white60
                                  ),
                                )
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 10),
                            padding:  EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              "Privacy Policy !",
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.shortestSide*0.035,
                                  fontWeight: FontWeight.bold,
                                  color:(pos_y == 2&& pos_x ==1)? Colors.redAccent:Colors.white60
                              ),
                            )
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToValidate() {
    if(pos_y == 1){

      if(checkEmail(usernameController.text)){
        emailvalide = true;
      }else{
        emailvalide = false;
      }
      if(passwordController.text.length>=6){
        passwordvalide = true;
      }else{
        passwordvalide = false;

      }
      print("ok");
      setState(() {

      });

      if(true ||   passwordvalide && emailvalide){
        _login(usernameController.text.toString(), passwordController.text.toString());
      }
    }
  }
  bool checkEmail(String email){
    if(email.length<6)
      return false;
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    return emailValid;
  }

}
