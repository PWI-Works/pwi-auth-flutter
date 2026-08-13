import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart';

http.Client createPlatformClient() => BrowserClient()..withCredentials = true;

String readBrowserCookies() => document.cookie;
