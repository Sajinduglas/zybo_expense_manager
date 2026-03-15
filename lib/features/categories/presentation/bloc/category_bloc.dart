import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc({required this.repository}) : super(CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(LoadCategoriesEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final categories = await repository.getCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onAddCategory(AddCategoryEvent event, Emitter<CategoryState> emit) async {
    if (state is CategoryLoaded) {
      final currentState = state as CategoryLoaded;
      try {
        final newCategory = await repository.addCategory(event.name);
        // Optimistic update
        final newCategories = List.of(currentState.categories)..insert(0, newCategory);
        emit(CategoryLoaded(newCategories));
      } catch (e) {
        emit(CategoryError(e.toString()));
        // Re-emit old state
        emit(CategoryLoaded(currentState.categories));
      }
    }
  }

  Future<void> _onDeleteCategory(DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    if (state is CategoryLoaded) {
      final currentState = state as CategoryLoaded;
      
      // Optimistic delete: remove instantly from UI
      final previousCategories = currentState.categories;
      final newCategories = previousCategories.where((c) => c.id != event.id).toList();
      emit(CategoryLoaded(newCategories));

      try {
        await repository.deleteCategory(event.id);
      } catch (e) {
        // Rollback on failure
        emit(CategoryError("Failed to delete category"));
        emit(CategoryLoaded(previousCategories));
      }
    }
  }
}
