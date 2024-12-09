import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_text_field.dart';

class LoginView extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'POS System Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              CustomTextField(
                label: 'Username',
                controller: usernameController,
              ),
              CustomTextField(
                label: 'Password',
                controller: passwordController,
                obscureText: true,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (usernameController.text.isEmpty || 
                      passwordController.text.isEmpty) {
                    Get.snackbar('Error', 'Please fill all fields');
                    return;
                  }
                  
                  bool success = await authController.login(
                    usernameController.text,
                    passwordController.text,
                  );
                  
                  if (success) {
                    Get.offAllNamed('/dashboard');
                  } else {
                    Get.snackbar('Error', 'Invalid credentials');
                  }
                },
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}