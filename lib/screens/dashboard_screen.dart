import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_colors.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/blood_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/rare_blood_section.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';
import 'login_screen.dart';
import 'find_donor_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'request_screen.dart';
import 'request_list_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _service = DashboardService();
  int _currentIndex = 0;

  // ── Bottom Nav Pages ───────────────────────────────────────────────────
  late final List<Widget> _pages = [
    _HomeTab(service: _service, onLogout: _handleLogout, onNav: _navigateTo),
    const FindDonorScreen(),
    const HomeScreen(),      // Donate tab
    const RequestScreen(),   // Request tab
    const ProfileScreen(),   // Profile tab
    const SettingsScreen(),  // Settings tab
  ];

  void _navigateTo(int index) => setState(() => _currentIndex = index);

  // ── Logout ─────────────────────────────────────────────────────────────
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService().logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Find"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Donate"),
          BottomNavigationBarItem(icon: Icon(Icons.bloodtype), label: "Request"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// HOME TAB — all the dashboard content
// ════════════════════════════════════════════════════════════════════════════

class _HomeTab extends StatelessWidget {
  final DashboardService service;
  final VoidCallback onLogout;
  final void Function(int) onNav;

  const _HomeTab({
    required this.service,
    required this.onLogout,
    required this.onNav,
  });

  // Helper: build a live count StreamBuilder
  Widget _liveCount({
    required Stream<QuerySnapshot<Map<String, dynamic>>> stream,
    required Widget Function(int count) builder,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return builder(count);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [

            // ── HEADER ────────────────────────────────────────────────────
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: service.currentUserStream(),
              builder: (context, snapshot) {
                final userData = snapshot.data?.data() ?? {};
                final name = snapshot.hasData
                    ? (userData['fullName'] ?? 'Loading...')
                    : 'Loading...';
                final bloodGroup = userData['bloodGroup'] ?? '';

                return Container(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 25, bottom: 35),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xffE53935), Color(0xffC62828)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 40,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Blood Connect",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white24,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Welcome 👋",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 15),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          _NotificationsBell(bloodGroup: bloodGroup),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            tooltip: "Logout",
                            onPressed: onLogout,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Let's Save Lives Together ❤️",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextField(
                          onSubmitted: (_) => onNav(1),
                          decoration: InputDecoration(
                            hintText: "Search donor or blood group",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.person_search),
                              onPressed: () => onNav(1),
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            // ── EMERGENCY BUTTON ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffFF6B6B), Color(0xffE53935)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.emergency, color: Colors.red, size: 30),
                    ),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Emergency Blood Request",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Find donors instantly",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => onNav(3), // go to Request tab
                        child: const Text("Request"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ── TODAY'S OVERVIEW ──────────────────────────────────────────
            _sectionHeader("Today's Overview"),
            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: .95,
                children: [

                  // ── Live: Total Donors ──────────────────────────────────
                  _liveCount(
                    stream: service.donorsStream(),
                    builder: (count) => StatCard(
                      title: "Donors",
                      value: "$count",
                      icon: Icons.people,
                      subtitle: "Active donors",
                    ),
                  ),

                  // ── Live: Total Users ───────────────────────────────────
                  _liveCount(
                    stream: service.allUsersStream(),
                    builder: (count) => StatCard(
                      title: "Members",
                      value: "$count",
                      icon: Icons.group,
                      subtitle: "Registered users",
                    ),
                  ),

                  // ── Live: Total Requests ────────────────────────────────
                  _liveCount(
                    stream: service.requestsStream(),
                    builder: (count) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RequestListScreen(),
                          ),
                        );
                      },
                      child: StatCard(
                        title: "Requests",
                        value: "$count",
                        icon: Icons.bloodtype,
                        subtitle: "Tap to view",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // ── BLOOD AVAILABILITY ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Icon(Icons.bloodtype, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    "Blood Availability",
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Live donor count per blood group",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ── Live Blood Group Grid ─────────────────────────────────────
            StreamBuilder<Map<String, int>>(
              stream: service.bloodStatsStream(),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? {
                  'A+': 0, 'A-': 0, 'B+': 0, 'B-': 0,
                  'O+': 0, 'O-': 0, 'AB+': 0, 'AB-': 0,
                };

                final groups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: groups.map((group) {
                      final count = stats[group] ?? 0;
                      return BloodCard(
                        group: group,
                        bags: "$count ${count == 1 ? 'Donor' : 'Donors'}",
                        count: count,
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 35),

            // ── RARE BLOOD SECTION ────────────────────────────────────────
            StreamBuilder<Map<String, int>>(
              stream: service.bloodStatsStream(),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? {};
                return RareBloodSection(bloodStats: stats);
              },
            ),

            const SizedBox(height: 35),

            // ── QUICK ACTIONS ─────────────────────────────────────────────
            _sectionHeader("Quick Actions"),
            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.0,
                children: [
                  DashboardCard(
                    title: "Donate Blood",
                    icon: Icons.favorite,
                    color: Colors.red,
                    onTap: () => onNav(2),
                  ),
                  DashboardCard(
                    title: "Request Blood",
                    icon: Icons.bloodtype,
                    color: Colors.deepOrange,
                    onTap: () {
                      // Navigate to request screen via a full-screen push
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RequestScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: "Find Donor",
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () => onNav(1),
                  ),
                  DashboardCard(
                    title: "My Profile",
                    icon: Icons.person,
                    color: Colors.green,
                    onTap: () => onNav(4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ── Notifications Bell ───────────────────────────────────────────────────────

class _NotificationsBell extends StatelessWidget {
  final String bloodGroup;

  const _NotificationsBell({required this.bloodGroup});

  @override
  Widget build(BuildContext context) {
    final DashboardService service = DashboardService();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: service.matchingRequestsStream(bloodGroup),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;

        return Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              tooltip: "Alerts",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(bloodGroup: bloodGroup),
                  ),
                );
              },
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}