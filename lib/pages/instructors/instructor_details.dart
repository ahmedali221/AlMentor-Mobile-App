import 'package:flutter/material.dart';
import '../../models/instructor.dart';

class InstructorDetailsPage extends StatelessWidget {
  final Instructor instructor;

  const InstructorDetailsPage({
    super.key,
    required this.instructor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${instructor.firstName} ${instructor.lastName}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with profile picture
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  instructor.profilePicture.isNotEmpty
                      ? CircleAvatar(
                          radius: 75,
                          backgroundImage:
                              NetworkImage(instructor.profilePicture),
                          onBackgroundImageError: (e, s) =>
                              const Icon(Icons.person),
                        )
                      : CircleAvatar(
                          radius: 75,
                          backgroundColor: const Color(0xFFeb2027),
                          child: Text(
                            '${instructor.firstName[0]}${instructor.lastName[0]}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  Text(
                    '${instructor.firstName} ${instructor.lastName}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    instructor.professionalTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Expertise Areas
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expertise Areas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: instructor.expertiseAreas.map((area) {
                      return Chip(
                        label: Text(area),
                        backgroundColor:
                            const Color(0xFFeb2027).withOpacity(0.1),
                        labelStyle: const TextStyle(color: Color(0xFFeb2027)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Biography
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Biography',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    instructor.biography,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Color.fromARGB(255, 105, 104, 104),
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
}
