import 'package:accountable/pages/file_upload_screen.dart';
import 'package:accountable/pages/home_page.dart';
import 'package:accountable/pages/summary_screen.dart';
import 'package:accountable/pages/transaction_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomePageKey = GlobalKey<NavigatorState>(debugLabel: 'HomePage');
final _shellNavigatorNewPageKey = GlobalKey<NavigatorState>(debugLabel: 'NewPage');
final _shellNavigatorSummaryPageKey = GlobalKey<NavigatorState>(debugLabel: 'SummaryPage');



final goRouter = GoRouter(
  initialLocation: '/HomePage',
  // * Passing a navigatorKey causes an issue on hot reload:
  // * https://github.com/flutter/flutter/issues/113757#issuecomment-1518421380
  // * However it's still necessary otherwise the navigator pops back to
  // * root on hot reload
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomePageKey,
          routes: [
            GoRoute(
              path: '/HomePage',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomePage( detailsPath: '/HomePage/transaction_details'),
              ),
              routes: [
                GoRoute(
                  path: 'transaction_details',
                  builder: (context, state) => const TransactionDetailScreen(),
                ),
                // GoRoute(
                //   path: 'sth',
                //   builder: (context, state) => const TransactionDetailScreen(),
                // ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorNewPageKey,
          routes: [
            
            GoRoute(
              path: '/UploadPage',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: FileUploadScreen(),
              ),
              routes: const [
                // GoRoute(
                //   path: 'details',
                //   builder: (context, state) => const DetailsScreen(label: 'B'),
                // ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSummaryPageKey,
          routes: [
            
            GoRoute(
              path: '/SummaryPage',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: BudgetSummaryScreen(),
              ),
              routes: [
                // GoRoute(
                //   path: 'details',
                //   builder: (context, state) => const DetailsScreen(label: 'B'),
                // ),
              ],
            ),
          ],
        ),
        
      ],
    ),
  ],
);

void main() {
  // turn off the # in the URLs on the web
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
    );
  }
}

// Stateful navigation based on:
// https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
  }) : super(
            key: key ?? const ValueKey<String>('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
     
        return ScaffoldWithNavigationBar(
          body: navigationShell,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
        );
      } 
    );
  }
}

class ScaffoldWithNavigationBar extends StatelessWidget {
  const ScaffoldWithNavigationBar({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(label: 'Home', icon: Icon(Icons.home)),
          NavigationDestination(label: 'New', icon: Icon(Icons.add)),
          NavigationDestination(label: 'Summary', icon: Icon(Icons.add_chart)),
        ],
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}



