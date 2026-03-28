class ReservationBranchModel {
  final String id;
  final String name;

  const ReservationBranchModel({required this.id, required this.name});

  factory ReservationBranchModel.fromMap(Map<String, dynamic> json) {
    return ReservationBranchModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class ReservationZoneModel {
  final String id;
  final String name;

  const ReservationZoneModel({required this.id, required this.name});

  factory ReservationZoneModel.fromMap(Map<String, dynamic> json) {
    return ReservationZoneModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class ReservationModel {
  final String id;
  final String reservationDate;
  final String reservationTime;
  final int guestCount;
  final String branchId;
  final String zoneId;
  final String eventType;
  final String customerName;
  final String phonePrimary;
  final String? phoneSecondary;
  final String? notes;
  final String status;
  final ReservationBranchModel? branch;
  final ReservationZoneModel? zone;

  const ReservationModel({
    required this.id,
    required this.reservationDate,
    required this.reservationTime,
    required this.guestCount,
    required this.branchId,
    required this.zoneId,
    required this.eventType,
    required this.customerName,
    required this.phonePrimary,
    required this.phoneSecondary,
    required this.notes,
    required this.status,
    required this.branch,
    required this.zone,
  });

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      id: map['id'] as String,
      reservationDate: map['reservationDate'] as String,
      reservationTime: map['reservationTime'] as String,
      guestCount: map['guestCount'] as int,
      branchId: map['branchId'] as String,
      zoneId: map['zoneId'] as String,
      eventType: map['eventType'] as String,
      customerName: map['customerName'] as String,
      phonePrimary: map['phonePrimary'] as String,
      phoneSecondary: map['phoneSecondary'] as String,
      notes: map['notes'] as String,
      status: map['status'] as String,
      branch: map['branch'] != null && (map['branch'] as Map).containsKey('id')
          ? ReservationBranchModel.fromMap(
              map['branch'] as Map<String, dynamic>,
            )
          : null,
      zone: map['zone'] != null && (map['zone'] as Map).containsKey('id')
          ? ReservationZoneModel.fromMap(map['zone'] as Map<String, dynamic>)
          : null,
    );
  }
}
