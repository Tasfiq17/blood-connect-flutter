import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_colors.dart';
import '../services/dashboard_service.dart';
import '../widgets/donor_card.dart';

class FindDonorScreen extends StatefulWidget {
  const FindDonorScreen({super.key});

  @override
  State<FindDonorScreen> createState() => _FindDonorScreenState();
}

class _FindDonorScreenState extends State<FindDonorScreen> {
  final DashboardService _service = DashboardService();

  String? _selectedBloodGroup;
  String? _selectedDistrict;
  String _searchQuery = '';

  final List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  final List<String> districts = [
    "Chattogram", "Dhaka", "Cumilla", "Cox's Bazar", "Noakhali",
    "Feni", "Sylhet", "Khulna", "Rajshahi", "Barisal", "Rangpur", "Mymensingh",
  ];

  void _resetFilters() {
    setState(() {
      _selectedBloodGroup = null;
      _selectedDistrict = null;
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [

            // ── Header ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Find a Donor 🔍",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Search by blood group or district",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: const InputDecoration(
                        hintText: "Search blood group or location...",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Filters ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  // Blood Group Filter
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedBloodGroup,
                          hint: const Text("Blood Group",
                              style: TextStyle(fontSize: 13)),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text("All Groups")),
                            ...bloodGroups.map((g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(g),
                                )),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedBloodGroup = v),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // District Filter
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDistrict,
                          hint: const Text("District",
                              style: TextStyle(fontSize: 13)),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text("All Districts")),
                            ...districts.map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d),
                                )),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedDistrict = v),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Reset
                  GestureDetector(
                    onTap: _resetFilters,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(Icons.refresh,
                          color: AppColors.primary, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Results ───────────────────────────────────────────────────
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _service.findDonors(
                  bloodGroup: _selectedBloodGroup,
                  district: _selectedDistrict,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  var donors = snapshot.data?.docs ?? [];

                  // Apply location and blood group search filter (No name search)
                  if (_searchQuery.isNotEmpty) {
                    donors = donors.where((doc) {
                      final address = (doc['address'] ?? '').toString().toLowerCase();
                      final district = (doc['district'] ?? '').toString().toLowerCase();
                      final blood = (doc['bloodGroup'] ?? '').toString().toLowerCase();
                      
                      final query = _searchQuery.toLowerCase();
                      return address.contains(query) || 
                             district.contains(query) || 
                             blood.contains(query);
                    }).toList();
                  }

                  if (donors.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 70, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            "No donors found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Try changing your filters",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Result count chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${donors.length} donor${donors.length == 1 ? '' : 's'} found",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: donors.length,
                            itemBuilder: (context, index) {
                              return DonorCard(donor: donors[index].data());
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
