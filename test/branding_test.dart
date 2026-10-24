import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coursemate_app/core/constants/app_constants.dart';
import 'package:coursemate_app/core/widgets/coursemate_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CourseMate Branding Assets Integrity', () {
    test('App and logo asset files exist and are non-empty', () {
      final assets = [
        AppConstants.assetLogoDark,
        AppConstants.assetLogoLight,
        AppConstants.assetLogoSymbol,
        AppConstants.assetAppIcon,
      ];

      for (final assetPath in assets) {
        final file = File(assetPath);
        expect(file.existsSync(), isTrue,
            reason: 'Asset $assetPath must exist on disk');
        expect(file.lengthSync(), greaterThan(1000),
            reason: 'Asset $assetPath must have substantial byte content');
      }
    });

    test('Android launcher icon assets exist across all density directories', () {
      final densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

      for (final density in densities) {
        final iconPath = 'android/app/src/main/res/mipmap-$density/ic_launcher.png';
        final roundIconPath = 'android/app/src/main/res/mipmap-$density/ic_launcher_round.png';
        final fgPath = 'android/app/src/main/res/mipmap-$density/ic_launcher_foreground.png';
        final launchImagePath = 'android/app/src/main/res/drawable-$density/launch_image.png';

        for (final path in [iconPath, roundIconPath, fgPath, launchImagePath]) {
          final file = File(path);
          expect(file.existsSync(), isTrue, reason: 'Android asset $path must exist');
          expect(file.lengthSync(), greaterThan(200),
              reason: 'Android asset $path must not be empty');
        }
      }
    });

    test('Android adaptive icon and splash XML configuration exists and valid', () {
      final xmlFiles = [
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml',
        'android/app/src/main/res/values/colors.xml',
        'android/app/src/main/res/drawable/launch_background.xml',
        'android/app/src/main/res/drawable-v21/launch_background.xml',
      ];

      for (final path in xmlFiles) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Configuration file $path must exist');
      }

      final colorsContent = File('android/app/src/main/res/values/colors.xml').readAsStringSync();
      expect(colorsContent, contains('ic_launcher_background'));
      expect(colorsContent, contains('#000000'));
      expect(colorsContent, contains('launch_background_color'));

      final launchBgContent = File('android/app/src/main/res/drawable/launch_background.xml').readAsStringSync();
      expect(launchBgContent, contains('@color/launch_background_color'));
      expect(launchBgContent, contains('@drawable/launch_image'));
    });

    test('Android 12+ SplashScreen API configuration exists and valid', () {
      final v31Styles = [
        'android/app/src/main/res/values-v31/styles.xml',
        'android/app/src/main/res/values-night-v31/styles.xml',
      ];

      for (final path in v31Styles) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'v31 style $path must exist');
        final content = file.readAsStringSync();
        expect(content, contains('windowSplashScreenBackground'));
        expect(content, contains('windowSplashScreenAnimatedIcon'));
        expect(content, contains('@drawable/launch_image'));
        expect(content, contains('@color/launch_background_color'));
      }
    });

    test('Web favicon and PWA icons exist and are non-empty', () {
      final webIcons = [
        'web/favicon.png',
        'web/icons/Icon-192.png',
        'web/icons/Icon-512.png',
        'web/icons/Icon-maskable-192.png',
        'web/icons/Icon-maskable-512.png',
      ];

      for (final iconPath in webIcons) {
        final file = File(iconPath);
        expect(file.existsSync(), isTrue,
            reason: 'Web icon $iconPath must exist');
        expect(file.lengthSync(), greaterThan(500),
            reason: 'Web icon $iconPath must not be empty');
      }
    });
  });

  group('CourseMateLogo Widget Theme Switching', () {
    testWidgets('CourseMateLogo selects dark logo in dark theme mode',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: CourseMateLogo(height: 40),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, equals('assets/images/logo_dark.png'));
    });

    testWidgets('CourseMateLogo selects light logo in light theme mode',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: CourseMateLogo(height: 40),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, equals('assets/images/logo_light.png'));
    });

    testWidgets('CourseMateLogo forceDark overrides light theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: CourseMateLogo(height: 40, forceDark: true),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, equals('assets/images/logo_dark.png'));
    });

    testWidgets('CourseMateLogo forceLight overrides dark theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: CourseMateLogo(height: 40, forceLight: true),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, equals('assets/images/logo_light.png'));
    });

    testWidgets('CourseMateSymbol loads logo_symbol.png',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CourseMateSymbol(size: 60),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, equals('assets/images/logo_symbol.png'));
    });
  });
}
