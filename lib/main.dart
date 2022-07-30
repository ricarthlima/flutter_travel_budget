import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_travel_budget/models/travel.dart';
import 'package:flutter_travel_budget/screens/travel_dashboard/travel_dashboard_screen.dart';
import 'firebase_options.dart';
import 'screens/travels_list/travels_list_screen.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Budget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const TravelsListScreen(),
      // home: TravelDashboardScreen(
      //   travel: Travel(
      //     id: "AAAA",
      //     name: "São Paulo",
      //     budget: 2000,
      //     startDate: DateTime.now(),
      //     endDate: DateTime.now().add(Duration(days: 15)),
      //   ),
      // ),
    );
  }
}
