
import 'package:cuproute/app/constants/route_names.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CupRouteApp());
}

class CupRouteApp extends StatelessWidget {
  const CupRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CupRoute',
      debugShowCheckedModeBanner: false,

      initialRoute: RouteNames.splash,
      routes: {},
    );
  }
}
