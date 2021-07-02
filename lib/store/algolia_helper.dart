import 'package:algolia/algolia.dart';

class AlgoliaHelper{
  static final Algolia algolia = Algolia.init(
      applicationId: 'EEXNRRTCX0',
      apiKey: '76aa82986de2b65cd8cc5ea01b187434' // Search only API key
  );
}