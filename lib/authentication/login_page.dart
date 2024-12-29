import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';
import 'package:uni_mobile_app/screens/home_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
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
      errorMessage = null;
    });

    setState(() {
      isLoading = true;
    });

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
      String message = 'An unexpected error occurred. Please try again later.';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            message = "Oops! We couldn't find an account with this email. Please check and try again.";
            break;
          case 'wrong-password':
            message = "The password entered is incorrect. Please try again.";
            break;
          case 'invalid-email':
            message = "The email address seems to be invalid. Please use a valid email.";
            break;
          case 'too-many-requests':
            message = "Too many attempts! Please wait a while and try again.";
            break;
          case 'email-already-in-use':
            message = "This email is already registered. Please try logging in or use a different email.";
            break;
          case 'operation-not-allowed':
            message = "This sign-in method is currently disabled. Please contact support.";
            break;
          default:
            message = "Something went wrong. Please try again later.";
        }
      } else {
        message = "An unexpected error occurred. Please check your connection and try again.";
      }

      setState(() {
        errorMessage = message;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void resetPassword() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        errorMessage = "Please enter your email to reset your password.";
      });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
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
              SizedBox(height: 10),

              TextButton(
                onPressed: switchToResetPasswordMode,
                child: Text("Forgot your password? Reset here"),
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
    );
  }
}