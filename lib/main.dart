import 'dart:convert';

import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:drawerbehavior/drawerbehavior.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:screenshot_share_image/screenshot_share_image.dart';


Color appColor = Colors.deepPurple;
Brightness mode = Brightness.light;
Color color1Begin = Colors.lightGreen.shade100;
Color color1End = Colors.lightBlue.shade100;
void main() {
  runApp(QuotesPage(),
  );
}
bool apiCall = false;
class QuotesPage extends StatefulWidget {
  @override
  _QuotesPageState createState() => _QuotesPageState();
}

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
        body: SafeArea(
          child:Stack(
            children: <Widget>[
              Positioned.fill(child: AnimatedBackground(color1Begin,color1End)),
              onBottom(AnimatedWave(
                height: 180,
                speed: 1.0,
              )),
              onBottom(AnimatedWave(
                height: 120,
                speed: 0.9,
                offset: pi,
              )),
              onBottom(AnimatedWave(
                height: 220,
                speed: 1.2,
                offset: pi / 2,
              )),
              Padding(
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
                                color: appColor == Colors.white ? Colors.red : Colors.deepPurple.shade900,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
  onBottom(Widget child) => Positioned.fill(
    child: Align(
      alignment: Alignment.bottomCenter,
      child: child,
    ),
  );
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

class AnimatedBackground extends StatefulWidget {
  Color color1begin;
  Color color1end;
  AnimatedBackground(this.color1begin,this.color1end);
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Colors.lightBlueAccent.shade100, end: Colors.greenAccent.shade200)),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Colors.green.shade100, end: Colors.lightBlueAccent.shade100))
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [animation["color1"], animation["color2"]])),
        );
      },
    );
  }
}

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  AnimatedWave({this.height, this.speed, this.offset = 0.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: height,
        width: constraints.biggest.width,
        child: ControlledAnimation(
            playback: Playback.LOOP,
            duration: Duration(milliseconds: (5000 / speed).round()),
            tween: Tween(begin: 0.0, end: 2 * pi),
            builder: (context, value) {
              return CustomPaint(
                foregroundPainter: CurvePainter(value + offset),
              );
            }),
      );
    });
  }
}

class CurvePainter extends CustomPainter {
  final double value;

  CurvePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()
      ..color = Colors.white.withAlpha(50);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

}