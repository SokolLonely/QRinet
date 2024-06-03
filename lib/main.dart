//import 'dart:ffi';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert' show utf8;
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
  List<String> RawValues = [];
  final stopwatch = Stopwatch();
  String _short = '';
  bool isRunning= true;
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

    final milliseconds = stopwatch.elapsedMilliseconds;
    final seconds = (milliseconds / 1000).truncate();
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
    child:Column(children: [
      SizedBox(
        height: 400,
        child: MobileScanner(onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes; //получение кр-кода
          print(barcodes[0].rawValue ?? "No Data found in QR");
          if (  isRunning && !stopwatch.isRunning )//&& currentBarcodes.length > 0
          {
            stopwatch.start();
            print('start');
          }
          if (isRunning && ( currentBarcodes.length == 0 ||  barcodes[0].rawValue != currentBarcodes.last.rawValue))
            {

              currentBarcodes.add(barcodes[0]);
              RawValues.add(barcodes[0].rawValue.toString());
              updateOutput(RawValues);

              print('added');
            }
          print(currentBarcodes.length);
          //криптография
          //ona vyshe


}),
      ),
        Text(_formatStopwatchTime() +'\n'+ _short ),//часы

        FloatingActionButton(child: Text(ButtonText, ),//кнопка старт-стоп
            backgroundColor: Colors.deepOrange,
            onPressed:
            (){
              isRunning = !isRunning;
              if (stopwatch.isRunning)
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
        ),

        Text(Output)//сплит
        ,
        SizedBox(
          width: 70,

          child:
        FloatingActionButton(
            child: Text('recent\nactivities'),
            backgroundColor: Colors.deepOrange,
            onPressed: (){
          Navigator.pushNamed(context, '/recent');
        }),

    ),
        // FloatingActionButton(child: Text('remove'), backgroundColor: Colors.deepOrange,onPressed: (){
        //   SetState(){
        //     currentBarcodes.removeLast();
        //     RawValues.removeLast();
        //     _short = sha256.convert(utf8.encode(RawValues.join(""))).toString().substring(0, 10);
        //     updateOutput(Output);
        //   }
        // })
      ]))
    );
  }
}