import '../../domain/entities/category_entity.dart';
import '../../../../core/constants/db_constants.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    super.isSynced = 0,
    super.isDeleted = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      // Default to synced 1 if from API (API returns categories without synced/deleted flags typically)
      // But if it's from local DB, use the DB's flags.
      isSynced: json[DbConstants.colIsSynced] ?? 1,
      isDeleted: json[DbConstants.colIsDeleted] ?? 0,
    );
  }

  factory CategoryModel.fromDb(Map<String, dynamic> map) {
    return CategoryModel(
      id: map[DbConstants.colId] as String,
      name: map[DbConstants.colName] as String,
      isSynced: map[DbConstants.colIsSynced] as int,
      isDeleted: map[DbConstants.colIsDeleted] as int,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      DbConstants.colId: id,
      DbConstants.colName: name,
      DbConstants.colIsSynced: isSynced,
      DbConstants.colIsDeleted: isDeleted,
    };
  }
  
  // For uploading to API
  Map<String, dynamic> toJson() {
    return {
      'category_id': id,
      'name': name,
    };
  }
}
