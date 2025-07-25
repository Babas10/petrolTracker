import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

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
        child: widget.data.isNotEmpty
            ? _buildFlChart(context)
            : _buildEmptyChart(context),
      ),
    );
  }

  Widget _buildFlChart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.config.title != null) ...[
            Text(
              widget.config.title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: _buildChartByType(context),
          ),
        ],
      ),
    );
  }

  /// Smart tick selection algorithm for x-axis optimization
  /// Returns list of indices that should show labels
  List<int> _getOptimalTickIndices(int dataLength, {int maxTicks = 6}) {
    if (dataLength <= maxTicks) {
      // If we have few data points, show all
      return List.generate(dataLength, (index) => index);
    }

    final ticks = <int>[];
    
    // Always include first and last
    ticks.add(0);
    if (dataLength > 1) {
      ticks.add(dataLength - 1);
    }

    // Calculate how many intermediate ticks we can fit
    final intermediateTicks = maxTicks - 2; // Subtract first and last
    
    if (intermediateTicks > 0) {
      // Distribute intermediate ticks evenly
      for (int i = 1; i <= intermediateTicks; i++) {
        final position = (dataLength - 1) * i / (intermediateTicks + 1);
        final index = position.round();
        
        // Avoid duplicates with first/last and ensure valid range
        if (index > 0 && index < dataLength - 1 && !ticks.contains(index)) {
          ticks.add(index);
        }
      }
    }

    // Sort to ensure proper order
    ticks.sort();
    return ticks;
  }

  /// Check if an index should show a label based on optimal tick selection
  bool _shouldShowTick(int index, int dataLength) {
    final optimalTicks = _getOptimalTickIndices(dataLength);
    return optimalTicks.contains(index);
  }

  Widget _buildChartByType(BuildContext context) {
    switch (widget.config.type) {
      case ChartType.line:
        return _buildLineChart(context);
      case ChartType.bar:
        return _buildBarChart(context);
      case ChartType.area:
        return _buildLineChart(context, isArea: true);
      case ChartType.multiLine:
        return _buildMultiLineChart(context);
    }
  }

  Widget _buildLineChart(BuildContext context, {bool isArea = false}) {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < widget.data.length; i++) {
      final item = widget.data[i];
      final value = item['value'] as double? ?? 0.0;
      spots.add(FlSpot(i.toDouble(), value));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: widget.data.length > 6 ? (widget.data.length / 6).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                
                // Use smart tick selection for better readability
                if (index >= 0 && index < widget.data.length && _shouldShowTick(index, widget.data.length)) {
                  final item = widget.data[index];
                  String label = '';
                  
                  if (item.containsKey('date')) {
                    final dateStr = item['date'] as String;
                    final parts = dateStr.split('-');
                    if (parts.length >= 2) {
                      label = '${parts[1]}/${parts[2]}';
                    }
                  } else if (item.containsKey('label')) {
                    label = item['label'].toString();
                  }
                  
                  return Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            belowBarData: isArea
                ? BarAreaData(
                    show: true,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  )
                : BarAreaData(show: false),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 2,
                strokeColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final barGroups = <BarChartGroupData>[];
    
    for (int i = 0; i < widget.data.length; i++) {
      final item = widget.data[i];
      final value = item['value'] as double? ?? 0.0;
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: Theme.of(context).colorScheme.primary,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: barGroups.isNotEmpty
            ? barGroups.map((g) => g.barRods.first.toY).reduce((a, b) => a > b ? a : b) * 1.2
            : 10,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: widget.data.length > 6 ? (widget.data.length / 6).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                
                // Use smart tick selection for better readability
                if (index >= 0 && index < widget.data.length && _shouldShowTick(index, widget.data.length)) {
                  final item = widget.data[index];
                  String label = '';
                  
                  if (item.containsKey('label')) {
                    label = item['label'].toString();
                  } else if (item.containsKey('date')) {
                    final dateStr = item['date'] as String;
                    final parts = dateStr.split('-');
                    if (parts.length >= 2) {
                      label = '${parts[1]}/${parts[2]}';
                    }
                  }
                  
                  return Text(
                    label.length > 8 ? label.substring(0, 8) : label,
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildMultiLineChart(BuildContext context) {
    // Extract all series from the data
    final Map<String, List<FlSpot>> seriesData = {};
    final List<Color> colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Colors.orange,
      Colors.green,
    ];
    
    for (int i = 0; i < widget.data.length; i++) {
      final item = widget.data[i];
      
      for (final key in item.keys) {
        if (key != 'date' && key != 'label' && item[key] is double) {
          seriesData.putIfAbsent(key, () => []);
          seriesData[key]!.add(FlSpot(i.toDouble(), item[key] as double));
        }
      }
    }

    final lineBarsData = <LineChartBarData>[];
    int colorIndex = 0;
    
    for (final entry in seriesData.entries) {
      lineBarsData.add(
        LineChartBarData(
          spots: entry.value,
          isCurved: true,
          color: colors[colorIndex % colors.length],
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 3,
              color: colors[colorIndex % colors.length],
              strokeWidth: 1,
              strokeColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
      );
      colorIndex++;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: widget.data.length > 6 ? (widget.data.length / 6).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                
                // Use smart tick selection for better readability
                if (index >= 0 && index < widget.data.length && _shouldShowTick(index, widget.data.length)) {
                  final item = widget.data[index];
                  String label = '';
                  
                  if (item.containsKey('date')) {
                    final dateStr = item['date'] as String;
                    final parts = dateStr.split('-');
                    if (parts.length >= 2) {
                      label = '${parts[1]}/${parts[2]}';
                    }
                  }
                  
                  return Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        lineBarsData: lineBarsData,
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No chart data available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
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