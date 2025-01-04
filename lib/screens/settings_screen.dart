import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:uni_mobile_app/authentication/login_page.dart';
import 'package:uni_mobile_app/theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isLoggingOut = false;

  void _logout(BuildContext context) async {
    setState(() {
      isLoggingOut = true;
    });


    await Future.delayed(Duration(seconds: 1));

    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );

    setState(() {
      isLoggingOut = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Theme",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: SwitchListTile(
                title: Text(
                  "Dark Mode",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (bool value) {
                  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                  themeProvider.setTheme(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: isLoggingOut ? null : () => _logout(context),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isLoggingOut
                          ? CircularProgressIndicator()
                          : Icon(Icons.logout, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        isLoggingOut ? "Logging out..." : "Log Out",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}