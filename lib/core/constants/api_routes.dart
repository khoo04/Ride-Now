class ApiRoutes {
  static const baseUrl = "http://10.0.2.2:8000/api/RideNowV1";

  //Auth Route
  static const login = "$baseUrl/auth/login";
  static const register = "$baseUrl/auth/register";
  static const logout = "$baseUrl/auth/logout";
  static const getUserData = "$baseUrl/auth/user";

  //Vehicle Route
  /// Method : GET
  static const getVehicleType = "$baseUrl/vehicle/types";

  /// GET Method for [Access] current logged in user vehicles
  ///
  /// POST Method for [Create] new vehicles for current user
  ///
  /// PUT Method with wild card {vehicle_id} for [Update] particular vehicle information
  /// Eg. vehicle/{vehicle_id}
  ///
  /// DELETE Method with wild card {vehicle_id} for [Delete] particular vehicle
  /// Eg. vehicle/{vehicle_id}
  static const vehicle = "$baseUrl/vehicle";

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
  static const ride = "$baseUrl/ride";

  ///Method: GET
  ///
  /// Params : {ride_id} wild card
  ///
  /// E.g. details/{ride_id}
  static const rideDetails = "$baseUrl/ride/details";

  //Ride - Driver Route
  /// GET User Created Rides
  static const createdRides = "$baseUrl/ride/createdRides";

  //Ride - Passenger Route
  ///Route to Join Ride
  ///
  /// Method : POST
  ///
  /// E.g: join/{ride_id}
  static const joinRide = "$baseUrl/ride/join";

  ///Route to Search Ride
  ///
  ///Method : GET
  ///
  ///Supported Query Params: origin, destination, seats, departure_time
  static const searchRide = "$baseUrl/ride/search";

  ///Route to Get Joined Rides
  ///
  ///Method : GET
  ///
  ///Get All Joined Rides
  static const joinedRide = "$baseUrl/ride/joinedRide";

  static const autoCompleteApiRoute =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json";
}
