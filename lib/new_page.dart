import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NewPage extends StatefulWidget {
  final String title;

  const NewPage({super.key, required this.title});

  String get titleText => title.replaceAll('_', ' ');

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  String mainBody = '';
  String bottomBody = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTexts();
  }

  Future<void> _loadTexts() async {

    final main = await rootBundle.loadString('assets/texts/${widget.title}_1.txt');
    final bottom = await rootBundle.loadString('assets/texts/${widget.title}_2.txt');
    setState(() {
      mainBody = main;
      bottomBody = bottom;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.titleText)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.titleText)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                child: MarkdownBody(
                  data: mainBody,
                  onTapLink: (text, href, _) async {
                    if (await canLaunchUrl(Uri.parse(href!))) {
                      await launchUrl(Uri.parse(href));
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                child: MarkdownBody(
                  data: bottomBody,
                  onTapLink: (text, href, _) async {
                    if (await canLaunchUrl(Uri.parse(href!))) {
                      await launchUrl(Uri.parse(href));
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
