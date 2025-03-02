import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Home2.dart';
import 'NewChild.dart';
import 'login.dart';



class ListofChildren extends StatefulWidget {
  String userId="";
  ListofChildren({super.key,required this.userId});

  @override
  State<ListofChildren> createState() => _ListofChildrenState();
}

class _ListofChildrenState extends State<ListofChildren> {
  String parentId="";
  final List<Color> colors = [
    Colors.blue.shade50,
    Colors.green.shade100,
    Colors.purple.shade100,
    Colors.orange.shade100,
    Colors.red.shade100,
    Colors.green.shade50,
  ];
  final Random random = Random();
  Map<String,dynamic> bodyData={};
  List<dynamic> childList=[];

  void initState() {
    super.initState();
    // Get the result from the pop action (newChild)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final newChild = ModalRoute.of(context)!.settings.arguments as Map?; // Adjust based on your data structure
      if (newChild != null) {
        setState(() {
          childList.add(newChild); // Add newChild to the list
        });
      }
    });
  }
  Map<String,dynamic> mineralsNeed={};

  Future<List<dynamic>> getChildById() async {
    try {
      var url = Uri.parse("http://92.205.109.210:8026/api/getchild");
      var apiResponse = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": widget.userId,  // Accessing the userId from widget
        }),
      );

      if (apiResponse.statusCode == 200) {
        var responseData = jsonDecode(apiResponse.body);
        childList= responseData["data"];

        print(childList);
        return childList;
      } else {
        throw Exception("Failed to fetch child data: ${apiResponse.statusCode}");
      }
    }
    catch (e) {
      throw Exception("Error fetching child: $e");
    }
  }
  Future<void> getParentId() async{
    if (childList.isNotEmpty) {
      parentId = childList.first["userid"]; // Extract the parent ID from the first child
      print("Extracted Parent ID: $parentId");
    }
    else {
      parentId=widget.userId;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No children found!"), backgroundColor: Colors.red),
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddnewChild(parentId: parentId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false, // Removes default back button
            backgroundColor: Colors.transparent, // Makes AppBar transparent
            elevation: 0, // Removes AppBar shadow
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
            ),
            title: const Text(
              "Who is in the List???",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            centerTitle: true,
            leading: IconButton(onPressed: (){
              Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>Loggingin()));
            }, icon: Icon(Icons.arrow_back))

        ),
        body:
        // List of Children
        SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                future: getChildById(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    var childList = snapshot.data;  // Now childList is a List of maps
                    if (childList == null || childList.isEmpty) {
                      return Center(child: Text("No children found"));
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: childList!.map<Widget>((child) {
                        String genderEmoji = child["gender"] == "male" ? "👦" : "👧";
                        Color bgColor = colors[random.nextInt(colors.length)];
                        String userId=child["userid"];
                        Map<String,dynamic> minerals={};
                        // mineralsNeed.addAll({"age":child["age"],"gender":child["gender"],"bmi":child["bmi"]});

                        print(minerals);
                        return SingleChildScrollView(
                          child: ListTile(
                            title: SingleChildScrollView(
                              child: GestureDetector(
                                onTap: (){
                                  minerals.addAll({"age":child["age"],"gender":"Girls","bmi":child["bmi"]});
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage2( age: minerals["age"],
                                    gender: minerals["gender"],
                                    bmi: minerals["bmi"],)));
                                },
                                child: Column(
                                    children:[
                                      Container(
                                        height: 220,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              genderEmoji,
                                              style: TextStyle(fontSize: 60),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              child["name"],
                                              style: TextStyle(
                                                  fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "Age: ${child["age"]}",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              "Child ID: ${child["gender"]}",  // Display childid
                                              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                            ),
                                            Text(
                                              "BMI: ${child["bmi"]}",  // Display childid
                                              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]
                                ),
                              ),
                            ),
                          ),
                        );

                      }).toList(),
                    );
                  } else {
                    return Center(child: Text("No children found"));
                  }
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: const CircleBorder( ),
                  padding: const EdgeInsets.all(30),
                ),
                child: const Icon(
                  Icons.add,
                  size: 50,
                ),
                onPressed: () {
                  getChildById();
                  childList.map((child)=>
                  parentId=child["userid"]);
                  getParentId();
                },
              ),
            ],

          ),
        )
    );
  }
}

