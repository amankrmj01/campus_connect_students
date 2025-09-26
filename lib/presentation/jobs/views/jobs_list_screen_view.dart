// lib/presentation/jobs/views/jobs_list_screen_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/job_model.dart';
import '../controllers/jobs.controller.dart';

class JobsListScreenView extends GetView<JobsController> {
  const JobsListScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('All Jobs'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: controller.showFiltersBottomSheet,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: controller.refreshJobs,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs, companies...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),

          // Filter Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: controller.tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 16),
                      const SizedBox(width: 4),
                      Obx(
                        () => Text(
                          'Eligible (${controller.eligibleJobs.length})',
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.list, size: 16),
                      const SizedBox(width: 4),
                      Obx(
                        () => Text(
                          'All (${controller.eligibleJobs.length + controller.notEligibleJobs.length})',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              labelColor: Colors.blue.shade700,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.blue.shade700,
            ),
          ),

          // Jobs List
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildJobsList(controller.eligibleJobs),
                _buildJobsList([
                  ...controller.eligibleJobs,
                  ...controller.notEligibleJobs,
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList(List<Job> jobs) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (jobs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.work_off_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No jobs available',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshJobs,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            // Determine if this job is in the eligible tab
            final isInEligibleTab = controller.eligibleJobs.contains(job);
            return _buildCompactJobCard(job, isInEligibleTab: isInEligibleTab);
          },
        ),
      );
    });
  }

  Widget _buildCompactJobCard(Job job, {required bool isInEligibleTab}) {
    final hasApplied = controller.hasAlreadyApplied(job);
    final daysLeft = controller.getDaysLeft(job.applicationDeadline);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => controller.goToJobDetails(job),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Company Logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.business,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Job Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.companyName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          job.location,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            controller.formatJobType(job.type),
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isInEligibleTab
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isInEligibleTab ? 'Eligible' : 'Not Eligible',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: isInEligibleTab
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (daysLeft >= 0)
                    Text(
                      '$daysLeft days left',
                      style: TextStyle(
                        fontSize: 9,
                        color: daysLeft <= 3
                            ? Colors.red.shade600
                            : Colors.grey.shade500,
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
}
