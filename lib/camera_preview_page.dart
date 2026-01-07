import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewPage extends StatefulWidget {
  final CameraDescription camera;

  const CameraPreviewPage({super.key, required this.camera});

  @override
  State<CameraPreviewPage> createState() => _CameraPreviewPageState();
}

class _CameraPreviewPageState extends State<CameraPreviewPage> {
  late CameraController _controller;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
    widget.camera,
    ResolutionPreset.high,
    enableAudio: false,
  );

  _controller.initialize().then((_) async {
    // ✅ MATIKAN FLASH
    await _controller.setFlashMode(FlashMode.off);

      if (mounted) {
        setState(() {});
      }
    });
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Kamera")),
      body: CameraPreview(_controller),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final image = await _controller.takePicture();
          Navigator.pop(context, image);
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
