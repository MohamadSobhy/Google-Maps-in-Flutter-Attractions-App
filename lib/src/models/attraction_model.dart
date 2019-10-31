import 'package:google_maps_flutter/google_maps_flutter.dart';

class Attraction {
  String attractionName;
  String address;
  String description;
  String thumbnail;
  LatLng locationCoords;

  Attraction(
      {this.attractionName,
      this.address,
      this.description,
      this.thumbnail,
      this.locationCoords});
}
