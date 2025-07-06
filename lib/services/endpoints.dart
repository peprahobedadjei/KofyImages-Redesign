class ApiEndpoints {
  static const String baseUrl = 'https://kofyimages-9dae18892c9f.herokuapp.com';
  
  // Cities endpoints
  static const String getAllCities = '$baseUrl/api/cities/';
  static const String getAllPhotosOfTheWeek = '$baseUrl/api/lifestyle-photos/photos-of-week/';
  static const String getAllHeroPictures = '$baseUrl/api/city_photos/';
  static String getCityDetails(String cityName) => '$baseUrl/api/cities/$cityName/content/';
  static String getCityDetailsPhotos(String cityName) => '$baseUrl/api/city_photos/$cityName/';

}