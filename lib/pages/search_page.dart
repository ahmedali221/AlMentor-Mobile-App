import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  String _searchQuery = '';

  // List of categories (title, color, icon, route)
  final List<Map<String, dynamic>> categories = [
    {
      'title': 'المهارات المهنية والأعمال',
      'color': const Color(0xFFe08b2f),
      'icon': Icons.work_outline,
      'route': '/business',
    },
    {
      'title': 'التكنولوجيا والتطوير',
      'color': const Color(0xFF1769aa),
      'icon': Icons.science_outlined,
      'route': '/technology',
    },
    {
      'title': 'الصحة النفسية والجسدية',
      'color': const Color(0xFF1769aa),
      'icon': Icons.favorite_border,
      'route': '/health',
    },
    {
      'title': 'الفنون، التصميم والإعلام',
      'color': const Color(0xFFc94a2f),
      'icon': Icons.palette_outlined,
      'route': '/arts',
    },
    {
      'title': 'دورات أكاديمية للطلاب وهيئة التدريس',
      'color': const Color(0xFF4e9c3e),
      'icon': Icons.edit_outlined,
      'route': '/academic',
    },
    {
      'title': 'تنمية أسلوب الحياة',
      'color': const Color(0xFFe08b2f),
      'icon': Icons.favorite,
      'route': '/lifestyle',
    },
    {
      'title': 'لغات',
      'color': const Color(0xFF2a3b8f),
      'icon': Icons.language,
      'route': '/languages',
    },
    {
      'title': 'الأسرة والعلاقات',
      'color': const Color(0xFF4e9c3e),
      'icon': Icons.favorite,
      'route': '/family',
    },
    {
      'title': 'العلوم الإنسانية',
      'color': const Color(0xFF2a3b8f),
      'icon': Icons.psychology_outlined,
      'route': '/humanities',
    },
    {
      'title': 'المهارات الشخصية',
      'color': const Color(0xFF2a3b8f),
      'icon': Icons.person_outline,
      'route': '/personal',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _searchQuery = _controller.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCategories {
    if (_searchQuery.isEmpty) return categories;
    return categories
        .where((cat) => cat['title'].toString().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'البحث',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {}, // No need for onTap, search is live
                  child: const Icon(Icons.search, color: Colors.white54),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      hintText: 'ماذا تود أن تتعلم؟',
                      hintStyle: TextStyle(color: Colors.white54, fontSize: 16),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Category grid
          _filteredCategories.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'لا توجد نتائج',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredCategories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.7,
                  ),
                  itemBuilder: (context, index) {
                    final cat = _filteredCategories[index];
                    return _CategoryCard(
                      title: cat['title'] as String,
                      color: cat['color'] as Color,
                      icon: cat['icon'] as IconData,
                      onTap: () {
                        Navigator.pushNamed(context, cat['route'] as String);
                      },
                    );
                  },
                ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: (index) {},
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Stack(
          children: [
            // Icon background
            Positioned(
              left: 12,
              top: 12,
              child: Icon(
                icon,
                color: Colors.white24,
                size: 38,
              ),
            ),
            // Title
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
