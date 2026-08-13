@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pwi_auth/src/platform_client.dart';

void main() {
  test('native platforms use the standard HTTP client without cookies', () {
    final client = createPlatformClient();
    addTearDown(client.close);

    expect(client, isA<http.Client>());
    expect(readBrowserCookies(), isEmpty);
  });
}
