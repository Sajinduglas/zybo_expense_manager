import 'package:equatable/equatable.dart';
import '../../data/repositories/sync_repository.dart';

abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

/// Default idle state with the last-synced time (null = never).
class SyncIdle extends SyncState {
  final String? lastSyncedTime;

  const SyncIdle({this.lastSyncedTime});

  @override
  List<Object?> get props => [lastSyncedTime];
}

/// Sync is in progress — used to drive the spinning animation.
class SyncInProgress extends SyncState {
  const SyncInProgress();
}

/// Sync completed successfully.
class SyncSuccess extends SyncState {
  final SyncResult result;

  const SyncSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

/// Sync failed with an error message.
class SyncFailure extends SyncState {
  final String message;

  const SyncFailure(this.message);

  @override
  List<Object?> get props => [message];
}
