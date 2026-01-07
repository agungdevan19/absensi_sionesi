import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmController.text) {
      showPopup("Registrasi Gagal", "Password tidak sama", true);
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // SIMPAN KE INTERNAL STORAGE
    await prefs.setString('email', emailController.text.trim());
    await prefs.setString('password', passwordController.text.trim());

    showPopup("Registrasi Berhasil", "Akun berhasil dibuat", false);

    // RESET FIELD
    emailController.clear();
    passwordController.clear();
    confirmController.clear();

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    });

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
      resizeToAvoidBottomInset: true, // ✅ FIX 1
      backgroundColor: const Color(0xFFE9F9F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF044D30),
        title: const Text("Register"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView( // ✅ FIX 2
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100), // ✅ FIX 3
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "REGISTER",
                  style: TextStyle(
                    fontSize: 26,
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

                const SizedBox(height: 16),

                /// CONFIRM PASSWORD
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Konfirmasi Password",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Konfirmasi password wajib diisi" : null,
                ),

                const SizedBox(height: 24),

                /// REGISTER BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF044D30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: register,
                    child: const Text(
                      "Register",
                      style: TextStyle(color: Colors.white),
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
