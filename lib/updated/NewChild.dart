import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login.dart';





class AddnewChild extends StatefulWidget {
  String? parentId;
  AddnewChild({super.key,required this.parentId});

  @override
  State<AddnewChild> createState() => _AddnewChildState();
}

class _AddnewChildState extends State<AddnewChild> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController bmiController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  int? selectedGender;
  Map<String,dynamic>  bodyData={};
  List<dynamic> childList=[];
  Map<String,dynamic> newChild={};


  Future<void> createChild() async {
    try {
      // Ensure all fields are valid
      int? age = int.tryParse(ageController.text);
      if (age == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid age")),
        );
        return;
      }

      double? weight = double.tryParse(weightController.text);
      double? bmi = double.tryParse(bmiController.text);
      if (weight == null || bmi == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter valid weight and BMI")),
        );
        return;
      }

      var apiResponse = await http.post(
        Uri.parse("http://92.205.109.210:8026/api/createchild"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "age": age,
          "gender": selectedGender == 0 ? "male" : "female",
          "weight": weight,
          "bmi": bmi,
          "userid": widget.parentId.toString(),
        }),
      );

      var bodyData = jsonDecode(apiResponse.body);
      print(bodyData["message"]);
      print(apiResponse.statusCode);
      print(widget.parentId);

      if (apiResponse.statusCode == 201) {
        bodyData=jsonDecode(apiResponse.body);
        newChild=bodyData["data"];
        Navigator.pop(context,newChild);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Child Created Successfully", style: TextStyle(color: Colors.black)),
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
        body: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTopDesign(),
                      SizedBox(height: 30),
                      _buildTextField(  "Child's Name",nameController),
                      SizedBox(height: 15),

                      _buildTextField(  "Age",ageController),
                      SizedBox(height: 15),
                      genderSelection(),
                      _buildTextField( "Height", heightController),
                      SizedBox(height: 20),
                      _buildTextField(  "Weight", weightController),
                      SizedBox(height: 20),
                      _buildTextField("BMI", bmiController,),
                      _buildGradientButton("CREATE AN ACCOUNT", (){
                          if(_formKey.currentState!.validate()){
                            createChild();
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please Enter All the required fields"),
                                backgroundColor: Colors.red));
                          }
                      }),

                    ],
                  ),
                ),
              ),
            )
        )
    );
  }


  Widget _buildTextField(String hint, TextEditingController controller, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: hint == "Age" || hint == "Height" || hint == "Weight"
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a valid $hint';
        }

        if (hint == "Mobile Number") {
          if (value.length != 10) return 'Mobile Number must be 10 digits';
          if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Only numeric values are allowed';
        }

        if (hint == "Age" && !RegExp(r'^[0-9]+$').hasMatch(value)) {
          return "Please enter a valid age";
        }

        if (hint == "Height") {
          double? height = double.tryParse(value);
          if (height == null || height <= 0) return "Please enter a valid height";
        }

        if (hint == "Weight") {
          double? weight = double.tryParse(value);
          if (weight == null || weight <= 0) return "Please enter a valid weight";
        }

        if (hint == "Password" && value.length < 6) {
          return 'Password must be at least 6 characters';
        }

        return null; // Return null if the input is valid
      },
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
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

  Widget _buildTopDesign() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(100),
              bottomRight: Radius.circular(100),
            ),
          ),
        ),
        Positioned(
          top: 60,

          child: Text(
            "Add Your Child Here!!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}




