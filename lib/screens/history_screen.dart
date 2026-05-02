import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/forge_app_bar.dart';
import '../services/api_service.dart';
import '../models/forge_response.dart';
import 'result_screen.dart';

/// History screen — shows previously saved analyses.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final projects = await ApiService().listProjects();
      if (!mounted) return;
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _isLoading = false;
      });
    }
  }

  void _openProject(Map<String, dynamic> project) {
    try {
      // The project data should contain the full analysis response
      final data = project['analysis_data'] ?? project['data'] ?? project;
      final response = ForgeResponse.fromJson(data);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(data: response)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open project: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ForgeAppBar(title: 'History', showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(kSpaceMarginMobile),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, size: 48, color: kOutline.withValues(alpha: 0.5)),
                        const SizedBox(height: kSpaceMD),
                        Text(_error!, style: kBodyMd.copyWith(color: kSecondary), textAlign: TextAlign.center),
                        const SizedBox(height: kSpaceMD),
                        ElevatedButton(onPressed: _fetchProjects, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : _projects.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(kSpaceMarginMobile),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 48, color: kOutline.withValues(alpha: 0.5)),
                            const SizedBox(height: kSpaceMD),
                            const Text('No Saved Analyses', style: kHeadlineMd),
                            const SizedBox(height: kSpaceSM),
                            Text(
                              'Run an analysis and tap Save to\nsee your history here.',
                              style: kBodyMd.copyWith(color: kSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: kPrimary,
                      onRefresh: _fetchProjects,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(kSpaceMarginMobile, kSpaceMD, kSpaceMarginMobile, kSpaceXL),
                        itemCount: _projects.length,
                        separatorBuilder: (_, __) => const SizedBox(height: kSpaceMD),
                        itemBuilder: (context, index) {
                          final project = _projects[index];
                          return _ProjectHistoryCard(
                            project: project,
                            onTap: () => _openProject(project),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _ProjectHistoryCard extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback onTap;
  const _ProjectHistoryCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Extract fields from various possible structures
    final rec = project['recommendation'] as Map<String, dynamic>? ??
        (project['analysis_data'] as Map<String, dynamic>?)?['recommendation'] as Map<String, dynamic>? ??
        (project['data'] as Map<String, dynamic>?)?['recommendation'] as Map<String, dynamic>? ??
        {};
    final name = rec['name'] ?? project['name'] ?? 'Saved Analysis';
    final category = rec['category'] ?? project['category'] ?? '';
    final grade = rec['grade'] ?? '';
    final createdAt = project['created_at'] ?? project['saved_at'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(kRadiusLG),
          boxShadow: kSoftShadow,
        ),
        padding: const EdgeInsets.all(kSpaceMD),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(kRadiusMD),
              ),
              child: const Icon(Icons.science, color: kPrimary, size: 24),
            ),
            const SizedBox(width: kSpaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.toString(), style: kTitleSm, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (category.toString().isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: kSurfaceContainer, borderRadius: BorderRadius.circular(100)),
                          child: Text(category.toString().toUpperCase(), style: kDataXs.copyWith(color: kSecondary, fontSize: 10)),
                        ),
                        const SizedBox(width: kSpaceSM),
                      ],
                      if (grade.toString().isNotEmpty)
                        Text(grade.toString(), style: kDataXs.copyWith(color: kOutline)),
                    ],
                  ),
                  if (createdAt.toString().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(createdAt.toString(), style: kDataXs.copyWith(color: kOutline, fontSize: 10)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kOutline),
          ],
        ),
      ),
    );
  }
}
