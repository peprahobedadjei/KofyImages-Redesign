class ApiEndpoints {
  static const String baseUrl = 'https://kofyimages-9dae18892c9f.herokuapp.com';

  // Cities endpoints
    static const String getallpictures = '$baseUrl/api/picture-frames/';
      static const String getallpaintings = '$baseUrl/api/painting-frames/';
  static const String postphoto = '$baseUrl/api/lifestyle-photos/';
    static const String getAllCities = '$baseUrl/api/cities/';
      static const String forgottenpassword = '$baseUrl/api/auth/forgot-password/';
    static String postCityLike(String cityName) =>
      '$baseUrl/api/cities/$cityName/like_city/';
    static const String getAllHeroImages = '$baseUrl/api/city_photos/';
  static String getCityReviews(String cityName) =>
      '$baseUrl/api/cities/$cityName/reviews/';
  static String postCityReviews(String cityName) =>
      '$baseUrl/api/cities/$cityName/add_review/';
  static const String getAllEvents = '$baseUrl/api/events/';
  static const String refreshToken = '$baseUrl/api/token/refresh/';
  static const String login = '$baseUrl/api/token/';
  static const String register = '$baseUrl/api/register/';
  static const String getAllPhotosOfTheWeek =
      '$baseUrl/api/lifestyle-photos/photos-of-week/';
  static String getCityDetails(String cityName) =>
      '$baseUrl/api/cities/$cityName/content/';
  static String getCityDetailsPhotos(String cityName) =>
      '$baseUrl/api/city_photos/$cityName/';
}
