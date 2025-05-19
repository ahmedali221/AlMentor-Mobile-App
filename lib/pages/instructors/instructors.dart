import 'package:almentor_clone/Core/Custom%20Widgets/instructor_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../models/instructor.dart';
import 'package:almentor_clone/Core/Providers/themeProvider.dart';
import 'instructor_details.dart';

class Instructors extends StatefulWidget {
  const Instructors({super.key});

  @override
  State<Instructors> createState() => _InstructorsState();
}

class _InstructorsState extends State<Instructors> {
  List<Instructor> instructors = [];
  bool isLoading = true;
  int currentPage = 1;
  int itemsPerPage = 6;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInstructors();
  }

  Future<List<Map<String, dynamic>>> fetchInstructors() async {
    final response =
        await http.get(Uri.parse('http://localhost:5000/api/instructors'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // The API returns: { "success": true, "message": "...", "data": [ ... ] }
      if (decoded is Map && decoded['data'] is List) {
        return List<Map<String, dynamic>>.from(decoded['data']);
      }
    }
    throw Exception('Failed to load instructors');
  }

  Future<void> _loadInstructors() async {
    try {
      final data = await fetchInstructors();
      setState(() {
        instructors = data.map((json) => Instructor.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Failed to load instructors');
    }
  }

  List<Instructor> get currentInstructors {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return instructors.sublist(
      startIndex,
      endIndex > instructors.length ? instructors.length : endIndex,
    );
  }

  int get totalPages => (instructors.length / itemsPerPage).ceil();

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // Instructors Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    padding: const EdgeInsets.all(16),
                    itemCount: currentInstructors.length,
                    itemBuilder: (context, index) {
                      return InstructorCard(
                        instructor: currentInstructors[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InstructorDetailsPage(
                                instructor: currentInstructors[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Pagination
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: currentPage > 1
                              ? () => changePage(currentPage - 1)
                              : null,
                        ),
                        for (int i = 1; i <= totalPages; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => changePage(i),
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: i == currentPage
                                    ? Colors.red
                                    : Colors.grey[300],
                                child: Text(
                                  '$i',
                                  style: TextStyle(
                                    color: i == currentPage
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: currentPage < totalPages
                              ? () => changePage(currentPage + 1)
                              : null,
                        ),
                      ],
                    ),
                  ),

                  // Become Instructor Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/instructor_bg.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black54,
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'How To Become an Instructor?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'And teach people all around the MENA region?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: const Text(
                            'Apply Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
