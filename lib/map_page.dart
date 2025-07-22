import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final _controller = TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  final _zoomFactor = 1.40;
  final _minScale = 1.0;
  final _maxScale = 4.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
      _controller.value = _animation!.value;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _resetZoom() => _animateTo(Matrix4.identity());

  void _zoomIn() => _applyZoom(_zoomFactor);

  void _zoomOut() => _applyZoom(1 / _zoomFactor);

  void _applyZoom(double scaleChange) {
    final begin = _controller.value.clone();
    final currentScale = begin.getMaxScaleOnAxis();
    final newScale = (currentScale * scaleChange).clamp(_minScale, _maxScale);
    final factor = newScale / currentScale;

    final box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final target = begin.clone();

    if (scaleChange > 1) {
      final center = size.center(Offset.zero);
      target.translate(center.dx, center.dy);
      target.scale(factor);
      target.translate(-center.dx, -center.dy);
    } else {
      target.scale(factor);
      final dx = target.getTranslation().x;
      final dy = target.getTranslation().y;
      final maxDx = (size.width * newScale - size.width) / 2;
      final maxDy = (size.height * newScale - size.height) / 2;

      target.setTranslationRaw(
        dx.clamp(-maxDx, maxDx),
        dy.clamp(-maxDy, maxDy),
        0,
      );
    }

    _animateTo(target);
  }

  void _animateTo(Matrix4 target) {
    _animation = Matrix4Tween(
      begin: _controller.value,
      end: target,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, // Black status bar icons
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            InteractiveViewer(
              transformationController: _controller,
              minScale: _minScale,
              maxScale: _maxScale,
              constrained: true,
              child: Center(
                child: Image.asset('assets/map/balmoral_map.png'),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: _buildButton(Icons.arrow_back_rounded, () => Navigator.of(context).pop()),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: _buildButton(Icons.refresh_rounded, _resetZoom),
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildButton(Icons.zoom_out_rounded, _zoomOut),
                  const SizedBox(width: 8),
                  _buildButton(Icons.zoom_in_rounded, _zoomIn),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton(
      onPressed: onPressed,
      heroTag: icon.toString(),
      backgroundColor: regalBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(56),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
