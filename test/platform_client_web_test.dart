@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/browser_client.dart';
import 'package:pwi_auth/src/platform_client.dart';
import 'package:web/web.dart';

void main() {
  test('web keeps credentialed browser requests and browser cookies', () {
    final client = createPlatformClient();
    addTearDown(client.close);

    expect(client, isA<BrowserClient>());
    expect((client as BrowserClient).withCredentials, isTrue);
    expect(readBrowserCookies(), document.cookie);
  });
}
