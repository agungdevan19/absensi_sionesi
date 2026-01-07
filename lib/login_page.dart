import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import 'attendance_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');

    if (savedEmail == null || savedPassword == null) {
      showPopup(
        "Login Gagal",
        "Akun belum terdaftar, silakan register terlebih dahulu",
        true,
      );
      return;
    }

    if (emailController.text.trim() == savedEmail &&
        passwordController.text.trim() == savedPassword) {

      //(USER YANG SEDANG LOGIN)
      await prefs.setString(
        'current_user',
        emailController.text.trim(),
      );

      emailController.clear();
      passwordController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AttendancePage()),
      );
    } else {
      showPopup("Login Gagal", "Email atau password salah", true);
    }
  }


  void showPopup(String title, String message, bool isError) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: isError ? Colors.red : const Color(0xFF044D30),
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F9F3),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "LOGIN",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF044D30),
                  ),
                ),
                const SizedBox(height: 30),

                /// EMAIL
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Email tidak boleh kosong" : null,
                ),

                const SizedBox(height: 16),

                /// PASSWORD
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Password tidak boleh kosong" : null,
                ),

                const SizedBox(height: 24),

                /// LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF044D30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: login,
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                      ),
                  ),
                ),

                const SizedBox(height: 12),

                /// REGISTER BUTTON
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Belum punya akun? Register",
                    style: TextStyle(color: Color(0xFF044D30)),
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
