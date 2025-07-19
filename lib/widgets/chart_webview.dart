import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Chart types supported by the WebView
enum ChartType {
  line,
  bar,
  area,
  multiLine,
}

/// Configuration for chart rendering
class ChartConfig {
  final ChartType type;
  final String? title;
  final String? xLabel;
  final String? yLabel;
  final String? unit;
  final String? className;
  final List<String>? series;
  final Map<String, String>? seriesLabels;
  final String Function(dynamic)? formatValue;

  const ChartConfig({
    required this.type,
    this.title,
    this.xLabel,
    this.yLabel,
    this.unit,
    this.className,
    this.series,
    this.seriesLabels,
    this.formatValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'xLabel': xLabel,
      'yLabel': yLabel,
      'unit': unit,
      'className': className,
      'series': series,
      'seriesLabels': seriesLabels,
    };
  }
}

/// Callback for chart events
typedef ChartEventCallback = void Function(String eventType, Map<String, dynamic> data);

/// WebView widget for displaying D3.js charts
class ChartWebView extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final ChartConfig config;
  final ChartEventCallback? onChartEvent;
  final VoidCallback? onChartReady;
  final Function(String)? onError;
  final double? width;
  final double? height;

  const ChartWebView({
    super.key,
    required this.data,
    required this.config,
    this.onChartEvent,
    this.onChartReady,
    this.onError,
    this.width,
    this.height,
  });

  @override
  State<ChartWebView> createState() => _ChartWebViewState();
}

class _ChartWebViewState extends State<ChartWebView> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isWebViewReady = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeWebView();
    }
  }

  @override
  void didUpdateWidget(ChartWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update chart if data or config changed and not on web
    if (!kIsWeb && (oldWidget.data != widget.data || oldWidget.config != widget.config)) {
      _updateChart();
    }
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress if needed
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _errorMessage = error.description;
              _isLoading = false;
            });
            widget.onError?.call(error.description);
          },
        ),
      )
      ..addJavaScriptChannel(
        'chartReady',
        onMessageReceived: (JavaScriptMessage message) {
          _isWebViewReady = true;
          _renderChart();
          widget.onChartReady?.call();
        },
      )
      ..addJavaScriptChannel(
        'chartEvent',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message) as Map<String, dynamic>;
            final eventType = data['eventType'] as String;
            final eventData = data['data'] as Map<String, dynamic>? ?? {};
            widget.onChartEvent?.call(eventType, eventData);
          } catch (e) {
            debugPrint('Error parsing chart event: $e');
          }
        },
      );

    _loadHtmlAsset();
  }

  Future<void> _loadHtmlAsset() async {
    try {
      final String htmlContent = await rootBundle.loadString('assets/charts/index.html');
      final String baseUrl = Platform.isAndroid 
          ? 'file:///android_asset/flutter_assets/assets/charts/'
          : 'assets/charts/';
      
      await _controller!.loadHtmlString(
        htmlContent,
        baseUrl: baseUrl,
      );
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load chart: $e';
        _isLoading = false;
      });
      widget.onError?.call('Failed to load chart: $e');
    }
  }

  void _renderChart() {
    if (!_isWebViewReady || widget.data.isEmpty) return;

    final message = {
      'type': 'renderChart',
      'chartType': widget.config.type.name,
      'data': widget.data,
      'options': widget.config.toJson(),
    };

    _sendMessageToWebView(message);
  }

  void _updateChart() {
    if (!_isWebViewReady) return;

    final message = {
      'type': 'updateData',
      'data': widget.data,
    };

    _sendMessageToWebView(message);
  }

  void _sendMessageToWebView(Map<String, dynamic> message) {
    if (_controller == null) return;
    
    final jsonMessage = jsonEncode(message);
    _controller!.runJavaScript('''
      if (window.chartManager) {
        window.chartManager.handleFlutterMessage($jsonMessage);
      }
    ''');
  }

  void _retryChart() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isLoading = true;
    });
    _loadHtmlAsset();
  }

  @override
  Widget build(BuildContext context) {
    // WebView is not supported on web platform
    if (kIsWeb) {
      return _buildWebFallback(context);
    }

    Widget content;

    if (_hasError) {
      content = _buildErrorWidget();
    } else if (_isLoading) {
      content = _buildLoadingWidget();
    } else {
      content = WebViewWidget(controller: _controller!);
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading chart...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading chart',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _retryChart,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebFallback(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.web_asset_off,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Interactive Charts Not Available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Interactive D3.js charts are only available on mobile devices. Use the mobile app for full chart functionality.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (widget.data.isNotEmpty) _buildSimpleDataSummary(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleDataSummary(BuildContext context) {
    final dataCount = widget.data.length;
    final hasNumericData = widget.data.isNotEmpty && 
                          widget.data.first.containsKey('value');
    
    String summary = 'Data points: $dataCount';
    
    if (hasNumericData) {
      final values = widget.data
          .map((d) => d['value'] as double?)
          .where((v) => v != null)
          .cast<double>()
          .toList();
          
      if (values.isNotEmpty) {
        final avg = values.reduce((a, b) => a + b) / values.length;
        summary += '\nAverage: ${avg.toStringAsFixed(2)}';
        
        if (widget.config.unit != null) {
          summary += ' ${widget.config.unit}';
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        summary,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Helper class for creating chart data points
class ChartDataPoint {
  final DateTime? date;
  final String? label;
  final double value;
  final Map<String, dynamic>? metadata;

  const ChartDataPoint({
    this.date,
    this.label,
    required this.value,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      if (date != null) 'date': date!.toIso8601String().split('T')[0],
      if (label != null) 'label': label,
      'value': value,
      if (metadata != null) ...metadata!,
    };
  }
}

/// Helper class for creating multi-series chart data
class MultiSeriesChartData {
  final DateTime date;
  final Map<String, double> values;

  const MultiSeriesChartData({
    required this.date,
    required this.values,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      ...values,
    };
  }
}

/// Extension methods for easier chart integration
extension ChartDataExtensions on List<ChartDataPoint> {
  List<Map<String, dynamic>> toChartData() {
    return map((point) => point.toJson()).toList();
  }
}

extension MultiSeriesChartDataExtensions on List<MultiSeriesChartData> {
  List<Map<String, dynamic>> toChartData() {
    return map((data) => data.toJson()).toList();
  }
}