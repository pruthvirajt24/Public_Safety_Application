import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:women_safety_app/data/background/background_services.dart';
import 'package:women_safety_app/data/global/appdata.dart';
import 'package:women_safety_app/data/shared_preferences/shared_preferences.dart';
import 'package:women_safety_app/model/contact_model.dart';
import 'package:women_safety_app/res/utils/utils.dart';
import 'package:women_safety_app/view_model/auth/login_view_model.dart';
import 'package:women_safety_app/view_model/bottom_sheat_view_model.dart';
import 'package:women_safety_app/views/child/bottom_nav_bar.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:women_safety_app/views/parents/parent_home_screen.dart';
import 'package:women_safety_app/views/police/police_dashboard.dart';
import 'package:women_safety_app/views/selection/auth_selection_screen.dart';

import 'firebase_options.dart';
import 'package:hive/hive.dart';

Future handlePermissions() async {
  await Permission.location.request();
  await Permission.sms.request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MySharedPrefernces.init();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  // Register  adapter
  Hive.registerAdapter(ContactModelAdapter());
  await Hive.openBox<ContactModel>('contactsData');
  await handlePermissions();
  await initiallizedLocalNotification();
  await BottomSheetControllers().grantedPermission();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    userData = await MySharedPrefernces().getUserData();
  } catch (e) {
    log("Error fetching user data from shared preferences");
  }
  try {
    await updateUserData(userData["id"]);
    userData = await MySharedPrefernces().getUserData();
  } catch (e) {}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Woman Safety App',
      theme: ThemeData(
        textTheme: GoogleFonts.figtreeTextTheme(ThemeData.light().textTheme),
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // useMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      home: FutureBuilder(
        future: MySharedPrefernces.getUserType(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingIndicator();
          }

          switch (snapshot.data) {
            case '':
              return const AuthSelectionScreen();
            case 'child':
              return const BottomNavPagesScreen();
            case 'parent':
              return const ParentHomeScreen();
            case 'police':
              return const PoliceDashboard();
            /*  default:
              return const LoginScreen(); */
            default:
              return const AuthSelectionScreen();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
