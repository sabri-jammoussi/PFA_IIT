import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/constants/user_role.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/services/user_claims_service.dart';
import 'package:dentiflow/screens/widgets/glass_tab_bar.dart';
import 'package:dentiflow/sidebar/drawer_widget.dart';

// Admin tab pages
import 'package:dentiflow/pages/admin/views/admin_dashboard_view.dart';
import 'package:dentiflow/pages/admin/views/cabinets_management_view.dart';

// Dentist tab pages
import 'package:dentiflow/pages/dashboard/dentist/views/dentist_dashboard_view.dart';
import 'package:dentiflow/pages/patients/views/patients_list_view.dart';
import 'package:dentiflow/pages/consultation/views/consultation_view.dart';
import 'package:dentiflow/pages/medical_acts/views/medical_acts_view.dart';

// Secretary tab pages
import 'package:dentiflow/pages/dashboard/secretary/views/secretary_dashboard_view.dart';
import 'package:dentiflow/pages/appointments/views/agenda_view.dart';
import 'package:dentiflow/pages/appointments/views/pending_requests_view.dart';
import 'package:dentiflow/pages/billing/views/billing_view.dart';

// Patient portal tab pages
import 'package:dentiflow/pages/patient_portal/views/patient_home_view.dart';
import 'package:dentiflow/pages/patient_portal/views/patient_appointments_view.dart';
import 'package:dentiflow/pages/patient_portal/views/patient_book_view.dart';

// Profile tab
import 'package:dentiflow/pages/profile/views/profile_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.initialIndex = 0, super.key});
  final int initialIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  double _page = 0;
  UserRole _role = UserRole.unknown;

  @override
  void initState() {
    super.initState();
    _page = widget.initialIndex.toDouble();
    _pageController = PageController(initialPage: widget.initialIndex);
    _pageController.addListener(_onPageScroll);
    _loadRole();

    // Handle navigation argument from drawer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args is Map && args.containsKey('index')) {
        final int idx = args['index'] as int;
        _pageController.jumpToPage(idx);
      }
    });
  }

  void _onPageScroll() {
    if (_pageController.hasClients) {
      setState(() => _page = _pageController.page ?? 0);
    }
  }

  Future<void> _loadRole() async {
    final claims = await UserClaimsService.currentUser();
    if (!mounted) return;
    setState(() => _role = claims.role);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> get _pages {
    switch (_role) {
      case UserRole.dentist:
        return [
          const DentistDashboardView(),
          const PatientsListView(),
          const ConsultationView(),
          const MedicalActsView(),
          const ProfileView(),
        ];
      case UserRole.secretary:
        return [
          const SecretaryDashboardView(),
          const AgendaView(),
          const PendingRequestsView(),
          const BillingView(),
          const ProfileView(),
        ];
      case UserRole.patient:
        return [
          const PatientHomeView(),
          const PatientAppointmentsView(),
          const PatientBookView(),
          const ProfileView(),
        ];
      case UserRole.admin:
        return [
          const AdminDashboardView(),
          const CabinetsManagementView(),
          const ProfileView(),
        ];
      default:
        return [const ProfileView()];
    }
  }

  List<GlassTabItem> get _tabItems {
    void go(int i) => _pageController.animateToPage(
          i,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOut,
        );

    switch (_role) {
      case UserRole.dentist:
        return [
          GlassTabItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard_rounded, label: 'nav_dashboard'.tr, onTap: () => go(0)),
          GlassTabItem(icon: Icons.people_outline_rounded, selectedIcon: Icons.people_rounded, label: 'nav_patients'.tr, onTap: () => go(1)),
          GlassTabItem(icon: Icons.medical_information_outlined, selectedIcon: Icons.medical_information_rounded, label: 'nav_consultation'.tr, onTap: () => go(2)),
          GlassTabItem(icon: Icons.healing_outlined, selectedIcon: Icons.healing_rounded, label: 'nav_acts'.tr, onTap: () => go(3)),
          GlassTabItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'nav_profile'.tr, onTap: () => go(4)),
        ];
      case UserRole.secretary:
        return [
          GlassTabItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard_rounded, label: 'nav_dashboard'.tr, onTap: () => go(0)),
          GlassTabItem(icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month_rounded, label: 'nav_agenda'.tr, onTap: () => go(1)),
          GlassTabItem(icon: Icons.inbox_outlined, selectedIcon: Icons.inbox_rounded, label: 'nav_requests'.tr, onTap: () => go(2)),
          GlassTabItem(icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long_rounded, label: 'nav_billing'.tr, onTap: () => go(3)),
          GlassTabItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'nav_profile'.tr, onTap: () => go(4)),
        ];
      case UserRole.patient:
        return [
          GlassTabItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'nav_home'.tr, onTap: () => go(0)),
          GlassTabItem(icon: Icons.calendar_today_outlined, selectedIcon: Icons.calendar_today_rounded, label: 'nav_appointments'.tr, onTap: () => go(1)),
          GlassTabItem(icon: Icons.add_circle_outline_rounded, selectedIcon: Icons.add_circle_rounded, label: 'nav_book'.tr, onTap: () => go(2)),
          GlassTabItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'nav_profile'.tr, onTap: () => go(3)),
        ];
      case UserRole.admin:
        return [
          GlassTabItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard_rounded, label: 'Plateforme', onTap: () => go(0)),
          GlassTabItem(icon: Icons.business_outlined, selectedIcon: Icons.business_rounded, label: 'Cabinets', onTap: () => go(1)),
          GlassTabItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Profil', onTap: () => go(2)),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = DfColors.brandPrimary(context);
    final List<GlassTabItem> tabs = _tabItems;

    return Scaffold(
      extendBody: true,
      drawer: const DfDrawer(),
      body: PageView(
        controller: _pageController,
        physics: tabs.isEmpty ? const NeverScrollableScrollPhysics() : null,
        children: _pages,
      ),
      bottomNavigationBar: tabs.isEmpty
          ? null
          : GlassTabBar(
              items: tabs,
              accentColor: accent,
              position: _page,
            ),
    );
  }
}


