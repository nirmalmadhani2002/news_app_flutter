import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'Provider/theme_provider.dart';


class WebView extends StatefulWidget {
  const WebView({Key? key}) : super(key: key);

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late InAppWebViewController? webViewController;
  late PullToRefreshController pullToRefreshController;
  List bookMark = [];
  double prog = 0;
  GlobalKey webViewKey = GlobalKey();
  TextEditingController searchcontroller = TextEditingController();

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  webReload() {
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    webReload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("MY News App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.light_mode),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false)
                  .changeTheme();
            },
          ),
          IconButton(
            onPressed: () {
              webViewController?.goBack();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
          ),
          IconButton(
            onPressed: () async {
              if (Platform.isAndroid) {
                webViewController?.reload();
              } else if (Platform.isIOS) {
                webViewController?.loadUrl(
                    urlRequest:
                    URLRequest(url: await webViewController?.getUrl()));
              }
            },
            icon: const Icon(
              Icons.refresh,
              size: 20,
            ),
          ),
          IconButton(
            onPressed: () {
              webViewController?.goForward();
            },
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 20,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          (prog < 1.0) ? LinearProgressIndicator(value: prog) : Container(),
          Expanded(
            flex: 10,
            child: InAppWebView(
              key: webViewKey,
              initialUrlRequest:
              URLRequest(url: Uri.parse("https://economictimes.indiatimes.com/news")),
              initialOptions: options,
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, uri) {
                setState(() {
                  searchcontroller.text =
                      uri!.scheme.toString() + "://" + uri.host + uri.path;
                });
              },
              onLoadStop: (controller, uri) async {
                pullToRefreshController.endRefreshing();
                setState(() {
                  searchcontroller.text =
                      uri!.scheme.toString() + "://" + uri.host + uri.path;
                });
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController.endRefreshing();
                }
                setState(() {
                  prog = progress / 100;
                  searchcontroller.text = prog.toString();
                });
              },
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                return PermissionRequestResponse(
                    resources: resources,
                    action: PermissionRequestResponseAction.GRANT);
              },
            ),
          ),
        ],
      ),
    );
  }
}