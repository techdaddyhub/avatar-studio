import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/avatar_provider.dart';
import 'providers/billing_provider.dart';
import 'providers/tracking_provider.dart';
import 'providers/audio_sync_provider.dart';
import 'providers/obs_provider.dart';
import 'providers/hardware_provider.dart';
import 'providers/license_provider.dart';
import 'widgets/sidebar_nav.dart';
import 'widgets/top_status_bar.dart';
import 'views/dashboard/dashboard_view.dart';
import 'views/studio/live_studio_view.dart';
import 'views/library/avatar_library_view.dart';
import 'views/creator/avatar_creator_view.dart';
import 'views/tracking/face_tracking_view.dart';
import 'views/audio/voice_lipsync_view.dart';
import 'views/obs/obs_integration_view.dart';
import 'views/scenes/scenes_backgrounds_view.dart';
import 'views/performance/performance_settings_view.dart';
import 'views/account/account_subscription_view.dart';
import 'views/diagnostics/diagnostics_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  runApp(AvatarStudioApp(storageService: storageService));
}

class AvatarStudioApp extends StatelessWidget {
  final StorageService? storageService;

  const AvatarStudioApp({super.key, this.storageService});

  @override
  Widget build(BuildContext context) {
    final storage = storageService ?? StorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AvatarProvider(storage)),
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
        ChangeNotifierProvider(create: (_) => AudioSyncProvider()),
        ChangeNotifierProvider(create: (_) => ObsProvider()),
        ChangeNotifierProvider(create: (_) => HardwareProvider()),
        ChangeNotifierProvider(create: (_) => LicenseProvider()),
        ChangeNotifierProvider(
          create: (_) => BillingProvider(storageService: storage),
        ),
      ],
      child: MaterialApp(
        title: 'Avatar Studio — Real-Time 3D Desktop Studio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const StudioMainShell(),
      ),
    );
  }
}

class StudioMainShell extends StatefulWidget {
  const StudioMainShell({super.key});

  @override
  State<StudioMainShell> createState() => _StudioMainShellState();
}

class _StudioMainShellState extends State<StudioMainShell> {
  StudioSection _currentSection = StudioSection.dashboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TopStatusBar(),
          Expanded(
            child: Row(
              children: [
                SidebarNav(
                  currentSection: _currentSection,
                  onSectionSelected: (section) {
                    setState(() {
                      _currentSection = section;
                    });
                  },
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentSection.index,
                    children: [
                      DashboardView(
                        onNavigate: (section) {
                          setState(() {
                            _currentSection = section;
                          });
                        },
                      ),
                      const LiveStudioView(),
                      const AvatarLibraryView(),
                      const AvatarCreatorView(),
                      const FaceTrackingView(),
                      const VoiceLipsyncView(),
                      const ObsIntegrationView(),
                      const ScenesBackgroundsView(),
                      const PerformanceSettingsView(),
                      const AccountSubscriptionView(),
                      const DiagnosticsView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
