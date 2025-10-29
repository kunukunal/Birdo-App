import 'package:birdo/home/home.dart';
import 'package:birdo/manage/manage.dart';
import 'package:birdo/models/time_settings.dart'; // Import TimeSettings model
import 'package:birdo/setting/setting.dart';
import 'package:birdo/sound/soundlist.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/audio_controller.dart';

// void main() => runApp(const MaterialApp(home: BottomNavBar()));

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // Shared state for pathOrder and timeSettings
  List<String> _pathOrder = [];

  final AudioSchedulerController controller =
      Get.put(AudioSchedulerController());

  @override
  void initState() {
    super.initState();
    // controller.loadSchedulesFromApi();
  }

  TimeSettings? _timeSettings;

  // Callback to update pathOrder and switch to Home page
  void updatePathOrder(List<String> newPathOrder) {
    setState(() {
      _pathOrder = newPathOrder;
      _page = 0; // Navigate to Home page
    });

    // Force the navigation bar to update its state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bottomNavigationKey.currentState?.setPage(0);
    });
  }

  // Callback to update timeSettings and switch to Home page
  void updateTimeSettings(TimeSettings newTimeSettings) {
    setState(() {
      _timeSettings = newTimeSettings;
      _page = 0; // Navigate to Home page
    });

    // Force the navigation bar to update its state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bottomNavigationKey.currentState?.setPage(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild _pages each time build is called to reflect updated pathOrder and timeSettings
    final List<Widget> pages = [
      Home(
        pathOrder: _pathOrder,
        timeSettings: _timeSettings,
      ),
      ScheduleInputView(
          // updateTimeSettings: updateTimeSettings,
          ),
      Soundlist(
        updatePathOrder: updatePathOrder,
      ),
      // Remove any duplicate Manage page if present
      const Setting(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: pages[_page], // Display the selected page
            ),
            Container(
              height: 90, // Fixed height for the navigation bar container
              margin: const EdgeInsets.only(
                  left: 0, right: 0, bottom: 0), // Add margin on all sides
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(30), // Apply rounded corners
                child: CurvedNavigationBar(
                  key: _bottomNavigationKey,
                  index: _page, // Add this line to control the selected index
                  items: const <Widget>[
                    Icon(Icons.home_outlined, size: 30, color: Colors.white),
                    Icon(Icons.access_time, size: 30, color: Colors.white),
                    Icon(Icons.volume_up_sharp, size: 30, color: Colors.white),
                    Icon(Icons.settings_rounded, size: 30, color: Colors.white),
                  ],
                  height: 70, // Height of the CurvedNavigationBar
                  color: const Color(0xFF34BB91),
                  buttonBackgroundColor: const Color(0xFF34BB91),
                  backgroundColor:
                      Colors.transparent, // Make background transparent
                  animationCurve: Curves.easeInOut,
                  animationDuration: const Duration(milliseconds: 600),
                  onTap: (index) {
                    setState(() {
                      _page = index; // Update the current page
                    });
                  },
                  letIndexChange: (index) => true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
