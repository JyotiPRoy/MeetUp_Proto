
import 'dart:convert';

import 'package:http/http.dart' as http;

const String PEXEL_API_KEY = '563492ad6f917000010000016c8a76879ea448ed9200efe34d541712';

class PexelImageProvider{
  static String searchBy = 'Nature%20ultra%20wide';
  static int perPage = 1;
  static int pageNumber = 4;
  static int currentInPage = 0;
  static String _currentImgUrl = ''; //Cache

  /// Since we have a monthly/hourly limit on the Pexel Api, so we're
  /// storing the current url in a var so that we don't call the api
  /// everytime the caller widget is rebuilt.
  static Future<String?> get imageUrl async {
    if(_currentImgUrl == ''){
      var response = await http.get(
          Uri.parse("https://api.pexels.com/v1/search?query=$searchBy&per_page=$perPage&page=$pageNumber"),
          headers: {'Authorization' : PEXEL_API_KEY}
      );
      print('Response: ${response.body}');
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      String imgUrl = jsonResponse['photos'][currentInPage]['src']['large'];
      _currentImgUrl = imgUrl;
      return imgUrl;
    }else return _currentImgUrl;
    // return null;
  }

  /// Use when the user wants to refresh the widget manually to load a
  /// different picture
  static Future<String?> get newImgUrl async {
    _currentImgUrl = '';
    pageNumber++;
    return await imageUrl;
  }
}