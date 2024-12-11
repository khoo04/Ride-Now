import 'package:flutter/material.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showContactMethodPicker(
    BuildContext context, String phoneNumber, String intro) {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        height: 150,
        margin: const EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Choose Contact Methods',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () async {
                    String url = "tel:$phoneNumber";

                    try {
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        throw "Unable to open the internal phone app. Please try another method.";
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showSnackBar(context, e.toString());
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const SizedBox(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage:
                              AssetImage("assets/images/telephone-call.png"),
                        ),
                        Text(
                          "Phone",
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    String webUrl =
                        'https://api.whatsapp.com/send/?phone=$phoneNumber&text=$intro';

                    await launchUrl(Uri.parse(webUrl),
                        mode: LaunchMode.externalApplication);
                    return;
                  },
                  child: const SizedBox(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage:
                              AssetImage("assets/images/whatsapp.png"),
                        ),
                        Text(
                          "WhatsApp",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      );
    },
  );
}
