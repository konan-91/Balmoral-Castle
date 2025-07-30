import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'language_selection_screen.dart';
import 'language_provider.dart';
import 'new_page.dart';
import 'video_player.dart';
import 'map_page.dart';

const Color regalBlue = Color(0xFF00426A);

void main() {
  MediaKit.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balmoral Castle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const LanguageSelectionScreen(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context, listen: false).language;

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: regalBlue,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: regalBlue,
            iconTheme: const IconThemeData(
              color: Colors.white,
              size: 42,
            ),
            title: const Text(
              'Balmoral Castle',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            elevation: 8.0,
            shadowColor: Colors.black,
            leading: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 4.0), // Slight padding for map icon
                child: IconButton(
                  icon: const Icon(Icons.location_on, size: 42, color: Colors.white),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapPage()),
                  ),
                  tooltip: 'Open Map',
                ),
              ),
            ],
          ),

          drawer: Drawer(
            backgroundColor: regalBlue,
            child: ListView(
              physics: const ClampingScrollPhysics(),
              children: [
                Container(
                  height: 140,
                  color: regalBlue,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0), // Adjust as needed
                    child: Image(
                      image: AssetImage('assets/images/drawer_logo.jpeg'),
                      fit: BoxFit.contain, // Use contain to respect padding
                    ),
                  ),
                ),


                const SizedBox(height: 28),

                _menuTile(context, 'Language', () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
                )),
                _menuTile(context, 'Visit', () => _navigateTo(context, 'Visit')),
                _menuTile(context, 'New for 2025', () => _navigateTo(context, 'New_for_2025')),
                _menuTile(context, 'Stay', () => _navigateTo(context, 'Stay')),
                _menuTile(context, 'Eat & Shop', () => _navigateTo(context, 'Eat_&_Shop')),
                _menuTile(context, 'Admission & Opening Times', () => _navigateTo(context, 'Admission_&_Opening_Times')),
                _menuTile(context, 'Copyright', () => _navigateTo(context, 'Copyright')),
              ],
            ),
          ),
          body: GridView.count(
            crossAxisCount: 1,
            padding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 40.0),
            mainAxisSpacing: 12.0,
            crossAxisSpacing: 12.0,
            childAspectRatio: 111 / 67,
            children: List.generate(10, (index) {
              final videoNumber = index + 1;
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayer(videoNumber: videoNumber.toString()),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.0),
                    child: Image.asset(
                      'assets/images/${language}_$videoNumber.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              );
            }),
          ),
        ));
  }

  ListTile _menuTile(BuildContext context, String title, VoidCallback onTap) =>
      ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
        dense: true,
        tileColor: regalBlue,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        onTap: onTap,
      );

  void _navigateTo(BuildContext context, String title) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => NewPage(title: title)),
  );
}