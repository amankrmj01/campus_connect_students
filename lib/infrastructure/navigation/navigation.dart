import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config.dart';
import '../../presentation/jobs/views/job_application_form.screen.dart';
import '../../presentation/screens.dart';
import 'bindings/controllers/controllers_bindings.dart';
import 'bindings/job_application_form.binding.dart';
import 'routes.dart';

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;

  const EnvironmentsBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    var env = ConfigEnvironments.getEnvironments()['env'];
    return env != Environments.PRODUCTION
        ? Banner(
            location: BannerLocation.topStart,
            message: env!,
            color: env == Environments.QAS ? Colors.blue : Colors.purple,
            child: child,
          )
        : SizedBox(child: child);
  }
}

class Nav {
  static List<GetPage> routes = [
    GetPage(
      name: Routes.AUTH,
      page: () => const AuthScreen(),
      binding: AuthControllerBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const MainNavigationScreen(),
      bindings: [
        MainNavigationControllerBinding(),
        HomeControllerBinding(),
        JobsControllerBinding(),
        ApplicationsControllerBinding(),
        GroupsControllerBinding(),
        ProfileControllerBinding(),
      ],
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardScreen(),
      binding: DashboardControllerBinding(),
    ),
    GetPage(
      name: Routes.JOBS,
      page: () => const JobsScreen(),
      binding: JobsControllerBinding(),
    ),
    GetPage(
      name: Routes.JOB_APPLICATION,
      page: () => const JobApplicationFormScreen(),
      binding: JobApplicationFormBinding(),
    ),
    GetPage(
      name: Routes.APPLICATIONS,
      page: () => const ApplicationsScreen(),
      binding: ApplicationsControllerBinding(),
    ),
    GetPage(
      name: Routes.GROUPS,
      page: () => const GroupsScreen(),
      binding: GroupsControllerBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(),
      binding: ProfileControllerBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsScreen(),
      binding: SettingsControllerBinding(),
    ),
  ];
}
