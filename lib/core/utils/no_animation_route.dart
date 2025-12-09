import 'package:flutter/material.dart';

/// Custom route class yang menghilangkan animasi transisi halaman
class NoAnimationPageRoute extends MaterialPageRoute {
  NoAnimationPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

  @override
  Duration get transitionDuration => Duration.zero;
}
