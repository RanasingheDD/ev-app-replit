import 'package:flutter/material.dart';

class PointsProvider extends ChangeNotifier {
  int _points = 0;

  int get points => _points;

  int getPoints(int points) {
    _points = points;
    return _points;
  }
}
