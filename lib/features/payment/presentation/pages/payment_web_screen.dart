import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ride_now_app/core/constants/api_routes.dart';
import 'package:ride_now_app/core/network/network_client.dart';

import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:ride_now_app/features/payment/presentation/pages/payment_result_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebScreen extends StatefulWidget {
  static const routeName = 'payment/web';
  const PaymentWebScreen({super.key});

  @override
  State<PaymentWebScreen> createState() => _PaymentWebScreenState();
}

class _PaymentWebScreenState extends State<PaymentWebScreen> {
  late final WebViewController _controller;
  late final String url;

  @override
  void initState() {
    super.initState();
    final WebViewController controller = WebViewController();

    final paymentState =
        context.read<PaymentCubit>().state as PaymentInitSuccess;

    url = paymentState.paymentLink;

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
            if (change.url ==
                "https://khoodev.us.kg/api/RideNowV1/payment/callback") {
              Navigator.of(context)
                  .popAndPushNamed(PaymentResultScreen.routeName);
            }
            eLog('url change to ${change.url}');
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentState.paymentLink));
    context.read<PaymentCubit>().setRequestProcessing();
    _controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Ride Payment'),
      ),
      body: WebViewWidget(controller: _controller),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool demoPaymentResult = false;
          demoPaymentResult = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Demo Payment"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("This is a demo payment process."),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final networkClient = GetIt.instance<NetworkClient>();

                        String token = url.split('/').last;
                        final response = await networkClient.invoke(
                            "${ApiRoutes.apiBaseUrl}/payment/demo/$token",
                            RequestType.post,
                            requestBody: {
                              "password": "KH00_DEMO",
                              "demo_status": 0,
                            });

                        bool success = response.data["success"] as bool;
                        // Call your demo payment logic here
                        // You can use your API or local logic to trigger a demo payment
                        if (context.mounted && success) {
                          Navigator.of(context)
                              .pop(success); // Close the dialog
                        }
                        // Handle demo payment logic
                      },
                      child: const Text("Start Demo Payment"),
                    ),
                  ],
                ),
              );
            },
          );
          if (context.mounted && demoPaymentResult) {
            Navigator.of(context)
                .popAndPushNamed(PaymentResultScreen.routeName);
          }
        },
        child: const Text("Demo"),
      ),
    );
  }
}
