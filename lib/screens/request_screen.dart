import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_colors.dart';
import '../models/request_model.dart';
import '../services/dashboard_service.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final DashboardService _service = DashboardService();

  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String? _selectedBloodGroup;
  String? _selectedDistrict;
  String _urgency = 'Normal';
  bool _isLoading = false;

  final List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  final List<String> districts = [
    "Chattogram", "Dhaka", "Cumilla", "Cox's Bazar", "Noakhali",
    "Feni", "Sylhet", "Khulna", "Rajshahi", "Barisal", "Rangpur", "Mymensingh",
  ];

  final Map<String, Map<String, dynamic>> _urgencyOptions = {
    'Normal': {'color': AppColors.success, 'icon': Icons.check_circle_outline},
    'Urgent': {'color': AppColors.warning, 'icon': Icons.warning_amber_rounded},
    'Emergency': {'color': AppColors.danger, 'icon': Icons.emergency},
  };

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      _showSnack("Please select a blood group", isError: true);
      return;
    }
    if (_selectedDistrict == null) {
      _showSnack("Please select a district", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final request = RequestModel(
      patientName: _patientNameController.text.trim(),
      bloodGroup: _selectedBloodGroup!,
      hospital: _hospitalController.text.trim(),
      address: _addressController.text.trim(),
      district: _selectedDistrict!,
      contact: _contactController.text.trim(),
      urgency: _urgency,
      requestedBy: uid,
    );

    final error = await _service.submitBloodRequest(request);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      _showSnack("Blood request submitted successfully!", isError: false);
      _resetForm();
    } else {
      _showSnack(error, isError: true);
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _patientNameController.clear();
    _hospitalController.clear();
    _addressController.clear();
    _contactController.clear();
    setState(() {
      _selectedBloodGroup = null;
      _selectedDistrict = null;
      _urgency = 'Normal';
    });
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [

              // ── Header ─────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xffE53935), Color(0xffC62828)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Request Blood 🩸",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Submit your request and find donors near you.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // ── Form ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Warning Message ───────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.red.shade700),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Important: A donor cannot donate blood if they have already donated within the last 3 months.",
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Urgency Selector ────────────────────────────────
                      const Text(
                        "Urgency Level",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: _urgencyOptions.entries.map((entry) {
                          final isSelected = _urgency == entry.key;
                          final color =
                              entry.value['color'] as Color;
                          final icon =
                              entry.value['icon'] as IconData;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _urgency = entry.key),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color.withOpacity(0.12)
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? color
                                        : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(icon,
                                        color: isSelected
                                            ? color
                                            : Colors.grey,
                                        size: 22),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.key,
                                      style: TextStyle(
                                        color: isSelected
                                            ? color
                                            : Colors.grey,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 22),

                      // Patient Name
                      _buildField(
                        controller: _patientNameController,
                        label: "Patient Name",
                        icon: Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Patient name is required"
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Blood Group Dropdown
                      _buildDropdown(
                        label: "Blood Group Required",
                        icon: Icons.bloodtype_outlined,
                        value: _selectedBloodGroup,
                        items: bloodGroups,
                        onChanged: (v) =>
                            setState(() => _selectedBloodGroup = v),
                      ),

                      const SizedBox(height: 16),

                      // Hospital
                      _buildField(
                        controller: _hospitalController,
                        label: "Hospital / Clinic Name",
                        icon: Icons.local_hospital_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Hospital name is required"
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // District Dropdown
                      _buildDropdown(
                        label: "District",
                        icon: Icons.location_city_outlined,
                        value: _selectedDistrict,
                        items: districts,
                        onChanged: (v) =>
                            setState(() => _selectedDistrict = v),
                      ),

                      const SizedBox(height: 16),

                      // Address
                      _buildField(
                        controller: _addressController,
                        label: "Full Address",
                        icon: Icons.map_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Address is required"
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Contact Number
                      _buildField(
                        controller: _contactController,
                        label: "Contact Number",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Contact number is required";
                          }
                          if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(v.trim())) {
                            return "Enter a valid BD phone number";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          onPressed: _isLoading ? null : _submitRequest,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            _isLoading ? "Submitting..." : "Submit Request",
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────────────────

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _decoration(label, icon),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _decoration(label, icon),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _hospitalController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}
