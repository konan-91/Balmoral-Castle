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

class _NewPageState extends State<NewPage> with TickerProviderStateMixin {
  String mainBody = '';
  String bottomBody = '';
  bool isLoading = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _loadTexts();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadTexts() async {
    try {
      final main = await rootBundle.loadString(
          'assets/texts/${widget.title}_1.txt');
      final bottom = await rootBundle.loadString(
          'assets/texts/${widget.title}_2.txt');
      setState(() {
        mainBody = main;
        bottomBody = bottom;
        isLoading = false;
      });
      _fadeController.forward();
    } catch (_) {
      setState(() {
        mainBody = 'Error loading content';
        bottomBody = '';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(
          0xFFFAFAFA),
      appBar: _buildAppBar(theme, isDark),
      body: isLoading ? _buildLoadingState() : _buildContent(theme, isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        widget.titleText,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Theme
                  .of(context)
                  .primaryColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading content...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContentCard(content: mainBody, isDark: isDark, isFirst: true),
            const SizedBox(height: 24),
            _buildContentCard(
                content: bottomBody, isDark: isDark, isFirst: false),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard({
    required String content,
    required bool isDark,
    required bool isFirst,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black
                .withOpacity(0.04),
            blurRadius: isDark ? 20 : 12,
            offset: const Offset(0, 4),
            spreadRadius: isDark ? -2 : 0,
          ),
        ],
        border: isDark
            ? Border.all(color: const Color(0xFF2C2C2E), width: 0.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: MarkdownBody(
            data: content,
            selectable: true,
            styleSheet: _buildMarkdownStyle(isDark),
            onTapLink: (text, href, _) async {
              if (href != null) {
                final uri = Uri.parse(href);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
          ),
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyle(bool isDark) {
    final baseColor = isDark ? Colors.white : const Color(0xFF050505);

    return MarkdownStyleSheet(
      p: TextStyle(fontSize: 19,
          fontFamily: 'NotoSans',
          fontWeight: FontWeight.w200,
          color: baseColor),
      h3: TextStyle(fontSize: 24,
          fontFamily: 'NotoSans',
          fontWeight: FontWeight.w100,
          color: baseColor),
    );
  }
}
