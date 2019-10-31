import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import './../mixins/attractions_data_mixin.dart';
import './../widgets/attraction_card.dart';
import './../widgets/map_control_button.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AttractionDataMixin {
  GoogleMapController _mapController;
  List<Marker> attractionMarkerList;
  PageController _pageController;
  MapStyle currentMapStyle = MapStyle.normal;
  MapType mapType;
  double currentZoom = 18.0;

  @override
  void initState() {
    super.initState();
    attractionMarkerList = attractionList.map(
      (attraction) {
        return Marker(
          markerId: MarkerId(attraction.attractionName),
          draggable: false,
          infoWindow: InfoWindow(
            title: attraction.attractionName,
            snippet: attraction.address,
          ),
          position: attraction.locationCoords,
        );
      },
    ).toList();

    _pageController = PageController(initialPage: 1, viewportFraction: 0.8)
      ..addListener(_onPageViewScrolled);
  }

  void _onPageViewScrolled() {
    _moveCameraToSelectedAttraction(_pageController.page.toInt(), false);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    switch (currentMapStyle) {
      case MapStyle.normal:
        mapType = MapType.normal;
        break;
      case MapStyle.hybird:
        mapType = MapType.hybrid;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Google Maps App',
        ),
      ),
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            height: mediaQuery.size.height,
            width: mediaQuery.size.width,
            child: GoogleMap(
              polygons: [
                Polygon(
                  strokeColor: Colors.blueAccent,
                  polygonId:
                      PolygonId('from first attraction to the second one'),
                  points: [
                    attractionList[1].locationCoords,
                    attractionList[0].locationCoords,
                  ],
                ),
                Polygon(
                  strokeColor: Colors.blueAccent,
                  polygonId:
                      PolygonId('from first attraction to the second one'),
                  points: [
                    attractionList[4].locationCoords,
                    attractionList[2].locationCoords,
                  ],
                ),
              ].toSet(),
              mapType: mapType,
              initialCameraPosition: CameraPosition(
                target: LatLng(30.094434, 31.31765500000006),
                zoom: currentZoom - 3.0,
              ),
              onMapCreated: _onMapCreatedCallback,
              markers: attractionMarkerList.toSet(),
            ),
          ),
          Positioned(
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
          ),
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      top: 15.0,
      right: 15.0,
      height: 180.0,
      width: 50.0,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          MapControlButton(
            icon: Icons.map,
            onButtonPressed: _changeMapTypeCallback,
          ),
          SizedBox(
            height: 10.0,
          ),
          MapControlButton(
            icon: Icons.zoom_in,
            onButtonPressed: _zoomInButtonCallback,
          ),
          SizedBox(
            height: 10.0,
          ),
          MapControlButton(
            icon: Icons.zoom_out,
            onButtonPressed: _zoomOutButtonCallback,
          ),
        ],
      ),
    );
  }

  void _changeMapTypeCallback() {
    print('Map Type changed to ${currentMapStyle.toString()}');

    switch (currentMapStyle) {
      case MapStyle.normal:
        currentMapStyle = MapStyle.hybird;
        break;
      case MapStyle.hybird:
        currentMapStyle = MapStyle.normal;
        break;
    }
    setState(() {});
  }

  void _zoomInButtonCallback() {
    print('Zooming IN: $currentZoom');
    setState(() {
      currentZoom += 3.0;
      _onPageViewScrolled();
    });
  }

  void _zoomOutButtonCallback() {
    print('Zooming OUT: $currentZoom');
    setState(() {
      currentZoom -= 3.0;
      _onPageViewScrolled();
    });
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
          zoom: currentZoom,
          bearing: 50.0,
          tilt: 50.0,
        ),
      ),
    );

    if (clickedNotDragged && _pageController.page != index) {
      _pageController.jumpToPage(index);
    }
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
