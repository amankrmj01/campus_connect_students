// lib/presentation/applications/views/my_applications_screen_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/applications.controller.dart';

class MyApplicationsScreenView extends GetView<ApplicationsController> {
  const MyApplicationsScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: controller.showFilterMenu,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(
                    () => Row(
                      children: controller.statusFilters.map((filter) {
                        final isSelected =
                            controller.selectedFilter.value == filter;
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              '${controller.getFilterDisplayName(filter)} (${controller.getCountForFilter(filter)})',
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                controller.setFilter(filter);
                              }
                            },
                            selectedColor: Colors.blue.shade100,
                            checkmarkColor: Colors.blue.shade700,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                    return _buildCompactApplicationCard(application);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactApplicationCard(application) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Icons.business, color: Colors.blue.shade700, size: 20),
        ),
        title: Text(
          application.jobDetails.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              application.jobDetails.companyName,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: controller
                        .getStatusColor(application.status)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    application.status.displayName,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: controller.getStatusColor(application.status),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  controller.formatDate(application.appliedAt),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => controller.goToApplicationDetails(application),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Applications Found',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.setFilter('ALL'),
            child: const Text('Show All Applications'),
          ),
        ],
      ),
    );
  }
}
