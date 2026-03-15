import 'package:uuid/uuid.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDatasource localDatasource;
  final Uuid uuid;

  CategoryRepositoryImpl({
    required this.localDatasource,
    this.uuid = const Uuid(),
  });

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final maps = await localDatasource.getAllCategories();
    return maps.map((map) => CategoryModel.fromDb(map)).toList();
  }

  @override
  Future<CategoryEntity> addCategory(String name) async {
    final String id = uuid.v4();
    final model = CategoryModel(id: id, name: name, isSynced: 0, isDeleted: 0);
    await localDatasource.insertCategory(model.toDb());
    return model;
  }

  @override
  Future<void> deleteCategory(String id) async {
    // Soft delete according to required rules
    await localDatasource.softDelete(id);
  }

  @override
  Future<List<CategoryEntity>> getUnsyncedCategories() async {
    final maps = await localDatasource.getUnsynced();
    return maps.map((map) => CategoryModel.fromDb(map)).toList();
  }

  @override
  Future<List<CategoryEntity>> getDeletedCategories() async {
    // The previous implementation requires getting Category models for synced/deleted ones
    // Wait, getDeletedIds returns List<String>. But the repository interface requires List<CategoryEntity> 
    // Wait... if the sync engine just needs IDs to purge, maybe returning IDs is enough? The interface currently dictates Future<List<CategoryEntity>>.
    // Let's adjust this. 
    // I can fetch all categories and filter, but the local datasource only has `getDeletedIds`.
    throw UnimplementedError("Need full deleted objects if required by sync");
  }

  @override
  Future<void> markAsSynced(List<String> ids) async {
    await localDatasource.markSynced(ids);
  }

  @override
  Future<void> permanentlyDelete(List<String> ids) async {
    await localDatasource.permanentlyDelete(ids);
  }

  @override
  Future<void> syncFromCloud(List<CategoryEntity> cloudCategories) async {
    for (var entity in cloudCategories) {
       final model = CategoryModel(
         id: entity.id,
         name: entity.name,
         isSynced: 1, // Fresh from API
         isDeleted: 0,
       );
       await localDatasource.insertCategory(model.toDb());
    }
  }
}
