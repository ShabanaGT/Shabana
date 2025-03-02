import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class AddChild extends StatefulWidget {
    String? parentId;
    AddChild({super.key,required this.parentId});

  @override
  State<AddChild> createState() => _AddChildState();
}

class _AddChildState extends State<AddChild> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController bmiController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  int? selectedGender;


  Future<void> createChild() async {
    try {
      var apiResponse = await http.post(
        Uri.parse("http://92.205.109.210:8026/api/createchild"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "age": int.parse(ageController.text),
          "gender": selectedGender == 0 ? "male" : "female",
          "weight": weightController.text,
          "bmi": bmiController.text,
          "userid":widget.parentId.toString(),
        }),
      );

      var bodyData = jsonDecode(apiResponse.body);
      print(bodyData["message"]);
      print(apiResponse.statusCode);
      print(widget.parentId);


      if (apiResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Child Created Successfully",style: TextStyle(color: Colors.black),),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to add child"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
    setState(() {
      nameController.clear();
      ageController.clear();

      heightController.clear();
      weightController.clear();
      bmiController.clear();

    });
  }

  void handlingRadioValue(int? value) {
    setState(() {
      selectedGender = value;
    });
  }

  void updateBmi() {
    if (heightController.text.isNotEmpty && weightController.text.isNotEmpty) {
      try {
        double height = double.parse(heightController.text) / 100;
        double weight = double.parse(weightController.text);

        if (height > 0 && weight > 0) {
          double BMI = weight / (height * height);
          setState(() {
            bmiController.text = BMI.toStringAsFixed(2);
          });
        } else {
          setState(() {
            bmiController.clear();
          });
        }
      } catch (e) {
        setState(() {
          bmiController.clear();
        });
      }
    } else {
      setState(() {
        bmiController.clear();
      });
    }
  }
  final GlobalKey<ScaffoldState> _scaffoldKey=GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    heightController.addListener(updateBmi);
    weightController.addListener(updateBmi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
            "Add Children",
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

          }, icon: Icon(Icons.arrow_back))

      ),


      body: Container(
        width: double.infinity,  // Ensures full width
        height: double.infinity,  // Ensures full height
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,  // Adjust width as needed
            ),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white.withOpacity(0.1), // Slight transparency
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      textField(nameController, "Child Name", TextInputType.text,),
                        SizedBox(height: 10),
                      textField(ageController, "Age", TextInputType.number),
                        SizedBox(height: 10),
                      genderSelection(),
                        SizedBox(height: 10),
                      textField(heightController, "Enter height", TextInputType.number),
                        SizedBox(height: 10),
                      textField(weightController, "Enter weight", TextInputType.number),
                          SizedBox(height: 10),
                      textField(bmiController, "BMI", TextInputType.number, readOnly: true),
                       SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: (){
                          createChild();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        child: const Text("Save", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget textField(TextEditingController controller, String hintText, TextInputType keyboardType, {IconData? icon, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          hintText: hintText,
          prefixIcon: icon != null ? Icon(icon, color: Colors.white54) : null,
          hintStyle: TextStyle(color: Colors.white)
      ),
      style: TextStyle(color: Colors.white),

    );
  }

  Widget genderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Gender", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<int>(
                title: const Text("Male", style: TextStyle(color: Colors.white)),
                value: 0,
                groupValue: selectedGender,
                onChanged: handlingRadioValue,
              ),
            ),
            Expanded(
              child: RadioListTile<int>(
                title: const Text("Female", style: TextStyle(color: Colors.white)),
                value: 1,
                groupValue: selectedGender,
                onChanged: handlingRadioValue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}