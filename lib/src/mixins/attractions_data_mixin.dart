import 'package:google_maps_flutter/google_maps_flutter.dart';

import './../models/attraction_model.dart';

class AttractionDataMixin {
  List<Attraction> attractionList = [
    Attraction(
      attractionName: 'Star bucks Coffee',
      address:
          '23 Ibrahim Al Lakani, El-Montaza, Heliopolis, Cairo Governorate.',
      description: 'Coffee shop.',
      thumbnail:
          'https://globalassets.starbucks.com/assets/d2fbf41711cc4343b84980e4e18328ff.jpg',
      locationCoords: LatLng(
        30.09209,
        31.323131999999987,
      ),
    ),
    Attraction(
      attractionName: 'Apple store',
      address:
          '3 El-Farik Abd El-Moneim Riad, Ad Doqi, Dokki, Giza Governorate.',
      description: 'Apple.inc products shop.',
      thumbnail:
          'https://www.mallofegypt.com/-/media/moeg/shopping/tradeline/tradeline---store-image-min.jpg',
      locationCoords: LatLng(
        30.048711,
        31.204615999999987,
      ),
    ),
    Attraction(
      attractionName: 'Cairo hospital',
      address:
          '3 Al ASRI Mohammed Nafe, El-Montaza, Heliopolis, Cairo Governorate.',
      description: 'Medical place.',
      thumbnail:
          'http://targetfortab.com/ar/cache/widgetkit/gallery/54/640-6c6d9e4da0-4fdb73743a.jpg',
      locationCoords: LatLng(30.094434, 31.31765500000006),
    ),
    Attraction(
      attractionName: 'Beanos caffee',
      address: '15 Baghdad St, El-Montaza, Heliopolis, Cairo Governorate.',
      description: 'Coffee shop.',
      thumbnail: 'http://www.magnument.com/assets/img/clients/A_30_1.jpg',
      locationCoords: LatLng(
        30.090266,
        31.32369,
      ),
    ),
    Attraction(
      attractionName: 'Costa caffee',
      address: '16 Al Nadi, El-Montaza, Heliopolis, Cairo Governorate.',
      description: 'Coffee shop.',
      thumbnail:
          'https://d6prv7be4nrvy.cloudfront.net/wp-content/uploads/costa.jpg',
      locationCoords: LatLng(
        30.090591,
        31.315675000000056,
      ),
    ),
    Attraction(
      attractionName: 'Heliopolis hospital',
      address: '125 El Hegaz St, El-Nozha, El Nozha, Cairo Governorate.',
      description: 'Medical place.',
      thumbnail: 'https://i.ytimg.com/vi/7k6VqR2BRxI/maxresdefault.jpg',
      locationCoords: LatLng(
        30.107002,
        30.107002,
      ),
    ),
    Attraction(
      attractionName: 'Harris Cafe',
      address:
          '23 Ibrahim Al Lakani, El-Montaza, Heliopolis, Cairo Governorate.',
      description: 'Coffee shop.',
      thumbnail:
          'http://roundmenu.s3-website-us-east-1.amazonaws.com/640x400/images/restaurants/rst_893224.jpg',
      locationCoords: LatLng(
        30.089389,
        31.32285300000001,
      ),
    ),
    Attraction(
      attractionName: 'Misr el Gedida court',
      address:
          '28 Abd Al Hamid Abou Hief, El-Nozha, El Nozha, Cairo Governorate.',
      description: 'Govermental place.',
      thumbnail:
          'http://english.ahram.org.eg/Media/News/2015/3/11/2015-635616703773143990-314.jpg',
      locationCoords: LatLng(30.103549000000005, 31.32944599999996),
    ),
    Attraction(
      attractionName: 'IBM Egypt',
      address: 'C10, Al Giza Desert, Giza Governorate.',
      description: 'IBM Electronics Company branch.',
      thumbnail:
          'https://www.consultancy-me.com/illustrations/news/detail/2019-06-28-121001353-IBM-expands-MENA-footprint-with-two-new-innovation-centres-in-Egypt--.jpg',
      locationCoords: LatLng(30.017651, 31.072318999999993),
    ),
    Attraction(
      attractionName: 'AUC library',
      address:
          'Falaki, The Greek Campus، 28 Al Falki, Ad Dawawin, Abdeen, Cairo Governorate.',
      description: 'American University of Cairo Library.',
      thumbnail:
          'https://www.aucegypt.edu/sites/default/files/inline-images/Library.jpg',
      locationCoords: LatLng(30.043548000000005, 31.238883999999985),
    ),
  ];
}
