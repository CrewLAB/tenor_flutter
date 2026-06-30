import 'package:flutter/widgets.dart';
import 'package:cl_tenor_flutter/tenor_flutter.dart';

class TenorTabProvider with ChangeNotifier {
  Tenor client;
  TenorAttributionType attributionType;

  TenorTabProvider({
    required this.client,
    required this.attributionType,
  });
}
