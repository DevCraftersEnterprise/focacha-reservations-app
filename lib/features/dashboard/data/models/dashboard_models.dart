class DashboardCalendarItem {
  final String date;
  final int count;

  const DashboardCalendarItem({required this.date, required this.count});

  factory DashboardCalendarItem.fromMap(Map<String, dynamic> map) {
    return DashboardCalendarItem(
      date: map['date'] as String,
      count: map['count'] as int,
    );
  }
}

class DashboardReservationItem {
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
  final DashboardZoneInfo? zone;

  const DashboardReservationItem({
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
    required this.zone,
  });

  factory DashboardReservationItem.fromMap(Map<String, dynamic> map) {
    return DashboardReservationItem(
      id: map['id'] as String,
      reservationDate: map['reservationDate'] as String,
      reservationTime: map['reservationTime'] as String,
      guestCount: map['guestCount'] as int,
      branchId: map['branchId'] as String,
      zoneId: map['zoneId'] as String,
      eventType: map['eventType'] as String,
      customerName: map['customerName'] as String,
      phonePrimary: map['phonePrimary'] as String,
      phoneSecondary: map['phoneSecondary'] as String?,
      notes: map['notes'] as String?,
      status: map['status'] as String,
      zone: map['zone'] != null
          ? DashboardZoneInfo.fromMap(map['zone'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DashboardZoneInfo {
  final String id;
  final String name;

  const DashboardZoneInfo({required this.id, required this.name});

  factory DashboardZoneInfo.fromMap(Map<String, dynamic> map) {
    return DashboardZoneInfo(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }
}

class DashboardDayDetail {
  final String date;
  final String branchId;
  final int total;
  final int activeCount;
  final int cancelledCount;
  final List<DashboardReservationItem> items;

  const DashboardDayDetail({
    required this.date,
    required this.branchId,
    required this.total,
    required this.activeCount,
    required this.cancelledCount,
    required this.items,
  });

  factory DashboardDayDetail.fromMap(Map<String, dynamic> map) {
    return DashboardDayDetail(
      date: map['date'] as String,
      branchId: map['branchId'] as String,
      total: map['total'] as int,
      activeCount: map['activeCount'] as int,
      cancelledCount: map['cancelledCount'] as int,
      items: (map['items'] as List<dynamic>)
          .map(
            (item) =>
                DashboardReservationItem.fromMap(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
