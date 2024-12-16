import 'package:flutter/material.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebScreen extends StatefulWidget {
  const PaymentWebScreen({super.key});

  @override
  State<PaymentWebScreen> createState() => _PaymentWebScreenState();
}

class _PaymentWebScreenState extends State<PaymentWebScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final WebViewController controller = WebViewController();
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('Error occurred on page: ${error.response?.statusCode}');
          },
          onUrlChange: (UrlChange change) {
            eLog('url change to ${change.url}');
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'http://192.168.182.11:8000/api/RideNowV1/payment/eyJpdiI6IjNDZlBUQkZDZXBsK1dEY05QMFowR2c9PSIsInZhbHVlIjoiUWpnVUR3b2JqbEUwUUpvbVFKakFlck1hREpqUXl2QnZ0V2lQMVZZVHp4ST0iLCJtYWMiOiIwZWNjOGEwZDZmMzM3OTMxMTlkMGI2NmNmNmQxZmYxMWU5OTdiMmJiYzYxMDhiNDA4OWRjMDcwOGI4NDE1MWM3In0='));

    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Ride Payment'),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
      ),
      body: WebViewWidget(controller: _controller),
      floatingActionButton: favoriteButton(),
    );
  }

  Widget favoriteButton() {
    return FloatingActionButton(
      onPressed: () async {
        final String? url = await _controller.currentUrl();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Favorited $url')),
          );
        }
      },
      child: const Icon(Icons.favorite),
    );
  }
}
