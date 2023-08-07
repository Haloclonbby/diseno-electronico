import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),

        useMaterial3: true,
      ),
      //darkTheme: ThemeData.dark(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String latitude = "";
  String altitude = "";
  String phone = "";
  StreamSubscription<Position>? positionStream;
  final Telephony telephony = Telephony.instance;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();

  }

  void getLocation() async {
    bool permisosLocation = await checkPermission();
    if (permisosLocation && positionStream == null ){
       positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
              (Position? position) {

            altitude = position!.altitude.toString();
            latitude = position!.latitude.toString() ;
            setState(() {

            });
          });
    }
  }

  Future<bool> checkPermission() async  {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        Fluttertoast.showToast(
            msg: 'Sin permisos de ubicacion',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: 'Sin permisos de ubicacion permante',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return false;

    }
    return true;
  }

  /*
  Future<Position> determinePosition() async  {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error("Sin permisos ");
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void getCurrentPosition() async {
    Position position = await determinePosition();
    altitude = position.altitude;
    latitude = position.latitude + 1;
    setState(() {
    });
  }*/

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Enviar ubicacion SMS"),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Center(child:
      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(child:  Text("Coordenadas", style: TextStyle(fontSize: 20))),
            Center(child:  Text(latitude == "" ?'Sin permisos': 'Latitud:$latitude Altitud: $altitude',)),
            const SizedBox(height: 50),
            SizedBox(width: 300, child:TextField(onChanged: (value){
              if(value.isNotEmpty){
                phone =value;
                setState(() {
                });
              }
            },decoration: const InputDecoration(border: OutlineInputBorder(),labelText: "Teléfono",),
              keyboardType: TextInputType.number,
            ),)
          ]),),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if(phone.length != 10){
            Fluttertoast.showToast(
                msg: 'Teléfono invalido',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
          if (positionStream == null ){
            getLocation();
          }
          if(phone.length == 10 && latitude != "" && altitude != ""){
            telephony.sendSms(to: phone, message: 'Tus coordenadas son : \n Latitud:$latitude \n Altitud: $altitude');
            Fluttertoast.showToast(
                msg: 'Ubicacion Enviada',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
        },
        child: const Icon(Icons.send),

      ),
    );//
  }
}