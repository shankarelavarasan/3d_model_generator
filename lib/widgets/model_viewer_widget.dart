import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ModelViewerWidget extends StatefulWidget {
  final String modelUrl;
  final String? thumbnailUrl;
  final bool autoRotate;
  final Color backgroundColor;

  const ModelViewerWidget({
    Key? key,
    required this.modelUrl,
    this.thumbnailUrl,
    this.autoRotate = true,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  State<ModelViewerWidget> createState() => _ModelViewerWidgetState();
}

class _ModelViewerWidgetState extends State<ModelViewerWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(_generateHTML());
  }

  String _generateHTML() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"></script>
        <style>
            body { margin: 0; padding: 0; overflow: hidden; }
            model-viewer { width: 100%; height: 100vh; }
        </style>
    </head>
    <body>
        <model-viewer
            src="${widget.modelUrl}"
            alt="3D Model"
            auto-rotate="${widget.autoRotate}"
            camera-controls
            background-color="${widget.backgroundColor.value.toRadixString(16).substring(2)}"
            skybox-image="${widget.thumbnailUrl ?? ''}"
            exposure="1.0"
            shadow-intensity="1.0">
        </model-viewer>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}