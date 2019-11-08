import 'package:flutter/material.dart';

class MapControlButton extends StatelessWidget {
  final IconData icon;
  final Function() onButtonPressed;

  MapControlButton({this.icon, this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: 50.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 2.0,
            color: Colors.black54,
          ),
        ],
      ),
      child: Center(
        child: IconButton(
          padding: EdgeInsets.all(0.0),
          onPressed: onButtonPressed,
          icon: Icon(
            icon,
            size: 30.0,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
