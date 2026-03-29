class BranchModel {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final bool isActive;

  const BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.isActive,
  });

  factory BranchModel.fromMap(Map<String, dynamic> map) {
    return BranchModel(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      phone: map['phone'] as String?,
      isActive: map['isActive'] as bool,
    );
  }
}
