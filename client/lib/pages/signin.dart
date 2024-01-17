import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

String converHash(String password) {
  final bytes = utf8.encode(password); // 비밀번호와 유니크 키를 바이트로 변환
  final hash = sha256.convert(bytes); // 비밀번호를 sha256을 통해 해시 코드로 변환
  return hash.toString();
}

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> sendData() async {
    const String url =
        'http://172.10.7.78:80/signin'; // Replace with your Flask server URL

    final Map<String, dynamic> data = {
      'name': _nameController.text,
      'id': _userIdController.text,
      'pw': converHash(_passwordController.text),
    };
    print('Sending data: $data');
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Data sent successfully');
        print('Response: ${response.body}');
        Navigator.pop(context);
      } else {
        print('Failed to send data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _login() {
    String name = _nameController.text;
    String userId = _userIdController.text;
    String password = _passwordController.text;

    // Perform your login logic here
    print("Name: $name");
    print("User ID: $userId");
    print("Password: $password");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // appBar: AppBar(
      //   title: Text('Login Page'),
      // ),
      backgroundColor: const Color(0xFFF0E3D0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 100),
            Image.asset(
              'assets/logo_vertical.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16.0),
            const Text(
              '바로북에 오신걸 환영합니다!',
              style: TextStyle(
                color: Color(0xFF6D5736),
                fontSize: 24.0, // 크기 조절
                fontWeight: FontWeight.bold, // 볼드체
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(labelText: 'User ID'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: sendData,
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(200, 50),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  color: Color(0xFF6D5736),
                  fontWeight: FontWeight.bold, // 볼드체
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
