import 'package:flutter/material.dart';

import 'package:get/get.dart';

class MyApplicationsScreenView extends GetView {
  const MyApplicationsScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyApplicationsScreenView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'MyApplicationsScreenView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
