class ZoneModel {
  final String id;
  final String name;
  final String branchId;
  final bool isActive;

  const ZoneModel({
    required this.id,
    required this.name,
    required this.branchId,
    required this.isActive,
  });

  factory ZoneModel.fromMap(Map<String, dynamic> map) {
    return ZoneModel(
      id: map['id'] as String,
      name: map['name'] as String,
      branchId: map['branchId'] as String,
      isActive: map['isActive'] as bool,
    );
  }
}
