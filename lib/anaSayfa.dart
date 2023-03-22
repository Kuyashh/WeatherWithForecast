import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:havadurumux/newCardWidget.dart';
import 'package:havadurumux/searchPage.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({Key? key}) : super(key: key);

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  String sehir = 'Denizli';
  dynamic sicaklik = 'veri';
  late Position position;
  dynamic response;
  String arkaPlan = 'acik';
  String weApiKey = '2f2b8e9fe13db6a6c64a5db1d0d7ce33';
  String iconVeri = '10d';
  String isiString = 'Açık';

  List<String> iconlar = ['10d', '10d', '10d', '10d', '10d'];
  List<dynamic> isilar = [0, 0, 0, 0, 0];
  List<String> tarihler = ['pazartesi', 'salı', 'çarşamba', 'perşembe', 'cuma'];
  List<String> yediGunleri = [
    'pazartesi',
    'salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];
  List<String> haftaninGunleri = [
    'pazartesi',
    'salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];

  Future<void> getDevicePosition() async {
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } catch (e) {


      /// alertDialog çıkarılacak /zamanAşımı,
      /// gps i kontrol edin cihaz izinlerini verin
    } finally {
      /// cevap gelmezse uygulama sadece sehır adıyla  çalışacak
    }
  }

  Future<void> getLocationData() async {
    response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$sehir&appid=$weApiKey&units=metric&lang=tr'));
    final parsedVeri = jsonDecode(response.body);

    setState(() {
      sicaklik = parsedVeri['main']['temp'];
      sehir = parsedVeri['name'];
      arkaPlan = parsedVeri['weather'][0]['main'];
      iconVeri = parsedVeri['weather'][0]['icon'];
      isiString = parsedVeri['weather'][0]['description'];
    });
  }

  Future<void> getLocationDataByLatLong() async {
    dynamic parsedLocation = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$weApiKey&units=metric&lang=tr'));
    final parsedloc = jsonDecode(parsedLocation.body);

    setState(() {
      sicaklik = parsedloc['main']['temp'];
      sehir = parsedloc['name'];
      arkaPlan = parsedloc['weather'][0]['main'];
      iconVeri = parsedloc['weather'][0]['icon'];
      isiString = parsedloc['weather'].first['description'];
    });
  }

  Future<void> getForecastByLocation() async {
    dynamic forecastData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$sehir&appid=$weApiKey&units=metric'));
    final forecastParsed = jsonDecode(forecastData.body);
    setState(() {
      iconlar.clear();
      isilar.clear();
      tarihler.clear();
      yediGunleri.clear();
      for (int i = 3; i < 40; i = i + 8) {
        iconlar.add(forecastParsed['list'][i]['weather'][0]['icon']);
        isilar.add(forecastParsed['list'][i]['main']['temp']);
        tarihler.add(forecastParsed['list'][i]['dt_txt']);

        DateTime parsedTime =
            DateTime.parse(forecastParsed['list'][i + 1]['dt_txt']);

        int gunSayisi = parsedTime.weekday;
        yediGunleri.add(haftaninGunleri[gunSayisi - 1]);
      }
    });
  }

  Future<void> getDailyForecastByLatLong() async {
    dynamic forecastData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=$weApiKey&units=metric'));
    final forecastParsed = jsonDecode(forecastData.body);
    setState(() {
      iconlar.clear();
      isilar.clear();
      tarihler.clear();
      yediGunleri.clear();

      for (int i = 3; i < 40; i = i + 8) {
        iconlar.add(forecastParsed['list'][i + 1]['weather'][0]['icon']);
        isilar.add(forecastParsed['list'][i + 1]['main']['temp']);
        tarihler.add(forecastParsed['list'][i + 1]['dt_txt']);

        DateTime parsedTime =
            DateTime.parse(forecastParsed['list'][i + 1]['dt_txt']);

        int gunSayisi = parsedTime.weekday;

        yediGunleri.add(haftaninGunleri[gunSayisi - 1]);
      }
    });
  }

  void getInitialData() async {
    await getDevicePosition();
    await getLocationDataByLatLong();
    await getDailyForecastByLatLong();
  }

  @override
  void initState() {
    getInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover, image: AssetImage('assets/$arkaPlan.jpg'))),
      child: sicaklik == 'veri'
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(120, 80, 120, 10),
                    child: LoadingIndicator(
                        indicatorType: Indicator.ballScaleMultiple,
                        colors: [Colors.blue],
                        strokeWidth: 2,
                        backgroundColor: Colors.transparent,
                        pathBackgroundColor: Colors.yellow),
                  ),
                  Text(
                    'Veriler yükleniyor',
                    style: TextStyle(fontSize: 25),
                  )
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: Image.network(
                      'http://openweathermap.org/img/wn/$iconVeri@2x.png'),
                ),
                Text(
                  '$sicaklik°',
                  style: TextStyle(
                      shadows: [
                        Shadow(
                            blurRadius: 30,
                            color: Colors.blueGrey.shade900,
                            offset: const Offset(6.0, 6.0))
                      ],
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Spartan MB'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    '\'$isiString\'',
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Spartan MB',
                        shadows: [
                          Shadow(
                              color: Colors.blueGrey.shade900,
                              offset: const Offset(6.0, 6.0),
                              blurRadius: 30)
                        ]),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      sehir,
                      style: TextStyle(shadows: [
                        Shadow(
                            blurRadius: 30,
                            color: Colors.blueGrey.shade900,
                            offset: const Offset(6.0, 6.0))
                      ], fontSize: 30, fontFamily: 'Spartan MB'),
                    ),
                    IconButton(
                        onPressed: () async {
                          sehir = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SearchPage()));
                          getLocationData();
                          getForecastByLocation();
                        },
                        icon: Icon(
                          Icons.search,
                          shadows: [
                            Shadow(
                                offset: const Offset(6.0, 6.0),
                                blurRadius: 30,
                                color: Colors.blueGrey.shade900)
                          ],
                        ))
                  ],
                ),
                dailyWeatherCard(context)
              ],
            ),
    );
  }

  Widget dailyWeatherCard(BuildContext context) {
    List<DailyCardWidget> cards = [];

    for (int i = 0; i < 5; i++) {
      cards.add(DailyCardWidget(
        iconVeri: iconlar[i],
        sicaklik: isilar[i],
        tarih: tarihler[i],
        gun: yediGunleri[i],
      ));
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.22,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }
}
