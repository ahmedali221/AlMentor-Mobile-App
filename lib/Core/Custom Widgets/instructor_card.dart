import 'package:flutter/material.dart';
import '../../models/instructor.dart';

class InstructorCard extends StatelessWidget {
  final Instructor instructor;
  final VoidCallback? onTap;
  final bool isArabic;

  const InstructorCard({
    super.key,
    required this.instructor,
    this.onTap,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    final user = instructor.user;
    final String name = isArabic
        ? '${user.firstNameAr} ${user.lastNameAr}'
        : '${user.firstNameEn} ${user.lastNameEn}';
    final String professionalTitle = isArabic
        ? instructor.professionalTitleAr
        : instructor.professionalTitleEn;
    final String profilePicture = user.profilePicture;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Instructor Image with circular avatar
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage: profilePicture.startsWith('http')
                    ? NetworkImage(profilePicture) as ImageProvider
                    : AssetImage(profilePicture),
                child: profilePicture.isEmpty
                    ? Icon(Icons.person, size: 40, color: Colors.grey[500])
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Instructor Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Professional Title
                  Text(
                    professionalTitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Rating and courses count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
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

class HorizontalInstructorList extends StatelessWidget {
  final List<Instructor> instructors;
  final String? title;
  final String? seeAllText;
  final Function(Instructor)? onInstructorTap;
  final bool isArabic;

  const HorizontalInstructorList({
    super.key,
    required this.instructors,
    this.title,
    this.seeAllText,
    this.onInstructorTap,
    this.isArabic = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and See All
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (seeAllText != null)
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: Row(
                      children: [
                        Text(
                          seeAllText!,
                          style: const TextStyle(
                            color: Color(0xFF00A0E3),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Color(0xFF00A0E3),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Instructor Cards
        SizedBox(
          height: 200, // Reduced height to match almentor style
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: instructors.length,
            itemBuilder: (context, index) {
              return InstructorCard(
                instructor: instructors[index],
                onTap: onInstructorTap != null
                    ? () => onInstructorTap!(instructors[index])
                    : null,
                isArabic: isArabic,
              );
            },
          ),
        ),
      ],
    );
  }
}
