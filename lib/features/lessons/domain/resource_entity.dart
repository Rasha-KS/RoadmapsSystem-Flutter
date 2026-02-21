enum ResourceType { youtube, book }

class ResourceEntity {
  final String id;
  final ResourceType type;
  final String title;
  final String link;

  const ResourceEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.link,
  });
}
