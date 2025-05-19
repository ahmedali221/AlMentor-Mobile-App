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
    this.isArabic = true,
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
    final List<String> expertiseAreas =
        isArabic ? instructor.expertiseAr : instructor.expertiseEn;
    final String profilePicture = user.profilePicture;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: 170,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Instructor Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: profilePicture.startsWith('http')
                  ? Image.network(
                      profilePicture,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 110,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 50),
                      ),
                    )
                  : Image.asset(
                      profilePicture,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 110,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 50),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Instructor Name
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Professional Title
                  Text(
                    professionalTitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Expertise Areas Chips
                  if (expertiseAreas.isNotEmpty)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: expertiseAreas
                          .take(2)
                          .map((area) => Chip(
                                label: Text(
                                  area,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
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

class HorizontalInstructorList extends StatefulWidget {
  final List<Instructor> instructors;
  final String? title;
  final String? description;
  final Function(Instructor)? onInstructorTap;

  const HorizontalInstructorList({
    super.key,
    required this.instructors,
    this.title,
    this.description,
    this.onInstructorTap,
  });

  @override
  State<HorizontalInstructorList> createState() =>
      _HorizontalInstructorListState();
}

class _HorizontalInstructorListState extends State<HorizontalInstructorList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Description
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: const [
                        Text(
                          'عرض الكل',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                  Text(
                    widget.title!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

          if (widget.description != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.description!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 14),
                textAlign: TextAlign.right,
              ),
            ),

          const SizedBox(height: 16),

          // Instructor Cards
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: widget.instructors.length,
              itemBuilder: (context, index) {
                final delay = 100 * index;
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final animationValue = _controller.value;
                    final shouldShow = animationValue > (index * 0.08);
                    return AnimatedOpacity(
                      opacity: shouldShow ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: Transform.translate(
                        offset: Offset(shouldShow ? 0 : 40, 0),
                        child: InstructorCard(
                          instructor: widget.instructors[index],
                          onTap: widget.onInstructorTap != null
                              ? () => widget
                                  .onInstructorTap!(widget.instructors[index])
                              : null,
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
    );
  }
}
