import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_input.dart';

class LoginView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'POS Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                CustomInput(
                  label: 'Username',
                  controller: _usernameController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                CustomInput(
                  label: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                Obx(() => ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final success = await authController.login(
                                  _usernameController.text,
                                  _passwordController.text,
                                );
                                if (success) {
                                  Get.offAllNamed('/dashboard');
                                }
                              }
                            },
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: authController.isLoading.value
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Login', style: TextStyle(fontSize: 16)),
                      ),
                    )),
                SizedBox(height: 16),
                Obx(() => authController.error.value.isNotEmpty
                    ? Text(
                        authController.error.value,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      )
                    : SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
