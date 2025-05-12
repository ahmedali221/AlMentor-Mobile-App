import 'package:flutter/material.dart';

/// Featured course card - larger card with title and instructor name
class FeaturedCourseCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String instructorName;
  final VoidCallback? onTap;
  final bool isRTL;
  final List<String> tags;

  const FeaturedCourseCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.instructorName,
    this.onTap,
    this.isRTL = true,
    this.tags = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 350,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha:0.3),
                    Colors.black.withValues(alpha:0.7),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment:
                    isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Section
                  Row(
                    mainAxisAlignment: isRTL
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      // Video icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha:0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.videocam,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),

                      // Tags
                      if (tags.isNotEmpty)
                        Row(
                          children: tags.map((tag) => _buildTag(tag)).toList(),
                        ),
                    ],
                  ),

                  // Bottom Section
                  Column(
                    crossAxisAlignment: isRTL
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                        textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      ),

                      const SizedBox(height: 8),

                      // Instructor name
                      Text(
                        instructorName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      ),

                      const SizedBox(height: 16),

                      // View Course Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: onTap,
                          child: const Text(
                            "عرض الدورة",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildTag(String tag) {
    Color bgColor = tag == 'جديد'
        ? Colors.blue
        : tag == 'مجاني'
            ? Colors.lightBlueAccent
            : Colors.red;
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// New course card - smaller card with new badge and support for multiple instructor names
class NewCourseCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final List<String> instructorNames;
  final bool isNew;
  final VoidCallback? onTap;

  const NewCourseCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.instructorNames,
    this.isNew = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with "New" badge if applicable
            Stack(
              children: [
                // Course image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // "New" badge
                if (isNew)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "جديد",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Course info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Course title
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Instructor names
                  Text(
                    instructorNames.join(' - '),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

/// Section Header - "أجدد الدورات التدريبية" with see all button
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // See all button with chevron icon
          InkWell(
            onTap: onSeeAllPressed,
            child: const Row(
              children: [
                Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),

          // Section title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

/// Example of using these components to build the sections
class CourseSections extends StatelessWidget {
  const CourseSections({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Most watched section
            SectionHeader(
              title: "الأعلى مشاهدة",
              onSeeAllPressed: () {},
            ),

            // Featured course card
            FeaturedCourseCard(
              imageUrl: 'assets/images/english_job.jpg',
              title: 'الإنجليزية للحصول على الوظيفة',
              instructorName: 'حنان رضوان',
              onTap: () {},
            ),

            // New courses section
            SectionHeader(
              title: "أجدد الدورات التدريبية",
              onSeeAllPressed: () {},
            ),

            // New courses horizontal list
            SizedBox(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  NewCourseCard(
                    imageUrl: 'assets/images/encryption.jpg',
                    title: 'أساسيات التشفير',
                    instructorNames: ['أحمد البهاوي'],
                    isNew: true,
                    onTap: () {},
                  ),
                  NewCourseCard(
                    imageUrl: 'assets/images/resilience.jpg',
                    title: 'عزز صمودك النفسي في عالم دائم التغير',
                    instructorNames: ['أحمد الأعور', 'نهى زهرة'],
                    isNew: true,
                    onTap: () {},
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
