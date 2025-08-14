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
    // Use fl_chart fallback for web and mobile platforms (WebView doesn't work reliably on mobile)
    return _buildWebFallback(context);
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
  List<int> _getOptimalTickIndices(int dataLength, {int maxTicks = 10}) {
    // Issue #70: Smart X-axis labeling
    if (dataLength <= 5) {
      // ≤5 data points: Show all actual data point labels
      return List.generate(dataLength, (index) => index);
    }

    // >5 data points: Show exactly 5 equidistant labels
    final ticks = <int>[];
    
    // Always include first and last
    ticks.add(0);
    ticks.add(dataLength - 1);
    
    // Add 3 intermediate points evenly distributed
    for (int i = 1; i <= 3; i++) {
      final position = (dataLength - 1) * i / 4; // Divide into 4 equal sections
      final index = position.round();
      
      // Avoid duplicates and ensure valid range
      if (index > 0 && index < dataLength - 1 && !ticks.contains(index)) {
        ticks.add(index);
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

  /// Check if year should be displayed for this index (first occurrence of a year)
  bool _shouldShowYear(int index) {
    if (widget.data.isEmpty || index >= widget.data.length) return false;
    
    // Always show year for first item
    if (index == 0) return true;
    
    final currentItem = widget.data[index];
    final previousItem = widget.data[index - 1];
    
    // Show year if it's different from previous item's year
    final currentYear = _getYearForIndex(index);
    final previousYear = _getYearForIndex(index - 1);
    
    return currentYear != previousYear;
  }

  /// Check if year should be displayed at center position for better alignment
  bool _shouldShowYearAtCenter(int index) {
    if (widget.data.isEmpty || index >= widget.data.length) return false;
    
    // Group data by year and find center positions
    final yearGroups = <String, List<int>>{};
    
    for (int i = 0; i < widget.data.length; i++) {
      final year = _getYearForIndex(i);
      if (year.isNotEmpty) {
        yearGroups.putIfAbsent(year, () => []).add(i);
      }
    }
    
    // Check if this index is the center of its year group
    final currentYear = _getYearForIndex(index);
    if (currentYear.isEmpty) return false;
    
    final yearIndices = yearGroups[currentYear];
    if (yearIndices == null || yearIndices.isEmpty) return false;
    
    // Calculate center index for this year group
    final centerIndex = yearIndices[yearIndices.length ~/ 2];
    
    return index == centerIndex;
  }

  /// Get year string for given index
  String _getYearForIndex(int index) {
    if (widget.data.isEmpty || index >= widget.data.length) return '';
    
    final item = widget.data[index];
    if (item.containsKey('date')) {
      final dateStr = item['date'] as String;
      final parts = dateStr.split('-');
      if (parts.length >= 1) {
        return parts[0]; // Return year
      }
    }
    
    return '';
  }

  /// Build year labels positioned between months for proper centering
  List<Widget> _buildYearLabels(int index) {
    final yearRanges = _getYearRanges();
    final labels = <Widget>[];
    
    for (final yearRange in yearRanges) {
      // Check if this index should show the year label (at the center position)
      if (index == yearRange['centerIndex']) {
        // Calculate the horizontal offset to center between first and last month of the year
        final firstIndex = yearRange['firstIndex'] as int;
        final lastIndex = yearRange['lastIndex'] as int;
        final centerPosition = (firstIndex + lastIndex) / 2;
        final currentPosition = index.toDouble();
        
        // Calculate offset in chart units (approximate)
        final offset = (centerPosition - currentPosition) * 40.0; // 40px per chart unit (approximate)
        
        labels.add(
          Positioned(
            top: 25, // Lower position for better visual separation
            left: offset - 15, // Center the text (approximate text width / 2)
            child: Text(
              yearRange['year'] as String,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
    }
    
    return labels;
  }

  /// Calculate year ranges and their center positions
  List<Map<String, dynamic>> _getYearRanges() {
    if (widget.data.isEmpty) return [];
    
    final yearGroups = <String, List<int>>{};
    
    // Group indices by year
    for (int i = 0; i < widget.data.length; i++) {
      final year = _getYearForIndex(i);
      if (year.isNotEmpty) {
        yearGroups.putIfAbsent(year, () => []).add(i);
      }
    }
    
    final yearRanges = <Map<String, dynamic>>[];
    
    for (final entry in yearGroups.entries) {
      final indices = entry.value;
      indices.sort();
      
      final firstIndex = indices.first;
      final lastIndex = indices.last;
      final centerIndex = indices[indices.length ~/ 2]; // Middle index for positioning
      
      yearRanges.add({
        'year': entry.key,
        'firstIndex': firstIndex,
        'lastIndex': lastIndex,
        'centerIndex': centerIndex,
        'count': indices.length,
      });
    }
    
    return yearRanges;
  }

  /// Calculate comprehensive Y-axis configuration for clean display
  Map<String, double> _calculateYAxisConfig() {
    if (widget.data.isEmpty) {
      return {'minY': 0.0, 'maxY': 10.0, 'interval': 2.0};
    }
    
    // Find actual min and max values in the data
    final values = widget.data
        .map((item) => item['value'] as double? ?? 0.0)
        .toList();
    
    if (values.isEmpty) {
      return {'minY': 0.0, 'maxY': 10.0, 'interval': 2.0};
    }
    
    final dataMin = values.reduce((a, b) => a < b ? a : b);
    final dataMax = values.reduce((a, b) => a > b ? a : b);
    final dataRange = dataMax - dataMin;
    
    if (dataRange <= 0) {
      // If all values are the same, create a small range around the value
      final center = dataMin;
      return {
        'minY': center - 2.0,
        'maxY': center + 2.0,
        'interval': 1.0
      };
    }
    
    // Calculate nice interval (target 4-5 ticks)
    double interval = dataRange / 4;
    
    // Round to nice numbers - more precise logic
    if (interval <= 0.5) {
      interval = 0.5;
    } else if (interval <= 1) {
      interval = 1.0;
    } else if (interval <= 1.5) {
      interval = 1.0;
    } else if (interval <= 2.5) {
      interval = 2.0;
    } else if (interval <= 4) {
      interval = 2.0;  // Use 2.0 instead of jumping to 5.0
    } else if (interval <= 7) {
      interval = 5.0;
    } else if (interval <= 12) {
      interval = 10.0;
    } else {
      interval = (interval / 10).ceil() * 10.0;
    }
    
    // Calculate nice bounds that include all data
    final minY = (dataMin / interval).floor() * interval;
    final maxY = (dataMax / interval).ceil() * interval;
    
    // Ensure we have at least some range
    final finalMinY = minY;
    final finalMaxY = maxY > minY ? maxY : minY + interval * 2;
    
    return {
      'minY': finalMinY,
      'maxY': finalMaxY,
      'interval': interval
    };
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

    // Calculate Y-axis bounds and interval
    final yAxisConfig = _calculateYAxisConfig();

    return LineChart(
      LineChartData(
        minY: yAxisConfig['minY'],
        maxY: yAxisConfig['maxY'],
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
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final spotIndex = touchedSpot.spotIndex;
                final dataItem = widget.data[spotIndex];
                
                // Format date
                String dateText = '';
                if (dataItem.containsKey('date')) {
                  final dateStr = dataItem['date'] as String;
                  final parts = dateStr.split('-');
                  if (parts.length >= 3) {
                    dateText = '${parts[1]}/${parts[2]}/${parts[0]}';
                  }
                }
                
                // Format value with unit
                final value = touchedSpot.y.toStringAsFixed(2);
                final unit = widget.config.unit ?? '';
                final valueWithUnit = '$value${unit.isNotEmpty ? ' $unit' : ''}';
                
                // Combine date and value on separate lines
                final tooltipText = dateText.isNotEmpty 
                    ? '$dateText\n$valueWithUnit'
                    : valueWithUnit;
                
                return LineTooltipItem(
                  tooltipText,
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: yAxisConfig['interval'],
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
              interval: widget.data.length > 10 ? (widget.data.length / 10).ceilToDouble() : 1,
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

    // Calculate Y-axis bounds and interval
    final yAxisConfig = _calculateYAxisConfig();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        minY: yAxisConfig['minY'],
        maxY: yAxisConfig['maxY'],
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dataItem = widget.data[groupIndex];
              
              // Format date
              String dateText = '';
              if (dataItem.containsKey('date')) {
                final dateStr = dataItem['date'] as String;
                final parts = dateStr.split('-');
                if (parts.length >= 3) {
                  dateText = '${parts[1]}/${parts[2]}/${parts[0]}';
                }
              }
              
              // Format value with unit
              final value = rod.toY.toStringAsFixed(2);
              final unit = widget.config.unit ?? '';
              final valueWithUnit = '$value${unit.isNotEmpty ? ' $unit' : ''}';
              
              // Combine date and value on separate lines
              final tooltipText = dateText.isNotEmpty 
                  ? '$dateText\n$valueWithUnit'
                  : valueWithUnit;
              
              return BarTooltipItem(
                tooltipText,
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: yAxisConfig['interval'],
              getTitlesWidget: (value, meta) {
                // Only show ticks that align with our calculated interval
                final interval = yAxisConfig['interval']!;
                final minY = yAxisConfig['minY']!;
                
                // Check if this value is at a valid interval position
                final relativeValue = value - minY;
                final isValidTick = (relativeValue % interval).abs() < 0.01; // Allow small floating point errors
                
                if (isValidTick) {
                  return Text(
                    value.toStringAsFixed(value % 1 == 0 ? 0 : 1), // Show decimals only when needed
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return const SizedBox.shrink(); // Hide invalid ticks
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60, // Increased for month names + year headers with better spacing
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                
                if (index >= 0 && index < widget.data.length) {
                  final item = widget.data[index];
                  
                  // Extract month name from date or label
                  String monthLabel = '';
                  if (item.containsKey('date')) {
                    final dateStr = item['date'] as String;
                    final parts = dateStr.split('-');
                    if (parts.length >= 2) {
                      final month = int.tryParse(parts[1]);
                      if (month != null && month >= 1 && month <= 12) {
                        final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        monthLabel = monthNames[month - 1];
                      }
                    }
                  } else if (item.containsKey('label')) {
                    monthLabel = item['label'].toString();
                    if (monthLabel.length > 3) {
                      monthLabel = monthLabel.substring(0, 3);
                    }
                  }
                  
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Month label at top
                      Text(
                        monthLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      // Year label positioned between months (if needed)
                      ..._buildYearLabels(index),
                    ],
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

    // Calculate Y-axis bounds and interval
    final yAxisConfig = _calculateYAxisConfig();

    return LineChart(
      LineChartData(
        minY: yAxisConfig['minY'],
        maxY: yAxisConfig['maxY'],
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
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final spotIndex = touchedSpot.spotIndex;
                final dataItem = widget.data[spotIndex];
                
                // Format date
                String dateText = '';
                if (dataItem.containsKey('date')) {
                  final dateStr = dataItem['date'] as String;
                  final parts = dateStr.split('-');
                  if (parts.length >= 3) {
                    dateText = '${parts[1]}/${parts[2]}/${parts[0]}';
                  }
                }
                
                // Format value with unit
                final value = touchedSpot.y.toStringAsFixed(2);
                final unit = widget.config.unit ?? '';
                final valueWithUnit = '$value${unit.isNotEmpty ? ' $unit' : ''}';
                
                // Combine date and value on separate lines
                final tooltipText = dateText.isNotEmpty 
                    ? '$dateText\n$valueWithUnit'
                    : valueWithUnit;
                
                return LineTooltipItem(
                  tooltipText,
                  TextStyle(
                    color: colors[touchedSpot.barIndex % colors.length],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: yAxisConfig['interval'],
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
              interval: widget.data.length > 10 ? (widget.data.length / 10).ceilToDouble() : 1,
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