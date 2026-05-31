import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/ios_status_bar.dart';
import 'collections_tab.dart';
import 'favorites_tab.dart';
import 'history_tab.dart';
import 'own_quotes_tab.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _controller = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const IosStatusSpacer(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MirraSpace.lg),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Library',
                      style: MirraType.title.copyWith(fontSize: 26)),
                ],
              ),
            ),
            const SizedBox(height: MirraSpace.md),
            TabBar(
              controller: _controller,
              isScrollable: true,
              padding: const EdgeInsets.symmetric(horizontal: MirraSpace.lg),
              labelStyle:
                  MirraType.ui(size: 14, weight: FontWeight.w600),
              unselectedLabelStyle:
                  MirraType.ui(size: 14, weight: FontWeight.w500),
              labelColor: MirraColors.ink,
              unselectedLabelColor: MirraColors.muted,
              indicatorColor: MirraColors.ink,
              indicatorWeight: 2.5,
              dividerColor: Colors.transparent,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Favorites'),
                Tab(text: 'Collections'),
                Tab(text: 'History'),
                Tab(text: 'My quotes'),
              ],
            ),
            const Divider(height: 1, color: MirraColors.line),
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: const [
                  FavoritesTab(),
                  CollectionsTab(),
                  HistoryTab(),
                  OwnQuotesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
