
import 'package:client/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:client/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String converHash(String password) {
  final bytes = utf8.encode(password); // 비밀번호와 유니크 키를 바이트로 변환
  final hash = sha256.convert(bytes); // 비밀번호를 sha256을 통해 해시 코드로 변환
  return hash.toString();
}
void main() async {
  await dotenv.load(fileName: ".env");


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _login() {
    String username = _usernameController.text;
    String password = converHash(_passwordController.text);

    // Perform login logic here
    // For simplicity, let's just print the credentials for now
    print("Username: $username");
    print("Password: $password");
  }

  Future<void> trylogin() async {
    final String url = 'http://172.10.7.78:80/login';

    final Map<String, dynamic> data = {
      'id': _usernameController.text,
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
        print('login 성공');
        print('Response: ${response.body}');
      } else {
        print('Failed to send data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // appBar: AppBar(
      //   title: Text('Login Page'),
      // ),
      backgroundColor: Color(0xFFF0E3D0),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 100),
            Image.asset(
              'assets/logo_vertical.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'UserId'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: trylogin,
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF927E63), // Change this to the desired color
                fixedSize:
                    Size(200, 50), // Set the width and height of the button
              ),
              child: Text('로그인',
                  style: TextStyle(
                    color: Colors.white, // Text color of the button
                  )),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('아직 회원이 아니신가요?'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignIn()),
                    );
                  },
                  child: Text(
                    '회원가입',
                    style: TextStyle(
                      color: Color(0xFF6D5736),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "main",
      home: MainPage(),
    );
  }
}
