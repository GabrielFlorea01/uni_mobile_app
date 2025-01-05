import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CoursesScreen extends StatefulWidget {
  final Function onCoursesUpdated;

  const CoursesScreen({super.key, required this.onCoursesUpdated});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _courseNameController = TextEditingController();

  String? _selectedCourseId;
  double _selectedPercentage = 0.0;

  final List<double> percentageOptions = List.generate(11, (index) => index * 10.0);

  Stream<QuerySnapshot> _coursesStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('courses')
          .where('userId', isEqualTo: user.uid)
          .snapshots();
    } else {
      return Stream.empty();
    }
  }

  String _getStatus(double percentage) {
    if (percentage == 0.0) {
      return "Not started yet";
    } else if (percentage == 100.0) {
      return "Completed";
    } else {
      return "In progress";
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
        final snapshot = await _firestore
            .collection('courses')
            .where('userId', isEqualTo: user.uid)
            .where('courseName', isEqualTo: _courseNameController.text.trim())
            .get();

        if (snapshot.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("A course with this name already exists!")),
          );
          return;
        }

        String status = _getStatus(_selectedPercentage);

        await _firestore.collection('courses').add({
          'courseName': _courseNameController.text.trim(),
          'status': status,
          'percentage': _selectedPercentage,
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        widget.onCoursesUpdated();
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
        String status = _getStatus(_selectedPercentage);
        await _firestore.collection('courses').doc(_selectedCourseId).update({
          'courseName': _courseNameController.text.trim(),
          'status': status,
          'percentage': _selectedPercentage,
        });

        widget.onCoursesUpdated();
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
      widget.onCoursesUpdated();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Course deleted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete course. Please try again.")),
      );
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown date";
    DateTime date = timestamp.toDate();
    return DateFormat('dd-MM-yyyy').format(date);
  }

  void _clearForm() {
    _courseNameController.clear();
    setState(() {
      _selectedCourseId = null;
      _selectedPercentage = 0.0;
    });
  }

  void _onCourseSelected(Map<String, dynamic> course) {
    setState(() {
      _selectedCourseId = course['id'];
      _courseNameController.text = course['courseName'];
      _selectedPercentage = course['percentage'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Courses Manager"),
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
              padding: const EdgeInsets.only(bottom: 20),
              child: DropdownButtonFormField<double>(
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
            ElevatedButton(
              onPressed: _selectedCourseId != null ? _updateCourse : _addCourse,
              child: Text(_selectedCourseId != null ? "Update Course" : "Add Course"),
            ),
            SizedBox(height: 20),
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
                    return Center(child: Text("No courses found."));
                  }

                  var courses = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return {
                      'id': doc.id,
                      'courseName': data['courseName'],
                      'status': data['status'],
                      'percentage': (data['percentage'] as num).toDouble(),
                      'createdAt': data['createdAt'],
                    };
                  }).toList();

                  return ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          title: Text(
                            course['courseName'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(course['status']),
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