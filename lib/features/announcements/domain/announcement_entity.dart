class AnnouncementEntity {
  final int id;
  final String title;
  final String description;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? link;
  final bool isActive;

  AnnouncementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.endsAt,
    required this.isActive,
    this.link,
  });
}
