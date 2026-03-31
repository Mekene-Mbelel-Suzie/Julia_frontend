import 'package:flutter/material.dart';

import '../../models/nurse_dashboard_record_model.dart';
import '../../models/vaccination_record_model.dart';
import '../../services/nurse_service.dart';
import '../../utils/app_theme.dart';
import 'update_vaccination_record_screen.dart';

class NurseDashboardRecordsScreen extends StatefulWidget {
  const NurseDashboardRecordsScreen({super.key});

  @override
  State<NurseDashboardRecordsScreen> createState() => _NurseDashboardRecordsScreenState();
}

class _NurseDashboardRecordsScreenState extends State<NurseDashboardRecordsScreen> {
  final NurseService nurseService = NurseService();
  final TextEditingController searchController = TextEditingController();

  bool isLoading = true;
  String selectedTab = 'due_today';
  List<NurseDashboardRecordModel> records = [];

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    try {
      final data = await nurseService.getDashboardRecords(
        tab: selectedTab,
        search: searchController.text,
      );

      if (!mounted) return;
      setState(() {
        records = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load records: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> openUpdate(NurseDashboardRecordModel record) async {
    final tempRecord = VaccinationRecordModel(
      id: record.id,
      vaccineName: record.vaccineName,
      vaccineCode: record.vaccineCode,
      doseNumber: record.doseNumber,
      status: record.status,
      dueDate: record.dueDate,
      scheduledDate: record.scheduledDate,
      administeredDate: record.administeredDate,
      batchNumber: record.batchNumber,
      notes: record.notes,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateVaccinationRecordScreen(record: tempRecord),
      ),
    );

    if (result != null) {
      await loadRecords();
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'given':
        return AppColors.success;
      case 'missed':
      case 'cancelled':
        return AppColors.error;
      case 'scheduled':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      DropdownMenuItem(value: 'due_today', child: Text('Due Today')),
      DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
      DropdownMenuItem(value: 'given', child: Text('Given')),
      DropdownMenuItem(value: 'missed', child: Text('Missed')),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          const Text(
            'Vaccination Work Queue',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Track due, overdue, given, and missed records.'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search child, parent, vaccine',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (_) => loadRecords(),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  value: selectedTab,
                  items: tabs,
                  onChanged: (value) {
                    setState(() => selectedTab = value ?? 'due_today');
                  },
                  decoration: const InputDecoration(labelText: 'View'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: loadRecords,
                child: const Text('Apply'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (records.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No vaccination records found.'),
              ),
            )
          else
            ...records.map(
                  (record) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(record.status).withAlpha(30),
                    child: Icon(
                      Icons.vaccines_outlined,
                      color: _statusColor(record.status),
                    ),
                  ),
                  title: Text(
                    '${record.childName} • ${record.vaccineName} (${record.vaccineCode})',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Parent: ${record.parentName}'),
                      Text('Dose: ${record.doseNumber} • Status: ${record.status}'),
                      Text('Due: ${record.dueDate}'),
                    ],
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => openUpdate(record),
                ),
              ),
            ),
        ],
      ),
    );
  }
}