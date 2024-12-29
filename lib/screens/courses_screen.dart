import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CoursesScreen extends StatefulWidget {
  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _courseNameController = TextEditingController();

  List<Map<String, dynamic>> courses = [];
  String? _selectedCourseId;
  String _selectedStatus = "Not started yet";
  int _selectedPercentage = 10;

  final List<String> statusOptions = ["Not started yet", "In progress", "Completed"];
  final List<int> percentageOptions = List.generate(10, (index) => (index + 1) * 10);

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  void _fetchCourses() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('courses')
            .where('userId', isEqualTo: user.uid)
            .get();

        setState(() {
          courses = snapshot.docs.map((doc) {
            var data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching courses: $e")),
      );
    }
  }

  void _addCourse() async {
    if (_courseNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Course name is required!")),
      );
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('courses').add({
          'courseName': _courseNameController.text.trim(),
          'status': _selectedStatus,
          'percentage': _selectedPercentage,
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _fetchCourses();
        _clearForm();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Course added successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add course. Please try again.")),
      );
    }
  }

  void _updateCourse() async {
    if (_selectedCourseId != null) {
      try {
        await _firestore.collection('courses').doc(_selectedCourseId).update({
          'courseName': _courseNameController.text.trim(),
          'status': _selectedStatus,
          'percentage': _selectedPercentage,
        });

        _fetchCourses();
        _clearForm();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Course updated successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update course. Please try again.")),
        );
      }
    }
  }

  void _deleteCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete();
      _fetchCourses();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Course deleted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete course. Please try again.")),
      );
    }
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('dd-MM-yyyy').format(date);
  }

  void _clearForm() {
    _courseNameController.clear();
    setState(() {
      _selectedCourseId = null;
      _selectedStatus = "Not started yet";
      _selectedPercentage = 10;
    });
  }

  void _onCourseSelected(Map<String, dynamic> course) {
    setState(() {
      _selectedCourseId = course['id'];
      _courseNameController.text = course['courseName'];
      _selectedStatus = course['status'];
      _selectedPercentage = course['percentage'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Courses"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _courseNameController,
                decoration: InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
                items: statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: DropdownButtonFormField<int>(
                value: _selectedPercentage,
                onChanged: (newValue) {
                  setState(() {
                    _selectedPercentage = newValue!;
                  });
                },
                items: percentageOptions.map((percentage) {
                  return DropdownMenuItem(
                    value: percentage,
                    child: Text("$percentage%"),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Percentage (%)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
            ),

            if (_selectedCourseId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "Created At: ${_formatDate(Timestamp.fromMillisecondsSinceEpoch(courses.firstWhere((course) => course['id'] == _selectedCourseId)['createdAt'].millisecondsSinceEpoch))}",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),

            ElevatedButton(
              onPressed: _selectedCourseId != null ? _updateCourse : _addCourse,
              child: Text(_selectedCourseId != null ? "Update Course" : "Add Course"),
            ),

            SizedBox(height: 20),

            Expanded(
              child: courses.isEmpty
                  ? Center(child: Text("No courses found."))
                  : ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            title: Text(course['courseName'] ?? 'No Name', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(course['status'] ?? 'No Status'),
                                SizedBox(height: 5),
                                Text(
                                  "Progress: ${course['percentage']}%",
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Course added on: ${_formatDate(course['createdAt'])}",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            onTap: () => _onCourseSelected(course),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteCourse(course['id']),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}