import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import './../models/attraction_model.dart';

class AttractionCard extends StatelessWidget {
  final Attraction _attraction;
  final PageController _pageController;
  final int index;
  final Function(int, bool) _onAttractionTappedCallback;

  AttractionCard(this._attraction, this._pageController, this.index,
      this._onAttractionTappedCallback);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (BuildContext ctx, Widget child) {
        double value = 1;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page - index;
          value = (1 - (value.abs() * .2)).clamp(0.0, 1.0);
        }

        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 140.0,
            width: Curves.easeInOut.transform(value) * 320.0,
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: () {
          _onAttractionTappedCallback(index, true);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 10.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                blurRadius: 5.0,
                color: Colors.black54,
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (BuildContext ctx, BoxConstraints constraints) {
              return Row(
                children: <Widget>[
                  Container(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                      ),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: _attraction.thumbnail,
                        placeholder: (BuildContext ctx, String url) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueGrey),
                            ),
                          );
                        },
                        errorWidget: (BuildContext ctx, String url, _) =>
                            Icon(Icons.error),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth * 0.025,
                  ),
                  Container(
                    width: constraints.maxWidth * 0.6,
                    height: constraints.maxHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _attraction.attractionName,
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          _attraction.address,
                          style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey),
                          textAlign: TextAlign.justify,
                        ),
                        Text(
                          _attraction.description,
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth * 0.025,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
