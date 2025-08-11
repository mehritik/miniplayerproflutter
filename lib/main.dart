import 'package:flutter/material.dart';
import 'package:miniplayerpro/screens/permission_screen.dart';
import 'package:miniplayerpro/screens/videos_list_screen.dart';
import 'package:miniplayerpro/utils/permission_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasPermission = await PermissionUtil.checkStoragePermission();
  runApp(MyApp(initialHasPermission: hasPermission));
}

class MyApp extends StatelessWidget {
  final bool initialHasPermission;
  const MyApp({super.key, required this.initialHasPermission});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Storage Permission + Videos List',
      themeMode: ThemeMode.system,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: initialHasPermission
          ? const VideosListScreen()
          : const PermissionScreen(),
    );
  }
}
