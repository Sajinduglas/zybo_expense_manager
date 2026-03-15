import 'package:equatable/equatable.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger the full sync workflow.
class TriggerSyncEvent extends SyncEvent {
  const TriggerSyncEvent();
}

/// Load the last synced time from prefs (called on page load).
class LoadSyncStatusEvent extends SyncEvent {
  const LoadSyncStatusEvent();
}
