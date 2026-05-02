import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/theme.dart';
import '../config/constants.dart';
import '../widgets/forge_app_bar.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  List<Map<String, dynamic>> _materials = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'all';

  final List<String> _categories = ['all', 'metal', 'polymer', 'ceramic', 'composite', 'wood'];

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = _selectedCategory == 'all'
          ? Uri.parse('$kApiBaseUrl/api/materials')
          : Uri.parse('$kApiBaseUrl/api/materials?category=$_selectedCategory');

      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          _materials = List<Map<String, dynamic>>.from(data['materials'] ?? []);
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Failed to load materials (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ForgeAppBar(title: 'Materials Database', showBackButton: true),
      body: Column(
        children: [
          // Category filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(kSpaceMarginMobile, kSpaceMD, kSpaceMarginMobile, kSpaceSM),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: kSpaceSM),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      _fetchMaterials();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? kPrimary : kSurfaceContainerLowest,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: isSelected ? kPrimary : kOutlineVariant),
                      ),
                      child: Text(
                        cat == 'all' ? 'All' : cat[0].toUpperCase() + cat.substring(1),
                        style: kLabelMd.copyWith(
                          color: isSelected ? Colors.white : kOnSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimary))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off, size: 48, color: kOutline.withValues(alpha: 0.5)),
                            const SizedBox(height: kSpaceMD),
                            Text(_error!, style: kBodyMd.copyWith(color: kSecondary), textAlign: TextAlign.center),
                            const SizedBox(height: kSpaceMD),
                            ElevatedButton(onPressed: _fetchMaterials, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : _materials.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 48, color: kOutline.withValues(alpha: 0.5)),
                                const SizedBox(height: kSpaceMD),
                                Text('No materials found', style: kBodyMd.copyWith(color: kSecondary)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: kPrimary,
                            onRefresh: _fetchMaterials,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(kSpaceMarginMobile, kSpaceSM, kSpaceMarginMobile, kSpaceXL),
                              itemCount: _materials.length,
                              separatorBuilder: (_, __) => const SizedBox(height: kSpaceMD),
                              itemBuilder: (context, index) {
                                final mat = _materials[index];
                                return _MaterialCard(material: mat);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final Map<String, dynamic> material;
  const _MaterialCard({required this.material});

  @override
  Widget build(BuildContext context) {
    final name = material['name'] ?? 'Unknown';
    final category = material['category'] ?? '';
    final grade = material['grade'] ?? '';
    final properties = material['properties'] as Map<String, dynamic>? ?? {};

    return Container(
      decoration: BoxDecoration(
        color: kSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(kRadiusLG),
        boxShadow: kSoftShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceSM),
          childrenPadding: const EdgeInsets.fromLTRB(kSpaceMD, 0, kSpaceMD, kSpaceMD),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(kRadiusMD),
            ),
            child: const Icon(Icons.science, color: kPrimary, size: 24),
          ),
          title: Text(name, style: kTitleSm),
          subtitle: Row(
            children: [
              if (category.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4, right: kSpaceSM),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: kSurfaceContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(category.toUpperCase(), style: kDataXs.copyWith(color: kSecondary)),
                ),
              if (grade.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(grade, style: kDataXs.copyWith(color: kOutline)),
                ),
            ],
          ),
          children: [
            if (properties.isNotEmpty) ...[
              const Divider(height: 1),
              const SizedBox(height: kSpaceSM),
              ...properties.entries.map((entry) {
                if (entry.value is num) {
                  final val = (entry.value as num).toDouble();
                  Color barColor;
                  if (val >= 7) {
                    barColor = const Color(0xFF16A34A);
                  } else if (val >= 4) {
                    barColor = kPrimary;
                  } else {
                    barColor = kError;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: kSpaceSM),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            entry.key.replaceAll('_', ' ').toUpperCase(),
                            style: kDataXs.copyWith(color: kSecondary),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: val / 10.0,
                              backgroundColor: kSurfaceContainer,
                              valueColor: AlwaysStoppedAnimation(barColor),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: kSpaceSM),
                        SizedBox(
                          width: 30,
                          child: Text('${val.toInt()}', style: kDataXs.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: kSpaceSM),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key.replaceAll('_', ' ').toUpperCase(), style: kDataXs.copyWith(color: kSecondary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: kSurfaceContainer, borderRadius: BorderRadius.circular(100)),
                          child: Text('${entry.value}'.toUpperCase(), style: kDataXs.copyWith(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  );
                }
              }),
            ],
          ],
        ),
      ),
    );
  }
}
