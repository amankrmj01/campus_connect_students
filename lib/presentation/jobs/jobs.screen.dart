// lib/presentation/jobs/jobs.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/job_model.dart';
import 'controllers/jobs.controller.dart';

class JobsScreen extends GetView<JobsController> {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // App Bar with Search
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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'Jobs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: controller.showFiltersBottomSheet,
                          icon: const Icon(
                            Icons.filter_list,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: controller.refreshJobs,
                          icon: const Icon(Icons.refresh, color: Colors.white),
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
                        decoration: const InputDecoration(
                          hintText: 'Search jobs, companies...',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tab Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: controller.tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.blue.shade700,
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      tabs: const [
                        Tab(text: 'Eligible'),
                        Tab(text: 'Not Eligible'),
                        Tab(text: 'All'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Filters Summary
          _buildFiltersChips(),

          // Tab View Content
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildJobsList(controller.eligibleJobs),
                _buildJobsList(controller.notEligibleJobs),
                _buildJobsList(controller.allJobs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList(RxList<Job> jobsList) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final filteredJobs = controller.getFilteredJobs(jobsList);

      if (filteredJobs.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshJobs,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredJobs.length,
          itemBuilder: (context, index) {
            final job = filteredJobs[index];
            // Determine which tab context this job is in
            bool isInEligibleTab = false;
            bool isInNotEligibleTab = false;

            if (jobsList == controller.eligibleJobs) {
              isInEligibleTab = true;
            } else if (jobsList == controller.notEligibleJobs) {
              isInNotEligibleTab = true;
            } else {
              // For "All" tab, check which list the job belongs to
              isInEligibleTab = controller.eligibleJobs.contains(job);
            }

            return _buildJobCard(job, isInEligibleTab: isInEligibleTab);
          },
        ),
      );
    });
  }

  Widget _buildFiltersChips() {
    return Obx(() {
      final hasFilters =
          controller.searchQuery.value.isNotEmpty ||
          controller.selectedJobType.value != 'ALL' ||
          controller.selectedLocation.value != 'ALL' ||
          !controller.showEligibleOnly.value;

      if (!hasFilters) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (controller.searchQuery.value.isNotEmpty)
                _buildFilterChip(
                  'Search: ${controller.searchQuery.value}',
                  () => controller.searchController.clear(),
                ),
              if (controller.selectedJobType.value != 'ALL')
                _buildFilterChip(
                  'Type: ${controller.selectedJobType.value.replaceAll('_', ' ')}',
                  () => controller.setJobTypeFilter('ALL'),
                ),
              if (controller.selectedLocation.value != 'ALL')
                _buildFilterChip(
                  'Location: ${controller.selectedLocation.value}',
                  () => controller.setLocationFilter('ALL'),
                ),
              if (!controller.showEligibleOnly.value)
                _buildFilterChip(
                  'All Jobs',
                  () => controller.toggleEligibleOnly(),
                ),
              if (hasFilters)
                TextButton(
                  onPressed: controller.clearFilters,
                  child: const Text('Clear All'),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onDeleted,
        backgroundColor: Colors.blue.shade50,
        labelStyle: TextStyle(color: Colors.blue.shade700),
      ),
    );
  }

  Widget _buildJobCard(Job job, {required bool isInEligibleTab}) {
    final hasApplied = controller.hasAlreadyApplied(job);
    final daysLeft = controller.getDaysLeft(job.applicationDeadline);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.goToJobDetails(job),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          job.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.companyName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              job.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Eligibility Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isInEligibleTab
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isInEligibleTab ? 'Eligible' : 'Not Eligible',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isInEligibleTab
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Job Details Row
              Row(
                children: [
                  _buildJobDetailChip(
                    controller.formatJobType(job.type),
                    Icons.work_outline,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildJobDetailChip(
                    'CGPA: ${job.requirements.minCgpa}+',
                    Icons.school_outlined,
                    Colors.green,
                  ),
                  const Spacer(),
                  if (daysLeft >= 0)
                    Text(
                      '$daysLeft days left',
                      style: TextStyle(
                        fontSize: 11,
                        color: daysLeft <= 3
                            ? Colors.red.shade600
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Job Description Preview
              Text(
                job.description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Salary and Apply Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Salary',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          controller.formatSalary(job.salary),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: hasApplied || daysLeft < 0 || !isInEligibleTab
                        ? null
                        : () => controller.applyForJob(job),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller
                          .getApplicationStatusColorForTab(
                            job,
                            isInEligibleTab: isInEligibleTab,
                          ),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      controller.getApplicationStatusTextForTab(
                        job,
                        isInEligibleTab: isInEligibleTab,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobDetailChip(String text, IconData icon, Color color) {
    Color textColor;
    if (color is MaterialColor) {
      textColor = color.shade700;
    } else {
      textColor = color;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No jobs found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
