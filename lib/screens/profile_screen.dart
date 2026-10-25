import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../services/dashboard_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DashboardService _service = DashboardService();
  bool _editMode = false;
  bool _isSaving = false;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  String? _selectedDistrict;

  final List<String> districts = [
    "Chattogram", "Dhaka", "Cumilla", "Cox's Bazar", "Noakhali",
    "Feni", "Sylhet", "Khulna", "Rajshahi", "Barisal", "Rangpur", "Mymensingh",
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  void _populateControllers(UserModel user) {
    _nameController.text = user.fullName;
    _phoneController.text = user.phone;
    _addressController.text = user.address;
    _selectedDistrict = user.district;
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnack("Name cannot be empty", isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final updates = {
      'fullName': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'district': _selectedDistrict ?? '',
    };

    final error = await _service.updateUserProfile(updates);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (error == null) _editMode = false;
    });

    _showSnack(
      error == null ? "Profile updated successfully!" : error,
      isError: error != null,
    );
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

  /// Calculate age from "DD/MM/YYYY" string
  String _calculateAge(String dob) {
    try {
      final parts = dob.split('/');
      if (parts.length != 3) return '';
      final birthDate = DateTime(
          int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return "$age years";
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _service.currentUserStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }

            final data = snapshot.data!.data() ?? {};
            final user = UserModel.fromMap(data);

            // Populate controllers (only when not in edit mode to avoid overwrite)
            if (!_editMode) _populateControllers(user);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [

                  // ── Header / Avatar ────────────────────────────────────
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xffE53935), Color(0xffC62828)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "My Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Avatar
                      Positioned(
                        bottom: -45,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                  color: AppColors.primary, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                user.bloodGroup,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // Name + Donor Badge
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: user.isDonor
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              user.isDonor
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 14,
                              color: user.isDonor
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              user.isDonor ? "Active Donor" : "Not Donating",
                              style: TextStyle(
                                color: user.isDonor
                                    ? AppColors.primary
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Stats Row ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _service.getUserDonations(),
                      builder: (context, snap) {
                        final donationCount = snap.data?.docs.length ?? 0;
                        return Row(
                          children: [
                            _statBox("Blood Group", user.bloodGroup,
                                Icons.bloodtype, AppColors.primary),
                            const SizedBox(width: 12),
                            _statBox("Donations", "$donationCount",
                                Icons.favorite, Colors.pink),
                            const SizedBox(width: 12),
                            _statBox(
                              "Age",
                              _calculateAge(user.dateOfBirth),
                              Icons.cake,
                              Colors.orange,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Profile Info Card ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header row
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 12, 4),
                            child: Row(
                              children: [
                                const Text(
                                  "Personal Information",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () {
                                    if (_editMode) {
                                      // Cancel edit
                                      _populateControllers(user);
                                      setState(() => _editMode = false);
                                    } else {
                                      setState(() => _editMode = true);
                                    }
                                  },
                                  icon: Icon(
                                    _editMode ? Icons.close : Icons.edit,
                                    size: 16,
                                  ),
                                  label: Text(_editMode ? "Cancel" : "Edit"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 1),

                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              children: [
                                if (_editMode) ...[
                                  // ── Edit Mode ────────────────────────────
                                  _editField(
                                      _nameController, "Full Name", Icons.person),
                                  const SizedBox(height: 14),
                                  _editField(
                                      _phoneController, "Phone Number", Icons.phone,
                                      type: TextInputType.phone),
                                  const SizedBox(height: 14),
                                  _editField(_addressController, "Address",
                                      Icons.home, maxLines: 2),
                                  const SizedBox(height: 14),
                                  // District dropdown
                                  DropdownButtonFormField<String>(
                                    value: _selectedDistrict,
                                    decoration: InputDecoration(
                                      labelText: "District",
                                      prefixIcon: const Icon(
                                          Icons.location_city,
                                          color: AppColors.primary),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                    ),
                                    items: districts
                                        .map((d) => DropdownMenuItem(
                                            value: d, child: Text(d)))
                                        .toList(),
                                    onChanged: (v) => setState(
                                        () => _selectedDistrict = v),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      onPressed:
                                          _isSaving ? null : _saveProfile,
                                      icon: _isSaving
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2))
                                          : const Icon(Icons.save),
                                      label: Text(
                                        _isSaving
                                            ? "Saving..."
                                            : "Save Changes",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  // ── View Mode ─────────────────────────────
                                  _infoRow(Icons.person, "Name", user.fullName),
                                  _divider(),
                                  _infoRow(Icons.email, "Email", user.email),
                                  _divider(),
                                  _infoRow(Icons.phone, "Phone", user.phone),
                                  _divider(),
                                  _infoRow(Icons.location_city, "District",
                                      user.district),
                                  _divider(),
                                  _infoRow(
                                      Icons.home, "Address", user.address),
                                  _divider(),
                                  _infoRow(Icons.person_outline, "Gender",
                                      user.gender),
                                  _divider(),
                                  _infoRow(Icons.cake, "Date of Birth",
                                      user.dateOfBirth),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────────────────

  Widget _statBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15, color: color),
            ),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? 'Not set' : value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade100);

  Widget _editField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
