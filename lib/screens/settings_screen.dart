import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

//TO-DO
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Locale _selectedLocale = Locale('en', 'US');

  void _changeTheme(ThemeMode themeMode) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.setTheme(themeMode);
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _selectedLocale = locale;
    });
    // Update locale in the app (using localization packages)
    // You may need to restart the app or use a state management approach here
  }

  void _logout(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: "Log out",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Theme", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: Text("Dark Mode"),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (bool value) {
                _changeTheme(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
            SizedBox(height: 20),
            
            Text("Language", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: Text("English"),
              onTap: () => _changeLanguage(Locale('en', 'US')),
              trailing: _selectedLocale.languageCode == 'en'
                  ? Icon(Icons.check, color: Colors.green)
                  : null,
            ),
            ListTile(
              title: Text("Español"),
              onTap: () => _changeLanguage(Locale('es', 'ES')),
              trailing: _selectedLocale.languageCode == 'es'
                  ? Icon(Icons.check, color: Colors.green)
                  : null,
            ),
            SizedBox(height: 40),
            
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: Icon(Icons.logout),
                label: Text("Log Out"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }
}