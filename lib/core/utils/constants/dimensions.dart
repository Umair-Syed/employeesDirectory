import 'package:flutter/material.dart';

class MyDimensions {
  static const double radiusRound = 14;

  double? _heightPercentage;
  double? _widthPercentage;
  double? _heightPaddingPercentage;
  double? _widthPaddingPercentage;
  bool _isDynamic = false;

  MyDimensions.responsive(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    _heightPercentage = queryData.size.height / 100.0;
    _widthPercentage = queryData.size.width / 100.0;
    _heightPaddingPercentage = (queryData.size.height / 100.0) -
        ((queryData.padding.top + queryData.padding.bottom) / 100.0);
    _widthPaddingPercentage = (queryData.size.width / 100.0) -
        ((queryData.padding.left + queryData.padding.right) / 100.0);
    _isDynamic = true;
  }

  MyDimensions();

  double rH(double v) {
    if (!_isDynamic) {
      throw StateError(
          'rH can only be called when using MyDimensions.dynamic constructor');
    }
    return _heightPercentage! * v;
  }

  double rW(double v) {
    if (!_isDynamic) {
      throw StateError(
          'rW can only be called when using MyDimensions.dynamic constructor');
    }
    return _widthPercentage! * v;
  }

  double rHP(double v) {
    if (!_isDynamic) {
      throw StateError(
          'rHP can only be called when using MyDimensions.dynamic constructor');
    }
    return _heightPaddingPercentage! * v;
  }

  double rWP(double v) {
    if (!_isDynamic) {
      throw StateError(
          'rWP can only be called when using MyDimensions.dynamic constructor');
    }
    return _widthPaddingPercentage! * v;
  }
}
