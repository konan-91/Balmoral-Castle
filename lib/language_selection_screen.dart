import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'main.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LanguageProvider>(context, listen: false);

    final languages = ['English', 'German', 'French', 'Dutch', 'Italian', 'Spanish'];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Language')),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          return ListTile(
            title: Text(lang),
            onTap: () {
              provider.setLanguage(lang);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyHomePage()),
              );
            },
          );
        },
      ),
    );
  }
}