import 'dart:convert';
import 'package:http/http.dart' as http;


abstract class QoutesData {
  Future<QuoteResponse?> getQuote();
}

class GetQoutesClass implements QoutesData {
  @override
  Future<QuoteResponse?> getQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random?tags=love|happiness'),
      );
      if (response.statusCode == 200) {
        return QuoteResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (err) {
      return null;
    }
  }
}

QuoteResponse quoteResponseFromJson(String str) =>
    QuoteResponse.fromJson(json.decode(str));

String quoteResponseToJson(QuoteResponse data) => json.encode(data.toJson());

class QuoteResponse {
  QuoteResponse({
    this.id,
    this.content,
    this.author,
    this.tags,
    this.authorSlug,
    this.length,
    this.dateAdded,
    this.dateModified,
  });

  String? id;
  String? content;
  String? author;
  List<String>? tags;
  String? authorSlug;
  int? length;
  String? dateAdded;
  String? dateModified;

  QuoteResponse copyWith({
    String? id,
    String? content,
    String? author,
    List<String>? tags,
    String? authorSlug,
    int? length,
    String? dateAdded,
    String? dateModified,
  }) =>
      QuoteResponse(
        id: id ?? this.id,
        content: content ?? this.content,
        author: author ?? this.author,
        tags: tags ?? this.tags,
        authorSlug: authorSlug ?? this.authorSlug,
        length: length ?? this.length,
        dateAdded: dateAdded ?? this.dateAdded,
        dateModified: dateModified ?? this.dateModified,
      );

  factory QuoteResponse.fromJson(Map<String, dynamic> json) => QuoteResponse(
      id: json["_id"],
      content: json["content"],
      author: json["author"],
      tags: json["tags"] == null
          ? null
          : List<String>.from(json["tags"].map((x) => x)),
      authorSlug: json["authorSlug"],
      length: json["length"],
      dateAdded: json["dateAdded"],
      dateModified: json["dateModified"]);

  Map<String, dynamic> toJson() => {
    "_id": id,
    "content": content,
    "author": author,
    "tags": tags == null
        ? null
        : List<dynamic>.from((tags ?? []).map((x) => x)),
    "authorSlug": authorSlug,
    "length": length,
    "dateAdded": dateAdded == null,
    "dateModified": dateModified == null
  };
}
