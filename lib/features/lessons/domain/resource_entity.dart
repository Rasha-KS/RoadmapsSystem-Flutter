enum ResourceType { article, video, book, other }

class ResourceEntity {
  final int id;
  final String title;
  final ResourceType type;
  final String language;
  final String link;

  const ResourceEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.language,
    required this.link,
  });
}
