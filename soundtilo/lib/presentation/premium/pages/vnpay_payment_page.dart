import 'package:flutter/material.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/core/constants/api_urls.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens a VNPay payment URL in a WebView.
/// Returns `true` if payment succeeded, `false` otherwise.
class VnpayPaymentPage extends StatefulWidget {
  final String paymentUrl;
  final String txnRef;

  const VnpayPaymentPage({
    super.key,
    required this.paymentUrl,
    required this.txnRef,
  });

  @override
  State<VnpayPaymentPage> createState() => _VnpayPaymentPageState();
}

class _VnpayPaymentPageState extends State<VnpayPaymentPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            // Intercept the return URL to capture payment result
            if (request.url.contains(ApiUrls.vnpayReturn)) {
              _handleReturnUrl(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleReturnUrl(String url) {
    final uri = Uri.parse(url);
    final responseCode = uri.queryParameters['vnp_ResponseCode'];
    final success = responseCode == '00';

    if (mounted) {
      Navigator.of(context).pop(success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Thanh toán VNPay'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showCancelConfirmation(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hủy thanh toán?'),
        content: const Text(
            'Bạn có chắc muốn hủy thanh toán? Giao dịch sẽ không được hoàn tất.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tiếp tục thanh toán'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context, false); // close webview with failure
            },
            child: const Text('Hủy', style: TextStyle(color: AppColors.errorColor)),
          ),
        ],
      ),
    );
  }
}
