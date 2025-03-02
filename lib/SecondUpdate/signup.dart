import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'login.dart';

class Signing extends StatefulWidget {
  const Signing({super.key});

  @override
  State<Signing> createState() => _SigningState();
}

class _SigningState extends State<Signing> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _parentController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  TextEditingController _createdbyController=TextEditingController();
  String? mobileNumber;
  var userList=[];
  Future<void> createUser() async {
    try {
      var response = await http.post(
        Uri.parse("http://92.205.109.210:8026/api/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "parentsname": _parentController.text,
          "mobileno": _mobileController.text,
          "pwd": _passwordController.text,
          "createdBy":_createdbyController.text

        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User registered Successfully"),
            backgroundColor: Colors.green ,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Loggingin()),
        );
        setState(() {
          _parentController.clear();
          _mobileController.clear();
          _passwordController.clear();

        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to Register"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  _buildTextField(Icons.person, "Parent's Name",_parentController),
                  SizedBox(height: 15),
                  _buildTextField(Icons.phone, "Mobile",_mobileController),
                  SizedBox(height: 15),
                  _buildTextField(Icons.vpn_key, "Password", _passwordController,obscureText: true),
                  SizedBox(height: 20),
                  _buildTextField(Icons.person, "CreatedBy", _createdbyController),
                  SizedBox(height: 20),
                  _buildGradientButton("CREATE AN ACCOUNT", () {
                      if(_formKey.currentState!.validate()){
                        createUser();
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please Enter All the required fields"),
                            backgroundColor: Colors.red));
                      }
                  }),
                  SizedBox(height: 30),
                  _buildBottomText("ALREADY HAVE AN ACCOUNT?", "SIGN IN", () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// ✅ Gradient Button
  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed:onPressed,
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

// ✅ Text Fields with Icons
  Widget _buildTextField(IconData icon, String hint,TextEditingController controller, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.pink),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter  $hint';
          }
          // Ensure no alphabet or special characters and length of 10 digits
          else if (hint == "Mobile Number") {
            if (value.length != 10) {
              return 'Mobile Number must be 10 digits';
            }
            // Check for non-numeric characters
            else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
              return 'Only numeric values are allowed';
            }
          }
          else if (hint == "Password" && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
        }
    );
  }

// ✅ Bottom Navigation Text
  Widget _buildBottomText(String text, String actionText, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: TextStyle(color: Colors.black54)),
        SizedBox(width: 5),
        GestureDetector(
          onTap: onTap,
          child: Text(actionText, style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

// ✅ Top Circular Design
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
            "My Child's Diet",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}