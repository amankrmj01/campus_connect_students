// lib/presentation/applications/applications.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/applications.controller.dart';

class ApplicationsScreen extends GetView<ApplicationsController> {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade700, Colors.blue.shade900],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Title and Stats
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'My Applications',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${controller.totalApplications.value} Total',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        decoration: InputDecoration(
                          hintText: 'Search applications...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: Obx(
                            () => controller.searchQuery.value.isNotEmpty
                                ? IconButton(
                                    onPressed: controller.clearSearch,
                                    icon: const Icon(Icons.clear),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Statistics Cards
          _buildStatisticsCards(),

          // Filter Tabs
          _buildFilterTabs(),

          // Applications List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredApplications.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshApplications,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredApplications.length,
                  itemBuilder: (context, index) {
                    final application = controller.filteredApplications[index];
                    return _buildApplicationCard(application);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/jobs'),
        backgroundColor: Colors.blue.shade700,
        icon: const Icon(Icons.add),
        label: const Text('Apply for Jobs'),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Obx(
              () => _buildStatCard(
                'Applied',
                controller.appliedCount.value.toString(),
                Colors.blue,
                Icons.send,
              ),
            ),
            const SizedBox(width: 12),
            Obx(
              () => _buildStatCard(
                'Under Review',
                controller.underReviewCount.value.toString(),
                Colors.orange,
                Icons.hourglass_empty,
              ),
            ),
            const SizedBox(width: 12),
            Obx(
              () => _buildStatCard(
                'Shortlisted',
                controller.shortlistedCount.value.toString(),
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Obx(
              () => _buildStatCard(
                'Rejected',
                controller.rejectedCount.value.toString(),
                Colors.red,
                Icons.cancel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: controller.statusFilters.map((filter) {
                    final isSelected =
                        controller.selectedFilter.value == filter;
                    return GestureDetector(
                      onTap: () => controller.setFilter(filter),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade700
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue.shade700
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          '${controller.getFilterDisplayName(filter)} (${controller.getCountForFilter(filter)})',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: controller.showFilterMenu,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(application) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.goToApplicationDetails(application),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Company Logo Placeholder
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.business, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 12),

                  // Job Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.jobDetails.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.jobDetails.companyName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Applied ${controller.formatDate(application.appliedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // More Options
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'view_job':
                          controller.goToJobDetails(application);
                          break;
                        case 'withdraw':
                          controller.withdrawApplication(application);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view_job',
                        child: ListTile(
                          leading: Icon(Icons.work),
                          title: Text('View Job'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (application.canWithdraw)
                        const PopupMenuItem(
                          value: 'withdraw',
                          child: ListTile(
                            leading: Icon(Icons.undo, color: Colors.red),
                            title: Text(
                              'Withdraw',
                              style: TextStyle(color: Colors.red),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Status and Round Info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: controller
                          .getStatusColor(application.status)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.getStatusIcon(application.status),
                          size: 14,
                          color: controller.getStatusColor(application.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          application.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: controller.getStatusColor(
                              application.status,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (application.currentRound > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Round ${application.currentRound}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (application.hasGroupAccess)
                    Icon(Icons.group, size: 16, color: Colors.blue.shade600),
                ],
              ),

              // Progress Bar for Multi-round Process
              if (application.roundHistory.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildRoundProgress(application),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundProgress(application) {
    final totalRounds = application.roundHistory.length;
    final currentRound = application.currentRound;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Round Progress',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(totalRounds, (index) {
            final round = index + 1;
            final isCompleted = round < currentRound;
            final isCurrent = round == currentRound;

            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < totalRounds - 1 ? 4 : 0),
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent
                      ? Colors.blue.shade600
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            controller.selectedFilter.value == 'ALL'
                ? 'No Applications Yet'
                : 'No ${controller.getFilterDisplayName(controller.selectedFilter.value)} Applications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.selectedFilter.value == 'ALL'
                ? 'Start applying for jobs to see your applications here'
                : 'Try changing the filter to see more applications',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/jobs'),
            icon: const Icon(Icons.work),
            label: const Text('Browse Jobs'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
