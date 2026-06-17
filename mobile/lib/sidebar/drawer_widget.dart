import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/constants/user_role.dart';
import 'package:dentiflow/core/services/user_claims_service.dart';
import 'package:dentiflow/core/storage/secure_token_storage.dart';
import 'package:dentiflow/core/services/signalr_service.dart';

class DfDrawer extends StatefulWidget {
  const DfDrawer({super.key});

  @override
  State<DfDrawer> createState() => _DfDrawerState();
}

class _DfDrawerState extends State<DfDrawer> {
  String _version = '';
  UserClaims _claims = UserClaims.anonymous();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    final claims = await UserClaimsService.currentUser();
    if (!mounted) return;
    setState(() {
      _version = info.version;
      _claims = claims;
    });
  }

  List<Map<String, dynamic>> _menuItems(UserRole role) {
    final List<Map<String, dynamic>> items = [];

    switch (role) {
      case UserRole.dentist:
        items.addAll([
          {'title': 'nav_dashboard'.tr, 'icon': Icons.dashboard_outlined, 'route': '/home', 'index': 0},
          {'title': 'nav_patients'.tr, 'icon': Icons.people_outline_rounded, 'route': '/home', 'index': 1},
          {'title': 'nav_consultation'.tr, 'icon': Icons.medical_information_outlined, 'route': '/home', 'index': 2},
          {'title': 'nav_acts'.tr, 'icon': Icons.healing_outlined, 'route': '/home', 'index': 3},
          {'title': 'nav_staff'.tr, 'icon': Icons.badge_outlined, 'route': '/staff'},
        ]);
        break;
      case UserRole.secretary:
        items.addAll([
          {'title': 'nav_dashboard'.tr, 'icon': Icons.dashboard_outlined, 'route': '/home', 'index': 0},
          {'title': 'nav_agenda'.tr, 'icon': Icons.calendar_month_outlined, 'route': '/home', 'index': 1},
          {'title': 'nav_requests'.tr, 'icon': Icons.inbox_outlined, 'route': '/home', 'index': 2},
          {'title': 'nav_billing'.tr, 'icon': Icons.receipt_long_outlined, 'route': '/home', 'index': 3},
          {'title': 'nav_stock'.tr, 'icon': Icons.inventory_2_outlined, 'route': '/stock'},
        ]);
        break;
      case UserRole.patient:
        items.addAll([
          {'title': 'nav_home'.tr, 'icon': Icons.home_outlined, 'route': '/home', 'index': 0},
          {'title': 'nav_appointments'.tr, 'icon': Icons.calendar_today_outlined, 'route': '/home', 'index': 1},
          {'title': 'nav_book'.tr, 'icon': Icons.add_circle_outline_rounded, 'route': '/home', 'index': 2},
        ]);
        break;
      default:
        break;
    }

    items.addAll([
      {'title': 'nav_notifications'.tr, 'icon': Icons.notifications_outlined, 'route': '/notifications'},
      {'title': 'nav_profile'.tr, 'icon': Icons.person_outline_rounded, 'route': '/profile'},
      {'title': 'nav_settings'.tr, 'icon': Icons.settings_outlined, 'route': '/settings'},
    ]);

    return items;
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('logout_confirm'.tr),
        content: Text('logout_confirm_msg'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('confirm'.tr, style: const TextStyle(color: DfColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await SignalRService.instance.disconnectAll();
    } catch (_) {}
    await SecureStorage.deleteToken();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = DfColors.brandPrimary(context);
    final List<Map<String, dynamic>> menus = _menuItems(_claims.role);

    return Drawer(
      backgroundColor: DfColors.surface1(context),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withValues(alpha: 0.85),
                    primary.withValues(alpha: 0.65),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.25),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
                    ),
                    child: Center(
                      child: Text(
                        _claims.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'drawer_welcome'.tr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _claims.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DfPill(
                    label: _claims.role.displayName,
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.20),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                ],
              ),
            ),
            // Menu
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: menus.length,
                itemBuilder: (context, index) {
                  final item = menus[index];
                  return ListTile(
                    leading: Icon(item['icon'] as IconData, color: primary, size: 22),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DfColors.textColor(context),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (item.containsKey('index')) {
                        Get.offAllNamed('/home', arguments: {'index': item['index']});
                      } else {
                        Navigator.pushNamed(context, item['route'] as String);
                      }
                    },
                  );
                },
              ),
            ),
            // Logout
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: DfColors.red),
              title: Text(
                'logout'.tr,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DfColors.red,
                ),
              ),
              onTap: _logout,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${'app_version'.tr} v$_version',
                style: TextStyle(fontSize: 11, color: DfColors.dimTextColor(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
