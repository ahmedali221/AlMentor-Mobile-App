import 'package:almentor_clone/Core/Constants/apiConstants.dart';
import 'package:almentor_clone/pages/categories/categoryCourses.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Core/Providers/themeProvider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> categories = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // List of possible colors for categories
  final List<Color> _categoryColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.red,
    Colors.indigo,
    Colors.pink,
  ];

  // List of possible icons for categories
  final List<IconData> _categoryIcons = [
    Icons.code,
    Icons.design_services,
    Icons.business,
    Icons.language,
    Icons.science,
    Icons.music_note,
    Icons.fitness_center,
    Icons.psychology,
    Icons.agriculture,
    Icons.engineering,
    Icons.medical_services,
    Icons.account_balance,
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _searchQuery = _controller.text.trim();
      });
    });
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:5000/api/category'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] is List) {
          setState(() {
            categories =
                (data['data'] as List).map<Map<String, dynamic>>((category) {
              final id = category['_id'] ?? '';
              final name = category['name']?['en'] ??
                  category['name']?['en'] ??
                  'Unknown';
              final randomColor =
                  _categoryColors[id.hashCode.abs() % _categoryColors.length];
              final randomIcon =
                  _categoryIcons[id.hashCode.abs() % _categoryIcons.length];

              return {
                'title': name,
                'color': randomColor,
                'icon': randomIcon,
                'route': '/category/$id',
              };
            }).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Invalid data format from server.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load categories: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching categories: $e';
      });
    }
  }

  // Filtered categories based on search query
  List<Map<String, dynamic>> get _filteredCategories {
    if (_searchQuery.isEmpty) {
      return categories;
    }
    return categories
        .where((cat) => (cat['title'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          Align(
            alignment: Alignment.center,
            child: Text("Explore Categories",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                )),
          ),
          SizedBox(
            height: 12,
          ),
          // Search bar
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {}, // No need for onTap, search is live
                  child: Icon(Icons.search, color: Theme.of(context).hintColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'What do you want to learn?',
                      hintStyle: TextStyle(
                          color: Theme.of(context).hintColor, fontSize: 16),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading or error or content
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage.isNotEmpty)
            Center(
              child: Text(
                _errorMessage,
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha((0.7 * 255).toInt()),
                ),
              ),
            )
          else if (_filteredCategories.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No Results found',
                  style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withAlpha((0.7 * 255).toInt()),
                      fontSize: 18),
                ),
              ),
            )
          else
            GridView.builder(
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
                    final categoryId = cat['route'].toString().split('/').last;

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CategoryCourses(
                          categoryId: categoryId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
        ],
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
