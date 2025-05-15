import 'package:flutter/material.dart';

// Model for each category
class CategoryItem {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final Color color;

  CategoryItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.color,
  });
}

// Main Widget
class CategoryButtonWidget extends StatefulWidget {
  const CategoryButtonWidget({super.key});

  @override
  _CategoryButtonWidgetState createState() => _CategoryButtonWidgetState();
}

class _CategoryButtonWidgetState extends State<CategoryButtonWidget> {
  // List of category items
  final List<CategoryItem> categories = [
    CategoryItem(
      title: 'المهارات المهنية والأعمال',
      icon: Icons.work_outline,
      activeIcon: Icons.work,
      color: Colors.blue,
    ),
    CategoryItem(
      title: 'دورات أكاديمية للطلاب وهيئة التدريس',
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
      color: Colors.blue,
    ),
    CategoryItem(
      title: 'دورة تقنية',
      icon: Icons.computer_outlined,
      activeIcon: Icons.computer,
      color: Colors.blue,
    ),
    CategoryItem(
      title: 'دورات تدريبية',
      icon: Icons.note_add_outlined,
      activeIcon: Icons.note_add,
      color: Colors.blue,
    ),
    CategoryItem(
      title: 'إدارة الوقت',
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer,
      color: Colors.blue,
    ),
    CategoryItem(
      title: 'التواصل الفعال',
      icon: Icons.chat_outlined,
      activeIcon: Icons.chat,
      color: Colors.blue,
    ),
  ];

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final double availableHeight = MediaQuery.of(context).size.height * 0.3;
    const double buttonHeight = 70;
    const double spacing = 12;

    final int buttonsPerPage = (availableHeight / (buttonHeight + spacing))
        .floor()
        .clamp(1, categories.length);

    // Split the list into chunks of buttonsPerPage
    final List<List<CategoryItem>> pages = [];
    for (int i = 0; i < categories.length; i += buttonsPerPage) {
      pages.add(
        categories.sublist(i, (i + buttonsPerPage).clamp(0, categories.length)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'الفئات',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        // PageView with vertical buttons
        SizedBox(
          height: (buttonHeight + spacing) * buttonsPerPage,
          child: PageView.builder(
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, pageIndex) {
              final pageItems = pages[pageIndex];
              // Split into two rows
              final int half = (pageItems.length / 2).ceil();
              final firstRow = pageItems.sublist(0, half);
              final secondRow = pageItems.sublist(half);

              Widget buildButton(CategoryItem item) {
                final int itemIndex = categories.indexOf(item);
                final bool isActive =
                    (_currentPage * buttonsPerPage <= itemIndex &&
                        itemIndex < (_currentPage + 1) * buttonsPerPage);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentPage = pageIndex;
                    });
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? item.color.withOpacity(0.15)
                          : Colors.black,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isActive ? item.color : Colors.grey.shade800,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive ? item.color : Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.title,
                          style: TextStyle(
                            color: isActive ? item.color : Colors.white,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: firstRow.map(buildButton).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: secondRow.map(buildButton).toList(),
                  ),
                ],
              );
            },
          ),
        ),

        // Page indicator
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.blue
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Example usage
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.black,
      ),
      body: const CategoryButtonWidget(),
    );
  }
}