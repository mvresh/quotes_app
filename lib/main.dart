import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';


Color appColor = Colors.white;
Brightness mode = Brightness.light;
void main() {
  runApp(QuotesPage(),
  );
}
bool apiCall = false;
class QuotesPage extends StatefulWidget {
  @override
  _QuotesPageState createState() => _QuotesPageState();
}
AnimationController _controller;

class _QuotesPageState extends State<QuotesPage> with SingleTickerProviderStateMixin {
  String quote = 'Time is not the main thing. It is the only thing.';
  String author = 'Miles Davis';

  Future<Map> getQuote() async {
    Map decodedMap;
    Response response = await get('https://favqs.com/api/qotd');
    if (response.statusCode == 200) {
      decodedMap = jsonDecode(response.body);
    }
    return decodedMap;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: appColor,
        brightness: mode,
      ),
      home: Scaffold(
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Align(alignment: Alignment.centerLeft,child: Text('Change Animation',style: TextStyle(fontFamily: 'Playfair', fontSize: 35),)),
              ),
              ListTile(
                title: Text('Fade Transition',style: TextStyle(fontFamily: 'Playfair', fontSize: 25,)),
                onTap: (){
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Scale Transition',style: TextStyle(fontFamily: 'Playfair', fontSize: 25)),
                onTap: (){
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Slide Transition',style: TextStyle(fontFamily: 'Playfair', fontSize: 25)),
                onTap: (){
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Center(
                    child:  CommonQuoteTextWidget(quote: quote),
                  ),
                ),

                Expanded(flex: 1,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$author',
                        style: TextStyle(
                            fontSize: 20,
                            color: appColor == Colors.white ? Colors.red : Colors.greenAccent,
                            fontStyle: FontStyle.italic),
                        textAlign: TextAlign.left,
                      )),
                ),
                Expanded(flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RawMaterialButton(
                          constraints: BoxConstraints.tightFor(width: 60,height: 60),
                          shape: CircleBorder(),
                          elevation: 2.0,
                          onPressed: () async{
                            setState(() {
                              apiCall = true;
                            });
                            Map finalQuoteMap = await getQuote();
                            setState(() {
                              quote = finalQuoteMap['quote']['body'];
                              author = finalQuoteMap['quote']['author'];
                              apiCall = false;
                            });
                          },
                          child: apiCall == false?Icon(Icons.arrow_forward,color: Colors.red,size: 30,):CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green),strokeWidth: 1,),
                          fillColor: Colors.white,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RawMaterialButton(
                          constraints: BoxConstraints.tightFor(width: 60,height: 60),
                          shape: CircleBorder(),
                          elevation: 2.0,
                          onPressed: () {
                            if(appColor == Colors.white){
                              appColor = Colors.black;
                              mode = Brightness.dark;
                            }
                            else{
                              appColor = Colors.white;
                              mode = Brightness.light;
                            }

                            setState(() {

                            });
                          },
                          child: Icon(Icons.wb_sunny,size: 30,),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CommonQuoteTextWidget extends StatelessWidget {
  const CommonQuoteTextWidget({
    Key key,
    @required this.quote,
  }) : super(key: key);

  final String quote;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$quote',
      style: TextStyle(fontFamily: 'Playfair', fontSize: 30),
      textAlign: TextAlign.left,
    );
  }
}
