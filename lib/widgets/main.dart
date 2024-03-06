import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../models/launch_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Products',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MissionPage(),
    );
  }
}

class MissionPage extends StatefulWidget {
  const MissionPage({super.key});

  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> {
  late Future<List<Launch>> futureLaunchList;

  Future<List<Launch>> fetchData() async {
    Uri uriObject = Uri.parse('https://api.spacexdata.com/v3/missions');
    final response = await http.get(uriObject);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      List<dynamic> parseListJson = body;

      // cant access by iterable through index
      List<Launch> items = List<Launch>.from(
        //map returns and interable
        parseListJson.map<Launch>((dynamic launch) => Launch.fromJson(launch)),
      );

      //.from is more optimized than .tolist()
      return items;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    futureLaunchList = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Space Missions"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FutureBuilder(
              future: futureLaunchList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var launch = snapshot.data![index];
                      var expanded = false;
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  launch.missionName!,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                if (expanded)
                                  Text(
                                    launch.description!,
                                    style: TextStyle(fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      MaterialButton(
                                        onPressed: () {
                                          if (expanded) {
                                            expanded = false;
                                          } else {
                                            expanded = true;
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              "More",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Icon(Icons.arrow_downward),
                                          ],
                                        ),
                                        color: Colors.orangeAccent,
                                        textColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      )
                                    ]),
                                Center(
                                  child: Wrap(
                                    spacing: 12,
                                    children: [
                                          var generatedColor = Random().nextInt(Colors.primaries.length)
                                          Colors.primaries[generatedColor]
                                      for (var item in launch.payloadIds!)
                                        Chip(
                                          label: Text(item),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                        )
                                    ],
                                  ),
                                )
                              ]),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }

                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                );
              })),
    );
  }
}
