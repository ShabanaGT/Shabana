import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'login.dart';

class Homepage2 extends StatefulWidget {
 // final Map<String,dynamic> mineralsNeed;
  final int age;
  final String gender;
  final String bmi;
    Homepage2({super.key, required this.age,
      required this.gender,
      required this.bmi,});

  @override
  State<Homepage2> createState() => _Homepage2State();
}

class _Homepage2State extends State<Homepage2> with TickerProviderStateMixin {
  final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool isLoading = true;

  final Map<String, Map<String, double>> nutrientValues = {};
  double proteinProgress = 0;
  double fiberProgress = 0;
  double fatProgress = 0;
  double carbsProgress = 0;

  late TabController _tabController;
  List<Map<String, dynamic>> foodList = [];
  Map<String, bool> selectedItems = {}; // Track selected food items

  @override
  void initState() {
    super.initState();
    fetchNutrientData();
    _tabController = TabController(length: 4, vsync: this);
    fetchFoodData();

    selectedItems = {
      for (var food in foodList) food['foodId']: false
    }; // Initialize selected items
    // print("Received mineralsNeed: ${widget.mineralsNeed}");
    //
    //   print("Age:${widget.mineralsNeed["age"].toString()}");
    //   print("Gender:${widget.mineralsNeed["gender"]}");
    //   print("Bmi:${widget.mineralsNeed["bmi"]}");

    }

  Future<void> fetchFoodData() async {
    final url = Uri.parse("http://92.205.109.210:8026/food/getallfood");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          foodList = List<Map<String, dynamic>>.from(data['data']);

        });
        print(foodList);
        updateProgress();
      } else {
        throw Exception("Failed to load food data");
      }
    } catch (e) {
      print("Error fetching food data: $e");
    }
  }

  bool isLoading1 = false;
  String responseMessage = "";

  /// 📌 Function to send the POST request
  Future<void> submitReport() async {
    print("hi");
    setState(() {
      isLoading1 = true;
      responseMessage = "";
    });
    bool anyFoodSelected = selectedItems.values.contains(true);
    if (!anyFoodSelected) {
      setState(() {
        responseMessage = "Please select at least one food item.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseMessage), backgroundColor: Colors.red),
      );
      setState(() {
        isLoading1 = false;
      });
      return; // Exit early if no items are selected
    }
    // Gather selected foods and their nutritional values
    List<Map<String, dynamic>> selectedFoodData = [];
    double totalProtein = 0;
    double totalFiber = 0;
    double totalFat = 0;
    double totalCarbs = 0;

    for (var foodId in selectedItems.keys) {
      if (selectedItems[foodId] == true) { // If item is selected
        var food = foodList.firstWhere((item) => item['foodId'] == foodId);

        if (food != null) {
          // Add selected food data to the list
          selectedFoodData.add({
            "foodId": food['foodId'],
            "foodName": food['foodName'],
            "proteinAmount": food["proteinAmount"],
            "fiberAmount": food["fiberAmount"],
            "fatAmount": food["fatAmount"],
            "carbsAmount": food["carbsAmount"]
          });

          // Calculate total nutritional values
          totalProtein +=
              double.tryParse(food["proteinAmount"].toString()) ?? 0;
          totalFiber += double.tryParse(food["fiberAmount"].toString()) ?? 0;
          totalFat += double.tryParse(food["fatAmount"].toString()) ?? 0;
          totalCarbs += double.tryParse(food["carbsAmount"].toString()) ?? 0;
        }
      }
    }

    final url = Uri.parse("http://92.205.109.210:8026/report/create");

    // 📌 JSON Body with selected food items and their nutritional values
    final Map<String, dynamic> requestBody = {
      "childid": "67b9c158a9ca358db64cb2ec",
      "parentid": "67b9ad24c530c026016c42be",
      "date": currentDate, // Use current date or a custom date
      "protein": {"required": "20", "achieved": totalProtein.toString()},
      "fiber": {"required": "25", "achieved": totalFiber.toString()},
      "carbs": {"required": "10", "achieved": totalCarbs.toString()},
      "fat": {"required": "10", "achieved": totalFat.toString()},
      "selectedFood": selectedFoodData // Add selected food data
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Success - Parse response
        final responseData = jsonDecode(response.body);

        if (responseData["status"] == "success") {
          setState(() {
            responseMessage = "Report submitted successfully!";
          });
          print(responseData["message"]);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(responseData["message"]),
            backgroundColor: Colors.black,));
          // Navigator.push(
          //   context,
          //MaterialPageRoute(builder: (context) =>  Progressbar()),

          // );
        } else {
          setState(() {
            responseMessage = "Submission failed: ${responseData["message"]}";
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(responseData["message"]),
            backgroundColor: Colors.black,));
        }
      } else {
        // ❌ API error (4xx, 5xx)
        setState(() {
          responseMessage = "Failed! Server error: ${response.statusCode}";
        });
      }
    } catch (error) {
      setState(() {
        responseMessage = "Error: $error";
      });
    }

    setState(() {
      isLoading1 = false;
    });
  }

  List<Map<String, dynamic>> getFilteredFood(String status) {
    return foodList.where((food) {
      if (status == "P") return food['status'] == "P";
      if (status == "Fi") return food['status'] == "Fi";
      if (status == "F") return food['status'] == "F";
      if (status == "C") return food['status'] == "C";
      return false;
    }).toList();
  }


  void updateProgress() {
    double totalProtein = 0;
    double totalFiber = 0;
    double totalFat = 0;
    double totalCarbs = 0;

    for (var foodId in selectedItems.keys) { // Iterate over keys (food IDs)
      if (selectedItems[foodId] == true) { // Check if item is selected
        var food = foodList.firstWhere(
              (item) => item['foodId'] == foodId,
          // orElse: () => null,
        );

        if (food != null) {
          totalProtein +=
              double.tryParse(food["proteinAmount"].toString()) ?? 0;
          totalFiber += double.tryParse(food["fiberAmount"].toString()) ?? 0;
          totalFat += double.tryParse(food["fatAmount"].toString()) ?? 0;
          totalCarbs += double.tryParse(food["carbsAmount"].toString()) ?? 0;
        }
      }
    }

    setState(() {
      proteinProgress = (totalProtein / 100).clamp(0.0, 1.0);
      fiberProgress = (totalFiber / 100).clamp(0.0, 1.0);
      fatProgress = (totalFat / 100).clamp(0.0, 1.0);
      carbsProgress = (totalCarbs / 100).clamp(0.0, 1.0);
    });

    print(
        "Updated Progress: Protein: $proteinProgress, Fiber: $fiberProgress, Fat: $fatProgress, Carbs: $carbsProgress");
  }
  String Protein="";
  String Fiber="";
  String Fat="";
  String Carbohydrates="";



  Future<void> fetchNutrientData() async {
    try {
      var response = await http.post(
        Uri.parse("http://92.205.109.210:8026/report/getall"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Age": widget.age,
          "Gender": widget.gender,
          "bmiRange": widget.bmi,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var bodyData = jsonDecode(response.body);
        var requirements = bodyData["data"];

        if (requirements.isNotEmpty) {
          // Extract nutrients using map
          var nutrientData = requirements.map((item) => {
            "Protein": item["Protein"],
            "Carbohydrates": item["Carbohydrates"],
            "Fat": item["Fat"],
            "Fiber": item["Fiber"]
          }).first;

          setState(() {
            Protein = nutrientData["Protein"]!;
            Carbohydrates = nutrientData["Carbohydrates"]!;
            Fat = nutrientData["Fat"]!;
            Fiber = nutrientData["Fiber"]!;
          });
        }

        print("Data fetched successfully");
      } else {
        print("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          _buildTopDesign(),
          Expanded( // Ensure the tab bar and list are visible
            child: SingleChildScrollView(
              child: DefaultTabController(
                length: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          currentDate,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProgressTab(
                          'Protein', proteinProgress, 'Protein', Colors.yellow),
                      _buildProgressTab(
                          'Fiber', fiberProgress, 'Fiber', Colors.green),
                      _buildProgressTab('Fat', fatProgress, 'Fat', Colors.red),
                      _buildProgressTab('Carbohydrates', carbsProgress,
                          'Carbohydrates', Colors.blue),
                      const SizedBox(height: 20),
                      TabBar(
                        indicatorColor: Colors.white,
                        labelStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black.withOpacity(0.7),
                        ),
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Protein'),
                          Tab(text: 'Fiber'),
                          Tab(text: 'Fat'),
                          Tab(text: 'Carbohydrates'),
                        ],
                      ),
                      SizedBox(
                        height: 300, // Ensures TabBarView is visible
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            buildFoodList("P"),
                            buildFoodList("Fi"),
                            buildFoodList("F"),
                            buildFoodList("C"),
                          ],
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            submitReport();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("Update",
                              style:
                              TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab(String label, double progress, String progressText,
      Color labelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 22, color: labelColor),
          ),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.black.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation(Colors.blue),
          ),
          const SizedBox(height: 5),
          Text(
            '${(progress * 100).toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget buildFoodList(String status) {
    List<Map<String, dynamic>> filteredList = getFilteredFood(status);
    return filteredList.isEmpty
        ? Center(child: Text("No food items found"))
        : ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        var food = filteredList[index];
        return CheckboxListTile(
          title: Text(
            food['foodName'],
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            "Quantity: ${food['quantity']}",
            style: TextStyle(color: Colors.black),
          ),
          value: selectedItems[food['foodId']] ?? false,
          onChanged: (bool? value) {
            setState(() {
              selectedItems[food['foodId']] = value ?? false;
            });
            updateProgress();
          },
        );
      },
    );
  }

  Widget _buildTopDesign() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(100),
              bottomRight: Radius.circular(100),
            ),
          ),
        ),
        Positioned(
          top: 40,
          child: Text(
            "Your child needs\n"
            "Protein: ${Protein ?? 'N/A'}\n"
    "Fiber: ${Fiber ?? 'N/A'}\n"
    "Fat: ${Fat ?? 'N/A'}\n"
    "Carbs: ${Carbohydrates ?? 'N/A'}",


    style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
