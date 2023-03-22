import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedCity = '';
  dynamic response;
  dynamic statusCode = '';

  /// ÖNEMLİ -- response.statuscode olarak direk sana int verir bu şekilde daha kısa onpress
  /// içinde yazabilrsin

  Future<void> durumVeri() async {
    response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=2f2b8e9fe13db6a6c64a5db1d0d7ce33'));
    Map decodedStatus = jsonDecode(response.body);
    statusCode = decodedStatus['cod'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/search.jpg'),
          fit: BoxFit.cover,
        )),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(80, 120, 80, 25),
              child: TextField(
                onChanged: (value) {
                  selectedCity = value;
                },
                style: const TextStyle(fontSize: 22, fontFamily: 'Spartan MB'),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Ara',
                ),
              ),
            ),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade800),
                onPressed: () async {
                  await durumVeri();
                  setState(() {
                    if (statusCode == '404') {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Hatalı Yazım"),
                            content: const Text("Lütfen şehrin ismini tekrar yazın"),
                            actions: <Widget>[
                              TextButton(
                                child: const Text("Tamam"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Navigator.pop(context, selectedCity);
                    }
                  });
                },
                child: const Text(
                  'Şehir Seç',
                  style: TextStyle(fontSize: 16),
                ))
          ],
        ),
      ),
    );
  }
}
