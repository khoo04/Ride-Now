class ApiRoutes {
  // static const baseUrl = "http://10.0.2.2:8000/api/RideNowV1";
  static const baseUrl = "https://khoodev.blog";
  //static const baseUrl = "http://192.168.0.162:8000";
  static const apiBaseUrl = "$baseUrl/api/RideNowV1";

  //Stagging
  //static const baseUrl = "https://staging.khoodev.us.kg/api/RideNowV1";

  //Boardcasting Auth Route
  static const broadcastingAuthEndpoints = "$baseUrl/broadcasting/auth";

  //Auth Route
  static const login = "$apiBaseUrl/auth/login";
  static const register = "$apiBaseUrl/auth/register";
  static const logout = "$apiBaseUrl/auth/logout";
  static const getUserData = "$apiBaseUrl/auth/user";

  //Vehicle Route
  /// Method : GET
  static const getVehicleType = "$apiBaseUrl/vehicle/types";

  /// GET Method for [Access] current logged in user vehicles
  ///
  /// POST Method for [Create] new vehicles for current user
  ///
  /// PUT Method with wild card {vehicle_id} for [Update] particular vehicle information
  /// Eg. vehicle/{vehicle_id}
  ///
  /// DELETE Method with wild card {vehicle_id} for [Delete] particular vehicle
  /// Eg. vehicle/{vehicle_id}
  static const vehicle = "$apiBaseUrl/vehicle";

  //Ride Route
  /// Method : GET,  Query Params: page, to get all available ride with pagination
  ///
  /// POST Method for [Create] new rides
  ///
  /// PUT Method with wild card {ride_id} for [Update] particular rides information
  /// Eg. ride/{ride_id}
  ///
  /// DELETE Method with wild card {ride_id} for [Delete] particular vehicle
  /// Eg. ride/{ride_id}
  static const ride = "$apiBaseUrl/ride";

  ///Method: GET
  ///
  /// Params : {ride_id} wild card
  ///
  /// E.g. details/{ride_id}
  static const rideDetails = "$apiBaseUrl/ride/details";

  //Ride - Driver Route
  /// GET User Created Rides
  static const createdRides = "$apiBaseUrl/ride/createdRides";

  /// Route to Start Ride
  /// Method: POST
  /// E.g: start/{ride_id}
  static const startRide = "$apiBaseUrl/ride/start";

  /// Route to Complete Ride
  /// Method: POST
  /// E.g: complete/{ride_id}
  static const completeRide = "$apiBaseUrl/ride/complete";

  //Ride - Passenger Route
  ///Route to Join Ride
  ///
  /// Method : POST
  ///
  /// E.g: join/{ride_id}
  static const joinRide = "$apiBaseUrl/ride/join";

  ///Route to Rate Ride
  ///
  /// Method: POST
  ///
  /// E.g.: rate/{ride_id}
  static const rateRide = "$apiBaseUrl/ride/rate";

  ///Route to Search Ride
  ///
  ///Method : GET
  ///
  ///Supported Query Params: origin, destination, seats, departure_time
  static const searchRide = "$apiBaseUrl/ride/search";

  /// Route to Leave Ride
  /// Method: POST
  /// E.g: leave/{ride_id}
  static const leaveRide = "$apiBaseUrl/ride/leave";

  ///Route to Get Joined Rides
  ///
  ///Method : GET
  ///
  ///Get All Joined Rides
  static const joinedRides = "$apiBaseUrl/ride/joinedRides";

  ///User Route
  static const profile = "$apiBaseUrl/users";

  ///Route to get users vouchers
  /// Method: GET
  static const vouchers = "$profile/vouchers";

  ///Route to get users balance
  /// Method: GET
  static const balance = "$profile/balance";

  ///Route to update user profile
  ///Method: POST
  static const updateProfile = "$profile/update";

  static const autoCompleteApiRoute =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json";

  static const placeDetailsApiRoute =
      "https://maps.googleapis.com/maps/api/place/details/json";

  static const geocodingApiRoute =
      "https://nominatim.openstreetmap.org/reverse";

  static const distanceBetweenTwoPoint =
      "https://maps.googleapis.com/maps/api/distancematrix/json";
}
