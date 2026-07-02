import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:field_track/features/todos/domain/entities/todo_entity.dart';
import 'package:field_track/features/todos/presentation/bloc/sync_bloc.dart';
import 'package:field_track/features/todos/presentation/widgets/sync_widgets.dart';
import 'package:field_track/shared/widgets/app_widgets.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  @override
  void initState() {
    super.initState();
    context.read<SyncBloc>().add(const SyncLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocListener<SyncBloc, SyncState>(
          listener: (context, state) {
            if (state.status == SyncStatus.failure &&
                state.errorMessage != null) {
              AppSnackBar.show(context, state.errorMessage!, isError: true);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: SyncSpacing.screen.copyWith(bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sync',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: SyncSpacing.titleBottom),
                    BlocSelector<SyncBloc, SyncState, bool>(
                      selector: (state) => !state.isOnline,
                      builder: (context, showOfflineBanner) {
                        if (!showOfflineBanner) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            const SyncOfflineBanner(),
                            SizedBox(height: SyncSpacing.section),
                          ],
                        );
                      },
                    ),
                    BlocSelector<SyncBloc, SyncState, (int, String)>(
                      selector: (state) =>
                          (state.pendingCount, state.lastSyncedLabel),
                      builder: (context, summary) {
                        final (pendingCount, lastSyncedLabel) = summary;
                        return SyncSummaryCard(
                          pendingCount: pendingCount,
                          lastSyncedLabel: lastSyncedLabel,
                        );
                      },
                    ),
                    SizedBox(height: SyncSpacing.section),
                    Text(
                      'WAITING TO UPLOAD',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: secondary,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: SyncSpacing.listTop),
                  ],
                ),
              ),
              Expanded(
                child: BlocSelector<SyncBloc, SyncState, List<PendingSyncChange>>(
                  selector: (state) => state.pendingChanges,
                  builder: (context, pendingChanges) {
                    if (pendingChanges.isEmpty) {
                      return const Center(child: SyncEmptyState());
                    }
                    return ListView.separated(
                      padding: SyncSpacing.screen.copyWith(top: 0),
                      itemCount: pendingChanges.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final change = pendingChanges[index];
                        return SyncPendingTile(
                          title: change.title,
                          actionLabel: change.actionLabel,
                          icon: syncIconForTitle(change.title),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: SyncSpacing.screen,
                child: BlocSelector<SyncBloc, SyncState, (bool, bool)>(
                  selector: (state) => (state.canSync, state.isSyncing),
                  builder: (context, actionState) {
                    final (canSync, isSyncing) = actionState;
                    return SyncActionButton(
                      enabled: canSync,
                      isLoading: isSyncing,
                      onPressed: () => context.read<SyncBloc>().add(
                            const SyncNowRequested(force: true),
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
