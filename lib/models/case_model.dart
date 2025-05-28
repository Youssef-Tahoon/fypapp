class Case {
  final String? id;
  final String? title;
  final String description;
  final double amountNeeded;
  final String submittedBy;
  final String status;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;

  Case({
    this.id,
    this.title,
    required this.description,
    required this.amountNeeded,
    required this.submittedBy,
    this.status = 'pending',
    this.submittedAt,
    this.approvedAt,
    this.rejectedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'amountNeeded': amountNeeded,
      'submittedBy': submittedBy,
      'status': status,
      'submittedAt': submittedAt,
      'approvedAt': approvedAt,
      'rejectedAt': rejectedAt,
    };
  }

  factory Case.fromMap(Map<String, dynamic> map) {
    return Case(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      amountNeeded: (map['amountNeeded'] ?? 0).toDouble(),
      submittedBy: map['submittedBy'] ?? '',
      status: map['status'] ?? 'pending',
      submittedAt: map['submittedAt']?.toDate(),
      approvedAt: map['approvedAt']?.toDate(),
      rejectedAt: map['rejectedAt']?.toDate(),
    );
  }
}