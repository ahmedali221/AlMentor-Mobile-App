import 'package:flutter/material.dart';
import '../../models/instructor.dart';
import '../../Core/Localization/app_translations.dart';
import '../../Core/Providers/language_provider.dart';
import '../../Core/Providers/themeProvider.dart';
import 'package:provider/provider.dart';

class InstructorCard extends StatelessWidget {
  final Instructor instructor;
  final VoidCallback? onTap;
  final bool isDark;
  final bool isRtl;
  final String locale;

  const InstructorCard({
    super.key,
    required this.instructor,
    required this.isDark,
    required this.isRtl,
    required this.locale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = instructor.user;
    final String name = locale == 'ar'
        ? '${user.firstNameAr} ${user.lastNameAr}'
        : '${user.firstNameEn} ${user.lastNameEn}';
    final String professionalTitle = locale == 'ar'
        ? instructor.professionalTitleAr
        : instructor.professionalTitleEn;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16),
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                backgroundImage: user.profilePicture.startsWith('http')
                    ? NetworkImage(user.profilePicture)
                    : AssetImage(user.profilePicture) as ImageProvider,
                child: user.profilePicture.isEmpty
                    ? Icon(Icons.person,
                        size: 40,
                        color: isDark ? Colors.grey[400] : Colors.grey[500])
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment:
                    isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    professionalTitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      height: 1.4,
                    ),
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment:
                        isRtl ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (isRtl) const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '•',
                        style: TextStyle(
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      if (!isRtl) const Spacer(),
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
  final String? titleKey;
  final String? seeAllKey;
  final Function(Instructor)? onInstructorTap;

  const HorizontalInstructorList({
    super.key,
    required this.instructors,
    this.titleKey,
    this.seeAllKey,
    this.onInstructorTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final locale = languageProvider.currentLocale.languageCode;
    final isRtl = languageProvider.isArabic;

    return Column(
      crossAxisAlignment:
          isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (titleKey != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppTranslations.getText(titleKey!, locale),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (seeAllKey != null)
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: Row(
                      children: [
                        Text(
                          AppTranslations.getText(seeAllKey!, locale),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isRtl ? Icons.arrow_back : Icons.arrow_forward,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: isRtl,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: instructors.length,
            itemBuilder: (context, index) {
              return InstructorCard(
                instructor: instructors[index],
                isDark: isDark,
                isRtl: isRtl,
                locale: locale,
                onTap: onInstructorTap != null
                    ? () => onInstructorTap!(instructors[index])
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
