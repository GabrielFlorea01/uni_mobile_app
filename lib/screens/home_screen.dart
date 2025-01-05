import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uni_mobile_app/screens/courses_screen.dart';
import 'package:uni_mobile_app/screens/profile_screen.dart';
import 'package:uni_mobile_app/screens/settings_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();

  Stream<QuerySnapshot> _coursesStream() {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    if (_searchQuery.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('courses')
          .where('userId', isEqualTo: userId)
          .where('courseName', isGreaterThanOrEqualTo: _searchQuery)
          .where('courseName', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
          .snapshots();
    }

    return FirebaseFirestore.instance
        .collection('courses')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown date";
    DateTime date = timestamp.toDate();
    return DateFormat('dd-MM-yyyy').format(date);
  }

  void _fetchCourses() {
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoursesScreen(
              onCoursesUpdated: _fetchCourses,
            ),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                focusNode: _searchFocusNode,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search Courses',
                  hintText: 'Enter course name...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _coursesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No courses found",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  var courses = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return {
                      "id": doc.id,
                      "courseName": data['courseName'],
                      "status": data['status'],
                      "percentage": (data['percentage'] as num).toDouble(),
                      "createdAt": data['createdAt'],
                    };
                  }).toList();

                  return ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 3,
                        child: ListTile(
                          title: Text(
                            course["courseName"],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Status: ${course["status"]}\n"
                            "Percentage: ${course["percentage"]}%\n"
                            "Created at: ${_formatDate(course["createdAt"])}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          trailing: Icon(Icons.arrow_forward),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CoursesScreen(
                                  onCoursesUpdated: _fetchCourses,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Course Manager',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}