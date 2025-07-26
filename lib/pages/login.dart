import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:orbitsproject/pages/dashboard.dart';
import '../utils/error_logger.dart'; // ✅ Import your error logger

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  String selectedRole = 'client'; // Default selection

  Future<void> loginUser() async {
    final String apiUrl = "http://13.203.214.225:3000/login";

    final Map<String, dynamic> requestBody = {
      "flag": selectedRole,
      selectedRole == "client" ? "clientinput" : "userinput": {
        "username": usernameController.text,
        "password": passwordController.text,
      },
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];

        final responseData =
            contentType != null && contentType.contains('application/json')
                ? jsonDecode(response.body)
                : response.body;

        if (responseData == "Invalid Password" ||
            responseData == "Invalid Username") {
          setState(() {
            errorMessage = responseData;
          });
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('username', usernameController.text.trim());
          await prefs.setString('password', passwordController.text.trim());

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage()),
          );
        }
      } else {
        setState(() {
          errorMessage = "Server Error. Try again!";
        });

        // ✅ Log server error
        await ErrorLogger.logError(
          'Server responded with status: ${response.statusCode}',
          response.body,
          'N/A',
        );
      }
    } catch (e, stackTrace) {
      await ErrorLogger.logError(
        'Login error',
        e.toString(),
        stackTrace.toString(),
      );

      setState(() {
        errorMessage = "Network Error. Check your connection.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Sign in", style: TextStyle(fontSize: 28)),
                const SizedBox(height: 20),

                // Dropdown for Role Selection
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: "client", child: Text("Client")),
                    DropdownMenuItem(value: "admin", child: Text("Admin")),
                  ],
                  decoration: InputDecoration(
                    labelText: "Select Role",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                if (errorMessage.isNotEmpty)
                  Text(errorMessage, style: const TextStyle(color: Colors.red)),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
