class Case {
  final String? id;
  final String? title;
  final String description;
  final double amountNeeded;
  final double amountRaised;
  final String submittedBy;
  final String userEmail;
  final String? proofUrl;
  final String status;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final List<Map<String, dynamic>>? donations;

  Case({
    this.id,
    this.title,
    required this.description,
    required this.amountNeeded,
    this.amountRaised = 0.0,
    required this.submittedBy,
    required this.userEmail,
    this.proofUrl,
    this.status = 'pending',
    this.submittedAt,
    this.approvedAt,
    this.rejectedAt,
    this.donations,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'amountNeeded': amountNeeded,
      'amountRaised': amountRaised,
      'submittedBy': submittedBy,
      'userEmail': userEmail,
      'proofUrl': proofUrl,
      'status': status,
      'submittedAt': submittedAt,
      'approvedAt': approvedAt,
      'rejectedAt': rejectedAt,
      'donations': donations,
    };
  }

  factory Case.fromMap(Map<String, dynamic> map) {
    return Case(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      amountNeeded: (map['amountNeeded'] ?? 0).toDouble(),
      amountRaised: (map['amountRaised'] ?? 0).toDouble(),
      submittedBy: map['submittedBy'] ?? '',
      userEmail: map['userEmail'] ?? '',
      proofUrl: map['proofUrl'],
      status: map['status'] ?? 'pending',
      submittedAt: map['submittedAt']?.toDate(),
      approvedAt: map['approvedAt']?.toDate(),
      rejectedAt: map['rejectedAt']?.toDate(),
      donations: List<Map<String, dynamic>>.from(map['donations'] ?? []),
    );
  }

  double get progressPercentage => (amountRaised / amountNeeded) * 100;
}