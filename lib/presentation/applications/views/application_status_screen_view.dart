import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ApplicationStatusScreenView extends GetView {
  const ApplicationStatusScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ApplicationStatusScreenView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ApplicationStatusScreenView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
