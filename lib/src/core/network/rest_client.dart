

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioclientProvider = Provider((ref) {
  return Dio();
});