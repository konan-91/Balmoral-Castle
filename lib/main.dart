import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Global Appearance Controls
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawer Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  // App Start
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balmoral Castle'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Language'),
            ),
            ListTile(
              leading: Icon(Icons.card_travel),
              title: Text('Visit'),
            ),
            ListTile(
              leading: Icon(Icons.new_releases),
              title: Text('New For 2025'),
            ),
            ListTile(
              leading: Icon(Icons.house),
              title: Text('Stay'),
            ),
            ListTile(
              leading: Icon(Icons.emoji_food_beverage),
              title: Text('Eat & Shop'),
            ),
            ListTile(
              leading: Icon(Icons.timer),
              title: Text('Admission & Opening Times'),
            ),
            ListTile(
              leading: Icon(Icons.copyright),
              title: Text('Copyright'),
            ),
          ],
        ),
      ),
      // body: const Center(child: Text('[Videos Here]')),
      // Need a list 1:10, which will display images 1:10 * current_language, linking to videos 1:10 (with sub track * language)
      body: GridView.count(
        crossAxisCount: 1,
        children: List.generate(10, (index) {
          return Center(
            child: Text(
              'Video $index',
              style: TextTheme.of(context).headlineSmall,
            ),
          );
        }),
      ),
    );
  }
}