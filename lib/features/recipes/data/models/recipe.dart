class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    this.sourceLink,
    this.content,
  });

  final String id;
  final String title;
  final String? sourceLink;
  final String? content;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'sourceLink': sourceLink,
      'content': content,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      title: map['title'] as String,
      sourceLink: map['sourceLink'] as String?,
      content: map['content'] as String?,
    );
  }
}
