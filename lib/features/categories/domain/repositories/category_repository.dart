import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<CategoryEntity> addCategory(String name);
  Future<void> deleteCategory(String id);
  // Methods for sync engine
  Future<List<CategoryEntity>> getUnsyncedCategories();
  Future<List<CategoryEntity>> getDeletedCategories();
  Future<void> markAsSynced(List<String> ids);
  Future<void> permanentlyDelete(List<String> ids);
  Future<void> syncFromCloud(List<CategoryEntity> cloudCategories);
}
