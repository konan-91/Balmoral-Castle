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
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: regalBlue,
          appBar: AppBar(
            backgroundColor: regalBlue,
            foregroundColor: Colors.white,
            title: const Text('Balmoral Castle'),
            actions: [
              IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapPage()),
                ),
                tooltip: 'Open Map',
              ),
            ],
          ),
      drawer: Drawer(
        backgroundColor: regalBlue,
        child: ListView(
          physics: const ClampingScrollPhysics(),
          children: [
            Container(
              height: 150, // Similar to DrawerHeader's default height
              color: regalBlue,
              alignment: Alignment.center,
              child: Image(
                image: AssetImage('assets/images/drawer_logo.jpg'),
                fit: BoxFit.fill,
              ),
            ),

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
            padding: EdgeInsets.all(12.0),
            mainAxisSpacing: 12.0,
            crossAxisSpacing: 12.0,
            childAspectRatio: 16 / 9,
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
                      'assets/images/$videoNumber.png',
                      fit: BoxFit.cover,
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
        tileColor: regalBlue,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18), // White text, larger
        ),
        onTap: onTap,
      );


  void _navigateTo(BuildContext context, String title) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => NewPage(title: title)),
  );
}