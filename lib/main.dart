//import 'dart:ffi';

import 'dart:async';
import 'Mystopwatch.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert' show utf8;
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute:  '/',
      routes:
      {
        '/':(context) => MyHomePage(),
        '/recent':(context) => Recent(),

      },
    );
  }
}
List<String> _savedRecentList = [];
class Recent extends StatefulWidget
{
  const Recent({super.key});
  @override
  State<Recent> createState() => _RecentCreateState();
}
class _RecentCreateState extends State<Recent>
{
_loadList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    _savedRecentList = prefs.getStringList('recent') ??  [];
  });
}
void initState() {
  _loadList();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
        SingleChildScrollView(
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children:[Text('\n\n'+ _savedRecentList.toString()),
                // FloatingActionButton(child: Text('очистить'), onPressed: (){
                //   _savedRecentList = [];
                //   //_saveList(_savedRecentList);
                //  })
              ]
          )
        )


    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Barcode> currentBarcodes = [];
  AudioPlayer audioPlayer = AudioPlayer();
  List<String> RawValues = [];
  final stopwatch = Mystopwatch();
  String _short = '';
  bool isRunning= true;
  //var startTime = DateTime.now();
  String ButtonText = "Stop";
  String Output = '';
  int i = 0;
  void initState() {
     isRunning = true;
     _loadUsername();

  Timer.periodic(Duration(milliseconds: 900), _updateTimer);}
  void _updateTimer(Timer timer)
  {
    print(RawValues.join(""));
    setState(() {
      _short = sha256.convert(utf8.encode(RawValues.join(""))).toString().substring(0, 10);
      RawValues = RawValues;
      Output = Output;

    }
    );

  }

  //dynamic temp = ';
  String result = '';
  void playLocal() async {
    await audioPlayer.play(UrlSource('assets/new_message_notice.mp3'));

  }
  String _savedUsername = "set your name";
  _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedUsername = prefs.getString('username') ?? '';
    }
    );
  }
  _saveUsername(String username) async {//это сохранение имени
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }
  _saveList(List<String> username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent', _savedRecentList);
  }
  String _formatStopwatchTime() {

    //final milliseconds = stopwatch.elapsedMilliseconds;
    //final seconds = (milliseconds / 1000).truncate();
    //final minutes = (seconds / 60).truncate();
    //final seconds = -startTime.second + DateTime.now().second;
    //final minutes = -startTime.minute + DateTime.now().minute;

      final timeDifference = stopwatch.result();//DateTime.now().difference(startTime);
      final seconds = timeDifference.inSeconds;
      final minutes = (seconds / 60).truncate();
      String secondsStr = (seconds % 60).toString().padLeft(2, '0');
      String minutesStr = minutes.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }
  void _changeText() {
    setState(() {
      ButtonText = ButtonText == 'Start' ? 'Stop' : 'Start';
    });
  }
  void updateOutput(List){
    String ans = Output;
    // for (String el in List)
    //   { //const String temp = _formatStopwatchTime();
        ans = ans + i.toString() +' ' + List.last +' '+_formatStopwatchTime() +'\n';
        i+=1;


      Output = ans;

    //return ans;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title:  Text('QRinet'),
            centerTitle: true,
            backgroundColor: Colors.deepOrange,
            //actionsIconTheme: IconThemeData(),
            actions: <Widget>[
              Text(_savedUsername),
              IconButton(onPressed: () {
                showDialog(context: context, builder: (BuildContext context){
                  return AlertDialog(
                    title: Text('change name'),
                    content: TextField(
                      onChanged: (String Value){
                        _saveUsername(Value);
                        setState(() {
                          _savedUsername = Value;
                        });

                      },
                    ),
                    actions: [FloatingActionButton(onPressed: (){
                      Navigator.of(context).pop();
                    },
                      child: Text('change'),
                    )

                    ],
                  );
                  //eventManager.eventStream.listen((event) {
                  //    print("Получено событие с параметром: ${event.parameter}");
                  //  });

                });
              },
                  icon:  const Icon(Icons.account_circle)),

            ]
        ),
      body: SingleChildScrollView(
    child:
      Column(children: [
        SizedBox(
          height: 400,
          child: MobileScanner(onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes; //получение кр-кода
            print(barcodes[0].rawValue ?? "No Data found in QR");
            if (  isRunning && !stopwatch.isRunning() )//&& currentBarcodes.length > 0 //first (start) qr
                {
              stopwatch.start();
               //startTime = DateTime.now();
              print('start');
            }
            if (isRunning && ( currentBarcodes.length == 0 ||  barcodes[0].rawValue != currentBarcodes.last.rawValue))
            {

              currentBarcodes.add(barcodes[0]);
              RawValues.add(barcodes[0].rawValue.toString());
              updateOutput(RawValues);
              playLocal();
              print('added');
            }
            print(currentBarcodes.length);
            //криптография
            //ona vyshe


          }),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [FloatingActionButton(child: Text(ButtonText, ),//кнопка старт-стоп
              backgroundColor: Colors.deepOrange,
              onPressed:
                  (){
                isRunning = !isRunning;
                if (stopwatch.isRunning())
                {
                  stopwatch.stop();
                  _changeText();
                  setState(() {
                    _savedRecentList.add('TIME: '+ _formatStopwatchTime()+' HASH: '+ _short + '\n' + Output+'\n');
                  });

                  _saveList(_savedRecentList);
                }
                else
                {
                  stopwatch.reset();
                  stopwatch.stop();
                  _short = '';
                  currentBarcodes = [];
                  RawValues = [];
                  Output = '';
                  _changeText();
                  i = 0;//сброс всего
                }
              }
          ),Text('\n '),
              SizedBox(
            width: 70,

            child:
            FloatingActionButton(
                child: Text('recent\nactivities'),
                backgroundColor: Colors.deepOrange,
                onPressed: (){
                  Navigator.pushNamed(context, '/recent');
                }),

          ),],  ),
          Column(children: [Text(_formatStopwatchTime() , style: TextStyle(
            fontSize: 24.0, // Увеличение размера шрифта
          ),),
            Text( _short ),//часы



            Text(Output)//сплит
            ,],),
        ],),


        // FloatingActionButton(child: Text('remove'), backgroundColor: Colors.deepOrange,onPressed: (){
        //   SetState(){
        //     currentBarcodes.removeLast();
        //     RawValues.removeLast();
        //     _short = sha256.convert(utf8.encode(RawValues.join(""))).toString().substring(0, 10);
        //     updateOutput(Output);
        //   }
        // })
      ]),)
    );
  }
}