import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:http/http.dart' as http;

// i dont know why i need to double run then i get the data from API 
// its actually works fine i alr look through and try to comprehend line by line
// but i think it is the same as u taught us (i found out this has some problem with stateful)

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        fontFamily: 'Georgia',
        useMaterial3: true,
      ),
      home: MyPlaces()
    );
  }
}

class MyPlaces extends StatefulWidget {
  const MyPlaces({super.key});

  @override
  State<MyPlaces> createState() => _MyPlacesState();
}

class _MyPlacesState extends State<MyPlaces> {
  late double screenHeight, screenWidth;
  List<dynamic> placeList = [];
  String status = "Pressing the button to load places";
  bool vis = false;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;    
    if (screenWidth > 600) {
      screenWidth = 600;
    } 
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPlaces'),
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth,
          child: Column(
            children: [
              Text(
                'Welcome to The MyPlaces App',
                style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: screenWidth,
                child: ElevatedButton(
                  onPressed: fetchPlaces,
                  child: const Text('Load Places', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                ),
              ),
              SizedBox(height: 10),
              Visibility(visible: vis, child: CircularProgressIndicator()),
              SizedBox(height: 10),
              placeList.isEmpty
                ? SizedBox(height: 100, child: Center(child: Text(status)))
                : Expanded(
                    child: ListView.builder(
                      itemCount: placeList.length,
                      itemBuilder: (context, index) {
                        String placeName = placeList[index]['name'];//"";
                        String state = placeList[index]['state'];
                        String imgUrl = placeList[index]['image_url'];
                        double rating = placeList[index]['rating'];
                        String desc = placeList[index]['description'];                        
                        String latitude = placeList[index]['latitude'].toString();                        
                        String longitude = placeList[index]['longitude'].toString();                        
                        String contact = placeList[index]['contact'];
                        int id = placeList[index]['id'];
                        String category = placeList[index]['category'];

                        return SizedBox(
                          height: 150,
                          child: Card(
                            elevation: 2,
                            
                            child: ListTile(
                              leading: SizedBox(
                                width: 100,
                                height: 100,
                                child: ImageNetwork(
                                  
                                  image: imgUrl,
                                  width: 100,
                                  height: 100,
                                  onError: const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                              ),

                              title: Text(placeName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(state),
                                  Text('Rating: $rating/5'),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: (){
                                  showDialog(
                                    context: context,
                                     builder: (context) {
                                      return AlertDialog(
                                        title: Text("$placeName Details"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: 
                                        [
                                          Text("Place ID: ${id.toString()}"),
                                          Text('Name: $placeName'),
                                          Text('State: $state'),
                                          Text('Description: $desc'),
                                          Text('Contact: $contact'),
                                          Text('Latitude: $latitude'),
                                          Text('Longitude: $longitude'),
                                          Text('Rating: $rating/5'),
                                          Text('Category: $category'),
                                        ],  
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: (){
                                              Navigator.of(context).pop();
                                            }, 
                                            child: Text("Close")
                                          )
                                        ],
                                      );
                                  });
                                }, 
                                icon: Icon(Icons.arrow_forward_ios)
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            ],
          ),
        ),

      ),
    );
  }
  void fetchPlaces() {
    status = "Fetching places...";
    vis = true;
    setState(() {});

    http.get(Uri.parse("https://slumberjer.com/teaching/a251/locations.php?state=&category=&name=")).timeout(
      Duration(seconds: 5),
      onTimeout: () {
        status = "Request timed out. Please try again.";
        vis = false;
        setState(() {});
        return http.Response('Error', 408); // Request Timeout response
      },
    ).then((
      response
    ) {
      if (response.statusCode == 200) {
        var data = response.body;
        //print(response.body.toString());
        placeList = []; 
        placeList = json.decode(data);
        status = "Loaded ${placeList.length} places.";
        vis = false;
        setState(() {});
      } else if(response.statusCode != 200){
        status = "Failed to load places. Error: ${response.statusCode}";
        vis = false;
        setState(() {});
        return;
      } else {
        status = "Failed to load places. Error: ${response.statusCode}";
        vis = false;
        setState(() {});
      }      
    }).catchError((error) {
      status = "Error fetching places: $error";
      vis = false;
      setState(() {});
    });
    
    if(placeList.isEmpty){
      status = "Did not found any places.";
      vis = false;
      setState(() {});
      return;
    }
  }
}