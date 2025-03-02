import 'dart:convert';
import 'dart:math';
import 'package:diet_app/add%20child.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChildrenList extends StatefulWidget {
  String userId="P003";
 // ChildrenList({super.key,required this.userId});
   ChildrenList({super.key});

  @override
  State<ChildrenList> createState() => _ChildrenListState();
}

class _ChildrenListState extends State<ChildrenList> {
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
      MaterialPageRoute(builder: (context) => AddChild(parentId: parentId)),
    );
   }
   @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Available Children"),
          centerTitle: true,
        ),
        body: Stack(
            children: [
              // Gradient Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pinkAccent, Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // List of Children
              Column(
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

                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: childList!.map<Widget>((child) {
                              String genderEmoji = child["gender"] == "male" ? "👦" : "👧";
                              Color bgColor = colors[random.nextInt(colors.length)];
                              String userId=child["userid"];
                              return ListTile(
                                  title: Column(
                                      children:[
                                        Container(
                                          height: 180,
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
                                                "Child ID: ${child["childid"]}",  // Display childid
                                                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]
                                  ),
                                );

                            }).toList(),
                          ),
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

              )
            ]
        )
    );
  }
}