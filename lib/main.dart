import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miniplayerpro/screens/permission_screen.dart';
import 'package:miniplayerpro/screens/videos_list_screen.dart';
import 'package:miniplayerpro/utils/permission_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make app edge-to-edge (content may render behind status/navigation bars)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Note: we don't set a global overlay style here because we want the
  // overlay to follow the app theme (handled in MaterialApp.builder).
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

      // Optional: provide a darkTheme so ThemeMode.system has something to use.
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // customize dark theme if you want
      ),
      themeMode: ThemeMode.system,

      // This builder lets us set a SystemUiOverlayStyle that follows the app theme
      builder: (context, child) {
        // Use the app's active Theme to determine brightness
        final brightness = Theme.of(context).brightness;

        // If the app's theme is dark, we want light icons; otherwise dark icons.
        final overlay = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // fully transparent
          systemNavigationBarColor: Colors.transparent, // optional: nav bar transparent
          statusBarIconBrightness:
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          statusBarBrightness:
          brightness == Brightness.dark ? Brightness.dark : Brightness.light,
          systemNavigationBarIconBrightness:
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        );

        // AnnotatedRegion applies the overlay for the portion of the widget tree.
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: child ?? const SizedBox.shrink(),
        );
      },

      home: initialHasPermission ? const VideosListScreen() : const PermissionScreen(),
    );
  }
}
