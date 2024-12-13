import 'package:driver/tabPages/home_tab.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  int _selectedIndex = 0;

  onItemClicked(int index) {
    setState(() {
      _selectedIndex = index;
      tabController!.index = _selectedIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTabPage(),
          // EarningsTabPage(),
          // RatingsTabPage(),
          // ProfileTabPage(),
        ],
      ), // TabBarView
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Ratings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        unselectedItemColor: darkTheme ? Colors.black54 : Colors.white54,
        selectedItemColor: darkTheme ? Colors.black : Colors.white,
        backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: onItemClicked,
      ), // BottomNavigationBar
    );
  }
}
