import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  void _onItemTapped(BuildContext context, int index) {
    onTap(index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/account');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/courses');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/clips');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 4:
      default:
        Navigator.pushReplacementNamed(context, '/');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const selectedColor = Colors.red;
    const unselectedColor = Colors.white;
    const backgroundColor = Colors.black;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      backgroundColor: backgroundColor,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'حسابي',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          label: 'دوراتي',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_outline),
          label: 'Clips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'بحث',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home, color: selectedColor),
          label: 'الرئيسية',
        ),
      ],
    );
  }
}
