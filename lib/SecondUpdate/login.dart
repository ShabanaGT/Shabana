import 'package:diet_app/SecondUpdate/signup.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ListOfChild.dart';



class Loggingin extends StatefulWidget {
  const Loggingin({super.key});

  @override
  State<Loggingin> createState() => _LogginginState();
}
// 🎨 Common UI Colors
const Color primaryColor = Color(0xFFEC4899);
const Color secondaryColor = Color(0xFF8B5CF6);

/// 📌 Sign In Page
class _LogginginState extends State<Loggingin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? mobileNumber;
  var userList = [];

  Future<void> login() async {
    try {
      var response = await http.post(
        Uri.parse("http://92.205.109.210:8026/api/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mobileno": _mobileController.text,
          "pwd": _passwordController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var bodyData = jsonDecode(response.body);

        // Extract the user data from the response
        var userData = bodyData["data"];

        // Get the userId from the response data
        String userId = userData["userid"];

        // Display a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(bodyData["message"]),
              backgroundColor: Colors.greenAccent),
        );

        print(response.statusCode);
        print("User ID: $userId");

        // Navigate to the home page and pass the userId
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ListofChildren(userId: userId)),
        );
      } else {
        print("Error ${response.statusCode}: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${response.statusCode}"),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network Error: Unable to reach server"),
            backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  _buildTextField(Icons.phone, "Mobile",_mobileController,obscureText: false),
                  SizedBox(height: 15),
                  _buildTextField(Icons.vpn_key, "Password",_passwordController, obscureText: true),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "FORGOT PASSWORD?",
                      style: TextStyle(
                          color: Colors.pink, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildGradientButton("SIGN IN", () {
                    if(_formKey.currentState!.validate()){
                      login();
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please Enter All the required fields"),
                          backgroundColor: Colors.red));
                    }
                  }),
                  SizedBox(height: 20),
                  _buildBottomText("DON'T HAVE AN ACCOUNT?", "SIGN UP", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Signing()),
                    );
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

// ✅ Text Fields with Icons
  Widget _buildTextField(IconData icon, String hint,TextEditingController controller,
      {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.pink),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a  $hint';
        }
        // Ensure no alphabet or special characters and length of 10 digits
        else  if (hint == "Mobile Number") {
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
        return null;
      },
      onChanged: (value) {
        setState(() {
          mobileNumber = value;
        });
      },
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
          child: Text(actionText, style: TextStyle(
              color: Colors.pink, fontWeight: FontWeight.bold)),
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
            "Login Here!!",
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}