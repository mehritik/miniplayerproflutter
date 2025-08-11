import 'dart:io';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:miniplayerpro/screens/videos_list_screen.dart';
import '../widgets/beyond_button.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  Future<void> _handlePermission(BuildContext context) async {
    // Helper to navigate
    void go() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VideosListScreen()),
      );
    }

    Future<void> handleStatus(PermissionStatus status) async {
      if (status.isGranted) {
        go();
      } else if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission required to continue')),
        );
        await Future.delayed(const Duration(milliseconds: 400));
        openAppSettings();
      } else {
        // normal denied -> inform user, but do nothing else
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission required to continue')),
        );
      }
    }

    try {
      // On Android: try modern media permission first, then fallback to storage
      if (Platform.isAndroid) {
        // Try videos (Android 13+ READ_MEDIA_VIDEO)
        final videoStatus = await Permission.videos.status;
        if (videoStatus.isGranted) {
          go();
          return;
        }

        final videoRequest = await Permission.videos.request();
        if (videoRequest.isGranted) {
          go();
          return;
        }

        // If videos permission wasn't granted, try legacy storage (pre-Android13)
        final storageStatus = await Permission.storage.status;
        if (storageStatus.isGranted) {
          go();
          return;
        }

        final storageRequest = await Permission.storage.request();
        await handleStatus(storageRequest);
        return;
      }

      // On iOS: request photos (covers media access)
      if (Platform.isIOS) {
        final photosStatus = await Permission.photos.status;
        if (photosStatus.isGranted) {
          go();
          return;
        }
        final photosRequest = await Permission.photos.request();
        await handleStatus(photosRequest);
        return;
      }

      // Other platforms: show a notice
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Platform not supported for media permission')),
      );
    } catch (e) {
      // Fallback error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colors for backgrounds
    final backgroundColor = isDark
        ? const Color(0xFF1C1C1C) // Charcoal black
        : const Color(0xFFEFF6FF); // White with slight bluish tint (#EFF6FF ≈ 10% blue)

    final gradientColors = isDark
        ? [const Color(0xFF1C1C1C), const Color(0xFF000000)]
        : [const Color(0xFFEFF6FF), const Color(0xFFDDEAFB)];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.3),
                  radius: 1.2,
                  colors: gradientColors,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 280,
                  child: ModelViewer(
                    src: 'assets/models/volcano.glb',
                    alt: 'Permission Model',
                    autoRotate: true,
                    disableZoom: true,
                    interactionPrompt: InteractionPrompt.none,
                    disablePan: true,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Allow Permission',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: isDark ? Colors.black45 : Colors.grey.withOpacity(0.3),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Text(
                    'We need access to your videos so we can show them in your library.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: BeyondButton(
                    label: 'Allow',
                    // onPressed: () => _handlePermission(context),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
