import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final int isSynced;
  final int isDeleted;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.isSynced = 0,
    this.isDeleted = 0,
  });

  @override
  List<Object?> get props => [id, name, isSynced, isDeleted];

  // Helper method for soft deletes and local modifications
  CategoryEntity copyWith({
    String? id,
    String? name,
    int? isSynced,
    int? isDeleted,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
