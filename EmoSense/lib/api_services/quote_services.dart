import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class QoutesData {
  Future<QuoteResponse?> getQuote();
}

class GetQoutesClass implements QoutesData {
  @override
  Future<QuoteResponse?> getQuote() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedQuote = prefs.getString('quote');
      final int? lastFetchedTime = prefs.getInt('lastFetchedTime');
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      // Check if the cached quote is valid (within 24 hours)
      if (cachedQuote != null && lastFetchedTime != null) {
        final differenceInHours = (currentTime - lastFetchedTime) / (1000 * 60 * 60);
        if (differenceInHours < 24) {
          return QuoteResponse.fromJson(jsonDecode(cachedQuote));
        }
      }

      // Fetch new quote if cache is outdated or missing
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random?tags=happiness%7Clove%7Csadness'),
      );

      // Log rate limit headers
      print('Rate Limit: ${response.headers['x-ratelimit-limit']}');
      print('Rate Limit Remaining: ${response.headers['x-ratelimit-remaining']}');
      print('Rate Limit Reset: ${response.headers['x-ratelimit-reset']}');

      if (response.statusCode == 200) {
        final quoteResponse = QuoteResponse.fromJson(jsonDecode(response.body));

        // Cache the new quote and update the timestamp
        await prefs.setString('quote', jsonEncode(quoteResponse.toJson()));
        await prefs.setInt('lastFetchedTime', currentTime);

        return quoteResponse;
      } else if (response.statusCode == 429) {
        // Handle rate limit error (429 Too Many Requests)
        print('Error: Rate limit exceeded. Please try again later.');
        return null;
      } else {
        // Log the exact response for non-200 status codes
        print('Error: Failed to load quote, status code: ${response.statusCode}, body: ${response.body}');
        throw Exception('Failed to load quote');
      }
    } catch (err) {
      // Log the exact error message
      print('Error occurred: $err');
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

// if cannot fetch quote, use fallback quotes
class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});
}

// List of fallback quotes
final List<Quote> fallbackQuotes = [
  Quote(
    text: 'But feelings can’t be ignored, no matter how unjust or ungrateful they seem.',
    author: 'Anne Frank',
  ),
  Quote(
    text: 'I don’t want to be at the mercy of my emotions. I want to use them, to enjoy them, and to dominate them.',
    author: 'Oscar Wilde',
  ),
  Quote(
    text: 'Watch your thoughts, they become words; watch your words, they become actions; watch your actions, they become habits; watch your habits, they become character; watch your character, for it becomes your destiny.',
    author: 'Frank Outlaw',
  ),
  Quote(
    text: 'Believe in yourself and all that you are. Know that there is something inside of you that is greater than any obstacle.',
    author: 'Christian D Larson',
  ),
  Quote(
    text: 'You cannot make yourself feel something you do not feel, but you can make yourself do right in spite of your feelings.',
    author: 'Pearl S. Buck',
  ),
  Quote(
    text: 'The deepest feeling always shows itself in silence; not in silence, but restraint.',
    author: 'Marianne Moore',
  ),
  Quote(
    text: 'My feelings can perhaps be imagined, but they can hardly be described.',
    author: 'Yann Martel',
  ),
  Quote(
    text: 'It’s not sissy to show your feeling.',
    author: 'Princess Diana',
  ),
  Quote(
    text: 'One can be the master of what one does, but never of what one feels.',
    author: 'Gustave Flaubert',
  ),
  Quote(
    text: 'The best and most beautiful things in the world cannot be seen or even touched. They must be felt with the heart.',
    author: 'Helen Keller',
  ),
  Quote(
    text: 'They may forget what you said, but they will never forget how you made them feel.',
    author: 'Carl W. Buehner',
  ),
  Quote(
    text: 'Learning to stand in somebody else’s shoes, to see through their eyes, that’s how peace begins. And it’s up to you to make that happen.',
    author: 'Barack Obama',
  ),
  Quote(
    text: 'In order to move on, you must understand why you felt what you did and why you no longer need to feel it.',
    author: 'Mitch Albom',
  ),
  Quote(
    text: 'Sensitive people usually love deeply and hate deeply. They don’t know any other way to live than by extremes because their emotional thermostat is broken.',
    author: 'Shannon L. Alder',
  ),
  Quote(
    text: 'It’s easier to whisper your feelings than to trumpet them forth out loud.',
    author: 'Anne Frank',
  ),
];