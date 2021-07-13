import 'package:algolia/algolia.dart';

class AlgoliaHelper{
  static final Algolia algolia = Algolia.init(
      applicationId: 'YOUR_APP_ID',
      apiKey: 'YOUR_API_KEY' // Search only API key
  );
}