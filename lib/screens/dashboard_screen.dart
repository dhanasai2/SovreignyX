import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/theme_provider.dart';
import '../utils/ats_colors.dart';
import 'candidates_screen.dart';
import 'contests_screen.dart';
import 'proctor_screen.dart';
import 'manage_courses_screen.dart';
import 'job_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const CandidatesScreen(),
    const JobDashboardScreen(),
    const ContestsScreen(),
    const ProctorScreen(),
    const ManageCoursesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _ensureCompanyProfileExists();
  }

  Future<void> _ensureCompanyProfileExists() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    if (user == null) return;

    try {
      final company = await supabase
          .from('companies')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (company == null) {
        await supabase.from('companies').insert({
          'id': user.id,
          'name': user.email?.split('@')[0] ?? 'Company',
          'email': user.email,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error ensuring company profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: ATSColors.bgSecondary,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ATSColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.business,
                color: ATSColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Company Portal',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: ATSColors.neutral800,
              ),
            ),
          ],
        ),
        backgroundColor: ATSColors.bgPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: ATSColors.neutral200,
            height: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: ATSColors.neutral600,
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle theme',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: ATSColors.neutral600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) async {
              if (value == 'logout') {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: ATSColors.danger, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(color: ATSColors.danger, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ATSColors.bgPrimary,
          border: Border(
            top: BorderSide(color: ATSColors.neutral200, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: ATSColors.neutral900.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          indicatorColor: ATSColors.primary.withOpacity(0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 70,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.people_outline, color: ATSColors.neutral500),
              selectedIcon: Icon(Icons.people, color: ATSColors.primary),
              label: 'Candidates',
            ),
            NavigationDestination(
              icon: Icon(Icons.work_outline, color: ATSColors.neutral500),
              selectedIcon: Icon(Icons.work, color: ATSColors.primary),
              label: 'Jobs',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined, color: ATSColors.neutral500),
              selectedIcon: Icon(Icons.emoji_events, color: ATSColors.primary),
              label: 'Contests',
            ),
            NavigationDestination(
              icon: Icon(Icons.security_outlined, color: ATSColors.neutral500),
              selectedIcon: Icon(Icons.security, color: ATSColors.primary),
              label: 'Proctor',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined, color: ATSColors.neutral500),
              selectedIcon: Icon(Icons.school, color: ATSColors.primary),
              label: 'Courses',
            ),
          ],
        ),
      ),
    );
  }
}
