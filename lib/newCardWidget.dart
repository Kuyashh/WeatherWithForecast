

import 'package:flutter/material.dart';

class DailyCardWidget extends StatelessWidget {

  DailyCardWidget({super.key, required this.iconVeri,required this.sicaklik,required this.tarih,required this.gun})  ;

  String iconVeri='10d' ;
  dynamic sicaklik = 0;
  String tarih = 'pazartesi' ;
  String gun = 'pazartesi; ';

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
     child: SizedBox(
       child: Column(
         children: [
           Image.network('http://openweathermap.org/img/wn/$iconVeri@2x.png'),

           Text('$sicaklik',style: const TextStyle(fontSize: 15),),
           const SizedBox(height: 10),
           Text(tarih),
           const SizedBox(height: 5),
           Text(gun)
         ],
       ),
     ), 
    );
  }
}
