class Visitor {
  final String passId;
  final String fullName;
  final String phone;
  final String email;
  final String visitorType;
  final String purpose;
  final String department;
  final String personToMeet;
  final DateTime entryTime;
  final DateTime? exitTime;
  String status;
  final String issuedBy;
  final String createdBy;

  Visitor({
    required this.passId,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.visitorType,
    required this.purpose,
    required this.department,
    required this.personToMeet,
    required this.entryTime,
    required this.exitTime,
    required this.status,
    required this.issuedBy,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() => {
    'passId': passId,
    'fullName': fullName,
    'phone': phone,
    'email': email,
    'visitorType': visitorType,
    'purpose': purpose,
    'department': department,
    'personToMeet': personToMeet,
    'entryTime': entryTime.millisecondsSinceEpoch,
    'exitTime': exitTime?.millisecondsSinceEpoch,
    'status': status,
    'issuedBy': issuedBy,
    'createdBy': createdBy,
  };

  factory Visitor.fromMap(Map<String, dynamic> m) => Visitor(
    passId: m['passId'] as String,
    fullName: m['fullName'] as String,
    phone: m['phone'] as String,
    email: m['email'] as String? ?? '',
    visitorType: m['visitorType'] as String,
    purpose: m['purpose'] as String,
    department: m['department'] as String,
    personToMeet: m['personToMeet'] as String? ?? '',
    entryTime: DateTime.fromMillisecondsSinceEpoch(m['entryTime'] as int),
    exitTime: m['exitTime'] != null
        ? DateTime.fromMillisecondsSinceEpoch(m['exitTime'] as int)
        : null,
    status: m['status'] as String,
    issuedBy: m['issuedBy'] as String,
    createdBy: m['createdBy'] as String? ?? '',
  );
}
