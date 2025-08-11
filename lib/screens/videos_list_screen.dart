import 'package:flutter/material.dart';

class VideosListScreen extends StatelessWidget {
  const VideosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Videos List')),
      body: const Center(
        child: Text(
          'Videos List Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
