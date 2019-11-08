import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import './../mixins/marker_icon_maker_mixin.dart';
import './../mixins/attractions_data_mixin.dart';
import './../widgets/attraction_card.dart';
import './../widgets/map_control_button.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AttractionDataMixin, MarkerIconMakerMixin {
  GoogleMapController _mapController;
  TextEditingController _myLocationFieldController = TextEditingController();
  TextEditingController _destinationFieldController = TextEditingController();
  LatLng _initialLocation;
  Set<Marker> _attractionMarkerList = Set();
  Marker currentDestMarker;
  Set<Polyline> _routesPolylines = Set();
  PageController _pageController;
  MapStyle _currentMapStyle = MapStyle.normal;
  MapType _mapType;
  double _currentZoom = 15.0;
  BuildContext scaffoldContext;
  static const double MAX_ZOOM_VALUE = 21.0;
  static const double MIN_ZOOM_VALUE = 0.0;
  static const String _apiRootDomain =
      'http://router.project-osrm.org/route/v1/driving';

  @override
  void initState() {
    super.initState();

    initializeMarkers();

    _pageController = PageController(initialPage: 0, viewportFraction: 0.8)
      ..addListener(_onPageViewScrolled);
  }

  void _onPageViewScrolled() {
    _moveCameraToSelectedAttraction(_pageController.page.toInt(), false);
  }

  Future<bool> initializeMarkers() async {
    try {
      //getting the current user location
      final Position userPosition = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      _initialLocation = LatLng(userPosition.latitude, userPosition.longitude);

      // List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(
      //     userPosition.latitude, userPosition.longitude);
      // _myLocationFieldController.text = placemarks[0].name;

    } catch (PlatformException) {
      _initialLocation = attractionList.first.locationCoords;
    }

    final Uint8List markerIcon =
        //await getMakerIconFromAssets('assets/images/marker_icon.png', 80);
        await getBytesFromCanvas(40, 40);

    _attractionMarkerList.addAll(attractionList.map(
      (attraction) {
        return Marker(
          markerId: MarkerId(attraction.attractionName),
          draggable: false,
          icon: BitmapDescriptor.fromBytes(markerIcon),
          infoWindow: InfoWindow(
              title: attraction.attractionName,
              snippet: attraction.address,
              onTap: () {
                _pageController.animateToPage(
                  attractionList.indexOf(attraction),
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              }),
          position: attraction.locationCoords,
        );
      },
    ).toSet());

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    switch (_currentMapStyle) {
      case MapStyle.normal:
        _mapType = MapType.normal;
        break;
      case MapStyle.hybird:
        _mapType = MapType.hybrid;
        break;
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: FutureBuilder(
        future: initializeMarkers(),
        builder: (BuildContext ctx, snapshot) {
          scaffoldContext = ctx;
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );

          return Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              _buildGoogleMap(mediaQuery),
              _buildSearchPanel(mediaQuery),
              _buildFavoriteAttractionsList(mediaQuery),
              _buildControlButtons(),
            ],
          );
        },
      ),
    );
  }

  Container _buildGoogleMap(MediaQueryData mediaQuery) {
    return Container(
      height: mediaQuery.size.height,
      width: mediaQuery.size.width,
      child: GoogleMap(
        mapType: _mapType,
        mapToolbarEnabled: false,
        compassEnabled: false,
        initialCameraPosition: CameraPosition(
          target: _initialLocation,
          zoom: _currentZoom - 2,
        ),
        onMapCreated: _onMapCreatedCallback,
        markers: _attractionMarkerList,
        polylines: _routesPolylines,
        onCameraMove: (cameraPosition) {
          setState(() {
            _currentZoom = cameraPosition.zoom;
          });
        },
        myLocationEnabled: true,
      ),
    );
  }

  Widget _buildSearchPanel(MediaQueryData mediaQuery) {
    return Positioned(
      top: 70.0,
      left: 20.0,
      right: 20.0,
      child: Column(
        children: <Widget>[
          Container(
            height: 50.0,
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            width: mediaQuery.size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  blurRadius: 4.0,
                  color: Colors.black38,
                ),
              ],
            ),
            child: TextField(
              controller: _myLocationFieldController,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Your Location',
                icon: Icon(
                  Icons.my_location,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          Container(
            height: 50.0,
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            width: mediaQuery.size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  blurRadius: 4.0,
                  color: Colors.black38,
                ),
              ],
            ),
            child: TextField(
              controller: _destinationFieldController,
              cursorColor: Theme.of(context).primaryColor,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Your Destination',
                icon: Icon(
                  Icons.directions_transit,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onSubmitted: _drawRoutesBetweenSourceAndDestination,
            ),
          )
        ],
      ),
    );
  }

  void _drawRoutesBetweenSourceAndDestination(String destination) async {
    destination = destination.trim();
    String source = _myLocationFieldController.text.toString().trim();

    final List<Placemark> destPlacmarks =
        await Geolocator().placemarkFromAddress(destination);
    final Position destLocation = destPlacmarks[0].position;

    String url;

    if (source == '') {
      url =
          '$_apiRootDomain/${_initialLocation.longitude},${_initialLocation.latitude};${destLocation.longitude},${destLocation.latitude}.json';
    } else {
      final List<Placemark> sourcePlacmarks =
          await Geolocator().placemarkFromAddress(source);
      final Position sourceLocation = sourcePlacmarks[0].position;
      url =
          '$_apiRootDomain/${sourceLocation.longitude},${sourceLocation.latitude};${destLocation.longitude},${destLocation.latitude}.json';
    }

    print('request URL is: $url\n');

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> parsedJson = json.decode(response.body);
      String routesPolyline = parsedJson['routes'][0]['geometry'];

      final coorValues = _decodePoly(routesPolyline);
      List<LatLng> routesPoints = [];
      for (int i = 0; i < coorValues.length; i += 2) {
        routesPoints.add(LatLng(coorValues[i], coorValues[i + 1]));
      }

      final poly = Polyline(
        polylineId: PolylineId(routesPoints.toString()),
        points: routesPoints,
        width: 5,
        color: Colors.indigo,
      );

      final newDestMarker = Marker(
        markerId: MarkerId(
          routesPoints.last.toString(),
        ),
        position:
            LatLng(routesPoints.last.latitude, routesPoints.last.longitude),
        icon: BitmapDescriptor.defaultMarker,
        draggable: false,
        infoWindow: InfoWindow(
          title: destination,
        ),
      );

      setState(() {
        _routesPolylines = [poly].toSet();
        _attractionMarkerList.remove(currentDestMarker);
        _attractionMarkerList.add(newDestMarker);
        currentDestMarker = newDestMarker;
      });
    } else {
      print('Error fetching routes');
      Scaffold.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('API request failed!'),
        ),
      );
    }
  }

  // !DECODE POLY
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    // repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    /*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  Positioned _buildFavoriteAttractionsList(MediaQueryData mediaQuery) {
    return Positioned(
      bottom: 80.0,
      height: 140.0,
      width: mediaQuery.size.width,
      child: PageView.builder(
        controller: _pageController,
        itemCount: attractionList.length,
        itemBuilder: (BuildContext ctx, int index) {
          print(index);
          return AttractionCard(
            attractionList[index],
            _pageController,
            index,
            _moveCameraToSelectedAttraction,
          );
        },
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 20.0,
      right: 15.0,
      left: 15.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          MapControlButton(
            icon: Icons.zoom_out,
            onButtonPressed: _zoomOutButtonCallback,
          ),
          MapControlButton(
            icon: Icons.layers,
            onButtonPressed: _changeMapTypeCallback,
          ),
          MapControlButton(
            icon: Icons.zoom_in,
            onButtonPressed: _zoomInButtonCallback,
          ),
        ],
      ),
    );
  }

  void _changeMapTypeCallback() {
    print('Map Type changed to ${_currentMapStyle.toString()}');

    switch (_currentMapStyle) {
      case MapStyle.normal:
        _currentMapStyle = MapStyle.hybird;
        break;
      case MapStyle.hybird:
        _currentMapStyle = MapStyle.normal;
        break;
    }
    setState(() {});
  }

  void _zoomInButtonCallback() {
    setState(() {
      if (_currentZoom < MAX_ZOOM_VALUE) _currentZoom += 1.0;
      _onPageViewScrolled();
    });
    print('Zooming IN: $_currentZoom');
  }

  void _zoomOutButtonCallback() {
    setState(() {
      if (_currentZoom > MIN_ZOOM_VALUE) _currentZoom -= 1.0;
      _onPageViewScrolled();
    });
    print('Zooming OUT: $_currentZoom');
  }

  void _onMapCreatedCallback(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  void _moveCameraToSelectedAttraction(int index, bool clickedNotDragged) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: attractionList[index].locationCoords,
          zoom: _currentZoom,
          bearing: 50.0,
          tilt: 50.0,
        ),
      ),
    );

    if (clickedNotDragged && _pageController.page != index) {
      _pageController.animateToPage(
        index,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }

    _destinationFieldController.text = attractionList[index].address;
  }

  @override
  dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

enum MapStyle {
  normal,
  hybird,
}
