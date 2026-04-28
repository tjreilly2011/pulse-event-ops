class EventModel {
  final String id;
  final String eventType;
  final String status;
  final String? title;
  final String? description;
  final String createdAt;
  final String destinationLocationId;

  const EventModel({
    required this.id,
    required this.eventType,
    required this.status,
    this.title,
    this.description,
    required this.createdAt,
    required this.destinationLocationId,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      eventType: json['event_type'] as String,
      status: json['status'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String,
      destinationLocationId: json['destination_location_id'] as String,
    );
  }

  String get displayTitle => title ?? eventType;
}
