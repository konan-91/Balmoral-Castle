import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_selection_screen.dart';
import 'language_provider.dart';
import 'new_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: MyApp(),
    ),
  );
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
      home: const LanguageSelectionScreen(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  // App Start
  @override
  Widget build(BuildContext context) {

    final language = context.watch<LanguageProvider>().language;
    print('Current Language: $language'); // Debug, verifying lang selection works

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balmoral Castle'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: const Text('Language'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LanguageSelectionScreen()),
                );
              },
            ),
            ListTile(
                title: const Text('Visit'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NewPage(title: 'Visit'),
                    ),
                  );
                }
            ),
            ListTile(
              title: const Text('New for 2025'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NewPage(title: 'New_for_2025'),
                  ),
                );
              }
            ),
            ListTile(
                title: const Text('Stay'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NewPage(title: 'Stay'),
                    ),
                  );
                }
            ),
            ListTile(
                title: const Text('Eat & Shop'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NewPage(title: 'Eat_&_Shop'),
                    ),
                  );
                }
            ),
            ListTile(
                title: const Text('Admission & Opening Times'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NewPage(title: 'Admission_&_Opening_Times'),
                    ),
                  );
                }
            ),
            const ListTile(
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