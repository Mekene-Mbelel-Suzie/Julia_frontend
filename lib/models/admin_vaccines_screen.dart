import 'package:flutter/material.dart';

import '../../models/vaccine_model.dart';
import '../../services/admin_service.dart';
import '../../utils/app_theme.dart';

class AdminVaccinesScreen extends StatefulWidget {
  const AdminVaccinesScreen({super.key});

  @override
  State<AdminVaccinesScreen> createState() => _AdminVaccinesScreenState();
}

class _AdminVaccinesScreenState extends State<AdminVaccinesScreen> {
  final AdminService adminService = AdminService();

  bool isLoading = true;
  List<VaccineModel> vaccines = [];

  @override
  void initState() {
    super.initState();
    loadVaccines();
  }

  Future<void> loadVaccines() async {
    try {
      final data = await adminService.getVaccines();
      if (!mounted) return;
      setState(() {
        vaccines = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load vaccines: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> openForm({VaccineModel? vaccine}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _VaccineFormDialog(vaccine: vaccine),
    );

    if (result == true) {
      await loadVaccines();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 12,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vaccines',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text('Manage the global vaccine catalog.'),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add Vaccine'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (vaccines.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No vaccines found.'),
              ),
            )
          else
            ...vaccines.map(
                  (vaccine) => Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withAlpha(18),
                    child: const Icon(Icons.vaccines_outlined, color: AppColors.primary),
                  ),
                  title: Text(vaccine.name),
                  subtitle: Text(
                    '${vaccine.code} • ${vaccine.category} • ${vaccine.numberOfDoses} dose(s)',
                  ),
                  trailing: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: vaccine.isActive
                              ? AppColors.success.withAlpha(18)
                              : AppColors.error.withAlpha(18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          vaccine.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: vaccine.isActive ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => openForm(vaccine: vaccine),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VaccineFormDialog extends StatefulWidget {
  final VaccineModel? vaccine;

  const _VaccineFormDialog({this.vaccine});

  @override
  State<_VaccineFormDialog> createState() => _VaccineFormDialogState();
}

class _VaccineFormDialogState extends State<_VaccineFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final AdminService adminService = AdminService();

  late final TextEditingController nameController;
  late final TextEditingController codeController;
  late final TextEditingController descriptionController;
  late final TextEditingController diseaseController;
  late final TextEditingController dosesController;

  String selectedCategory = 'routine';
  bool isActive = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.vaccine?.name ?? '');
    codeController = TextEditingController(text: widget.vaccine?.code ?? '');
    descriptionController = TextEditingController(text: widget.vaccine?.description ?? '');
    diseaseController = TextEditingController(text: widget.vaccine?.diseasePrevented ?? '');
    dosesController = TextEditingController(
      text: (widget.vaccine?.numberOfDoses ?? 1).toString(),
    );
    selectedCategory = widget.vaccine?.category ?? 'routine';
    isActive = widget.vaccine?.isActive ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    diseaseController.dispose();
    dosesController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      if (widget.vaccine == null) {
        await adminService.createVaccine(
          name: nameController.text.trim(),
          code: codeController.text.trim(),
          description: descriptionController.text.trim(),
          diseasePrevented: diseaseController.text.trim(),
          category: selectedCategory,
          numberOfDoses: int.parse(dosesController.text.trim()),
          isActive: isActive,
        );
      } else {
        await adminService.updateVaccine(
          vaccineId: widget.vaccine!.id,
          name: nameController.text.trim(),
          code: codeController.text.trim(),
          description: descriptionController.text.trim(),
          diseasePrevented: diseaseController.text.trim(),
          category: selectedCategory,
          numberOfDoses: int.parse(dosesController.text.trim()),
          isActive: isActive,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.vaccine == null ? 'Add Vaccine' : 'Edit Vaccine'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Vaccine name'),
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Enter vaccine name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Code'),
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Enter vaccine code' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: diseaseController,
                  decoration: const InputDecoration(labelText: 'Disease prevented'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dosesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Number of doses'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Enter number of doses';
                    if (int.tryParse(value.trim()) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'routine', child: Text('Routine')),
                    DropdownMenuItem(value: 'optional', child: Text('Optional')),
                    DropdownMenuItem(value: 'campaign', child: Text('Campaign')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value ?? 'routine';
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: isActive,
                  onChanged: (v) => setState(() => isActive = v),
                  title: const Text('Active'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : submit,
          child: isLoading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : const Text('Save'),
        ),
      ],
    );
  }
}