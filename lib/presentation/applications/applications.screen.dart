import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/applications.controller.dart';

class ApplicationsScreen extends GetView<ApplicationsController> {
  const ApplicationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ApplicationsScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ApplicationsScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
