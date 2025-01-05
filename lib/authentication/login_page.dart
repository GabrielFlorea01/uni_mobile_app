import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';
import 'package:uni_mobile_app/screens/home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool isResetPasswordMode = false;
  String? errorMessage;
  bool isPasswordVisible = false;

  void loginUser() async {
    setState(() {
      isLoading = true;
    });
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete both fields before signing in.")),
      );
      return;
    }
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      String message = "An unexpected error occurred. Please try again later.";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-credential':
            message = "The provided credentials are invalid. Please check the EMAIL and PASSWORD and try again.";
            break;
          default:
            message = "Something went wrong. Please try again later.";
            break;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void resetPassword() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your email to reset your password!")),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent. Check your inbox!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        isResetPasswordMode = false;
      });
    } catch (e) {
      String message = "An error occurred while sending the reset email.";

      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-email') {
          message = "The email address is invalid. Please enter a valid email.";
        } else if (e.code == 'user-not-found') {
          message = "No account found with this email. Please check and try again.";
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void switchToResetPasswordMode() {
    setState(() {
      isResetPasswordMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isResetPasswordMode ? "Reset Password" : "Login")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 600 ? 400 : double.infinity,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/CoursesTrackerIcon.png',
                            height: constraints.maxWidth > 600 ? 150 : 200,
                            width: constraints.maxWidth > 600 ? 150 : 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: constraints.maxWidth > 600 ? 50 : 100),

                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                      if (!isResetPasswordMode) ...[
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            errorText: errorMessage != null && emailController.text.isEmpty
                                ? 'Please enter your email.'
                                : null,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Color.fromARGB(255, 115, 58, 135),
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            errorText: passwordController.text.isEmpty && errorMessage != null
                                ? 'Please enter your password.'
                                : null,
                          ),
                        ),
                        SizedBox(height: 20),
                        isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: loginUser,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 40),
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  textStyle: TextStyle(fontSize: 18),
                                ),
                                child: Text("Login"),
                              ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupPage()),
                            );
                          },
                          child: Text("Don't have an account? Sign up"),
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: switchToResetPasswordMode,
                          child: Text("Forgot your password?"),
                        ),
                      ] else ...[
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Enter your email",
                            border: OutlineInputBorder(),
                            errorText: errorMessage != null && emailController.text.isEmpty
                                ? 'Please enter your email.'
                                : null,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: resetPassword,
                          child: Text("Send Reset Link"),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isResetPasswordMode = false;
                            });
                          },
                          child: Text("Back to Login"),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}