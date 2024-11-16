import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:lotusbeacon/application/app.dart';

Future<void> main() async {
  hierarchicalLoggingEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    buildRunnableApp(
      isWeb: kIsWeb,
      webAppWidth: 480,
      app: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

Widget buildRunnableApp({
  required bool isWeb,
  required double webAppWidth,
  required Widget app,
  double webAppHeight = 900,
}) {
  if (!isWeb) {
    return app;
  }

  return Center(
    child: ClipRect(
      child: SizedBox(
        width: webAppWidth,
        height: webAppHeight,
        child: app,
      ),
    ),
  );
}
