import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    initializeMarkers();

    _pageController = PageController(initialPage: 2, viewportFraction: 0.8)
      ..addListener(_onPageViewScrolled);
  }

  void _onPageViewScrolled() {
    _moveCameraToSelectedAttraction(_pageController.page.toInt(), false);
  }

  Future<bool> initializeMarkers() async {
    final Uint8List markerIcon =
        await getMakerIconFromAssets('assets/images/marker_icon.png', 80);

    attractionMarkerList = attractionList.map(
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
    ).toList();

    return true;
  }

  Future<Uint8List> getMakerIconFromAssets(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
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
      body: FutureBuilder(
        future: initializeMarkers(),
        builder: (BuildContext ctx, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );

          return Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Container(
                height: mediaQuery.size.height,
                width: mediaQuery.size.width,
                child: GoogleMap(
                  mapType: mapType,
                  initialCameraPosition: CameraPosition(
                    target: attractionList[2].locationCoords,
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
          );
        },
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      top: 50.0,
      right: 15.0,
      height: 200.0,
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
      _pageController.animateToPage(
        index,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
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
