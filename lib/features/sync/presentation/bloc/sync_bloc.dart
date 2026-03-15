import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/sync_repository.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncRepository _repository;

  SyncBloc({required SyncRepository repository})
      : _repository = repository,
        super(SyncIdle(lastSyncedTime: repository.getLastSyncedTime())) {
    on<LoadSyncStatusEvent>(_onLoadStatus);
    on<TriggerSyncEvent>(_onTriggerSync);
  }

  void _onLoadStatus(LoadSyncStatusEvent event, Emitter<SyncState> emit) {
    emit(SyncIdle(lastSyncedTime: _repository.getLastSyncedTime()));
  }

  Future<void> _onTriggerSync(
      TriggerSyncEvent event, Emitter<SyncState> emit) async {
    emit(const SyncInProgress());
    try {
      final result = await _repository.runSync();
      emit(SyncSuccess(result));
      // Return to idle with updated timestamp
      emit(SyncIdle(lastSyncedTime: _repository.getLastSyncedTime()));
    } catch (e) {
      emit(SyncFailure(e.toString().replaceFirst('Exception: ', '')));
      emit(SyncIdle(lastSyncedTime: _repository.getLastSyncedTime()));
    }
  }
}
