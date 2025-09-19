import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:petrol_tracker/providers/theme_providers.dart';
import 'package:petrol_tracker/providers/units_providers.dart';

// No conditional imports - handle platform differences in code

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
class ChartWebView extends ConsumerStatefulWidget {
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
  ConsumerState<ChartWebView> createState() => _ChartWebViewState();
}

class _ChartWebViewState extends ConsumerState<ChartWebView> {
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
            // Give D3.js a moment to initialize, then mark as ready
            Future.delayed(const Duration(milliseconds: 500), () {
              print('WebView page finished loading, marking as ready');
              _isWebViewReady = true;
              _renderChart();
              widget.onChartReady?.call();
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
            if (message.message.isEmpty) return;
            
            final data = jsonDecode(message.message) as Map<String, dynamic>;
            final eventType = data['eventType'] as String? ?? data['type'] as String?;
            final eventData = data['data'] as Map<String, dynamic>? ?? {};
            
            if (eventType == 'log') {
              // Print D3.js console logs to Flutter console
              print('D3.js: ${data['message']}');
            } else if (eventType == 'ready') {
              // Handle ready signal from D3.js
              print('D3.js ready signal received!');
              _isWebViewReady = true;
              _renderChart();
              widget.onChartReady?.call();
            } else if (eventType != null) {
              widget.onChartEvent?.call(eventType, eventData);
            }
          } catch (e) {
            debugPrint('Error parsing chart event: $e');
            debugPrint('Message was: ${message.message}');
          }
        },
      );

    _loadHtmlAsset();
  }

  Future<void> _loadHtmlAsset() async {
    try {
      // Load all the required assets
      final String htmlContent = await rootBundle.loadString('assets/charts/index.html');
      final String jsContent = await rootBundle.loadString('assets/charts/charts.js');
      final String cssContent = await rootBundle.loadString('assets/charts/styles.css');
      
      // Create self-contained HTML with inline CSS and JS
      final String completeHtml = '''
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Petrol Tracker Charts</title>
          <script src="https://d3js.org/d3.v7.min.js"></script>
          <style>
              $cssContent
              
              /* Remove all default margins and padding to eliminate white gaps */
              html, body {
                  margin: 0 !important;
                  padding: 0 !important;
                  width: 100%;
                  height: 100%;
                  overflow: hidden;
              }
              
              /* Ensure chart container fills ALL available space with no gaps */
              #chart-container {
                  width: 100%;
                  height: 100vh;
                  margin: 0;
                  padding: 0;
                  display: flex;
                  flex-direction: column;
              }
              
              #chart {
                  flex: 1;
                  width: 100%;
                  height: 100%;
                  min-height: 200px;
                  margin: 0;
                  padding: 0;
              }
              
              #chart svg {
                  width: 100% !important;
                  height: 100% !important;
                  display: block;
              }
          </style>
      </head>
      <body>
          <div id="chart-container">
              <div id="loading" class="loading">
                  <div class="loading-spinner"></div>
                  <p>Loading chart...</p>
              </div>
              <div id="error" class="error hidden">
                  <div class="error-icon">⚠️</div>
                  <p class="error-message">Error loading chart</p>
                  <button class="retry-button" onclick="window.chartManager.retryChart()">Retry</button>
              </div>
              <div id="chart" class="chart hidden"></div>
          </div>

          <script>$jsContent</script>
          <script>
              // Override the renderAreaChart method for optimal space usage and styling
              ChartManager.prototype.renderAreaChart = function(data, options) {
                  console.log('🔍 ENHANCED: Custom renderAreaChart called with', data.length, 'data points');
                  console.log('🔍 ENHANCED: Theme colors:', options.theme);
                  console.log('🔍 ENHANCED: Sample data point 0:', JSON.stringify(data[0], null, 2));
                  console.log('🔍 ENHANCED: Data points with isComplexPeriod:', data.filter(d => d.hasOwnProperty('isComplexPeriod')).length);
                  console.log('🔍 ENHANCED: Complex periods:', data.filter(d => d.isComplexPeriod === true).length);
                  console.log('🔍 ENHANCED: Simple periods:', data.filter(d => d.isComplexPeriod === false).length);
                  
                  // Prevent re-entry during rendering
                  if (this._rendering) {
                      console.log('Already rendering, skipping duplicate call');
                      return;
                  }
                  this._rendering = true;
                  
                  try {
                      // Create tooltip div if it doesn't exist
                  let tooltip = d3.select('body').select('.d3-tooltip');
                  if (tooltip.empty()) {
                      tooltip = d3.select('body').append('div')
                          .attr('class', 'd3-tooltip')
                          .style('position', 'absolute')
                          .style('background', 'rgba(0, 0, 0, 0.8)')
                          .style('color', 'white')
                          .style('padding', '8px 12px')
                          .style('border-radius', '4px')
                          .style('font-size', '12px')
                          .style('font-family', '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif')
                          .style('pointer-events', 'none')
                          .style('opacity', 0)
                          .style('z-index', 1000);
                  }
                  
                  // Smart tooltip positioning function
                  function getSmartTooltipPosition(event, d, containerElement) {
                      // Get chart container dimensions and position
                      const chartRect = containerElement.getBoundingClientRect();
                      const chartWidth = chartRect.width;
                      const chartMidpoint = chartWidth / 2;
                      
                      // Get cursor position relative to chart
                      const cursorX = event.clientX - chartRect.left;
                      
                      // Determine which side of chart we're on
                      const isRightSide = cursorX >= chartMidpoint;
                      
                      // Estimate tooltip dimensions (approximate)
                      const tooltipWidth = 140; // Approximate width based on content
                      const tooltipHeight = 40; // Approximate height for 2 lines
                      
                      let tooltipX, tooltipY;
                      
                      if (isRightSide) {
                          // Position tooltip to the LEFT of cursor (very close positioning)
                          tooltipX = event.pageX - tooltipWidth + 15; // Even closer, bringing it 10px more to the right
                          console.log('Right side positioning: tooltip to the left (very close)');
                      } else {
                          // Position tooltip to the RIGHT of cursor (current behavior)
                          tooltipX = event.pageX + 15; // 15px padding from cursor
                          console.log('Left side positioning: tooltip to the right');
                      }
                      
                      // Always position tooltip above the cursor
                      tooltipY = event.pageY - 15;
                      
                      // Boundary checking to ensure tooltip stays on screen
                      const windowWidth = window.innerWidth;
                      const windowHeight = window.innerHeight;
                      
                      // Adjust for right boundary
                      if (tooltipX + tooltipWidth > windowWidth) {
                          tooltipX = windowWidth - tooltipWidth - 10;
                      }
                      
                      // Adjust for left boundary
                      if (tooltipX < 10) {
                          tooltipX = 10;
                      }
                      
                      // Adjust for top boundary
                      if (tooltipY < 10) {
                          tooltipY = event.pageY + 25; // Position below cursor instead
                      }
                      
                      // Adjust for bottom boundary
                      if (tooltipY + tooltipHeight > windowHeight) {
                          tooltipY = windowHeight - tooltipHeight - 10;
                      }
                      
                      console.log('Smart tooltip position:', {
                          cursorX: cursorX,
                          chartMidpoint: chartMidpoint,
                          isRightSide: isRightSide,
                          finalX: tooltipX,
                          finalY: tooltipY
                      });
                      
                      return { x: tooltipX, y: tooltipY };
                  }
                  
                  // Get theme colors with fallbacks
                  const primaryColor = (options.theme && options.theme.primaryColor) || '#10b981'; // Default green
                  const surfaceColor = (options.theme && options.theme.surfaceColor) || '#f7fbf1'; // Light green background
                  const onSurfaceColor = (options.theme && options.theme.onSurfaceColor) || '#374151';
                  const outlineColor = (options.theme && options.theme.outlineColor) || '#9ca3af';
                  
                  const container = d3.select('#chart');
                  
                  // Get parent element dimensions for responsive sizing with retry mechanism
                  const parentElement = container.node().parentElement;
                  let containerWidth = parentElement.clientWidth || 400;
                  let containerHeight = parentElement.clientHeight || 300;
                  
                  // If dimensions are too small, wait and retry (fixes initial loading issue)
                  if (containerWidth < 100 || containerHeight < 100) {
                      console.log('Container too small, retrying in 100ms...');
                      setTimeout(() => {
                          if (parentElement.clientWidth > 100 && parentElement.clientHeight > 100) {
                              console.log('Retrying chart render with proper dimensions');
                              this.renderAreaChart(data, options);
                          }
                      }, 100);
                      return;
                  }
                  
                  // Optimize margins for maximum chart space usage (shifted down 3px)
                  const margin = { top: 38, right: 20, bottom: 90, left: 50 };
                  const width = containerWidth - margin.left - margin.right;
                  // Use full container height for maximum chart space
                  const height = containerHeight - margin.top - margin.bottom;
                  
                  console.log('Chart dimensions:', { containerWidth, containerHeight, width, height });
                  console.log('Parent dimensions:', { parentWidth: parentElement.clientWidth, parentHeight: parentElement.clientHeight });
                  
                  // Clear any existing content first
                  container.selectAll('*').remove();
                  
                  // Also clear any chart titles specifically
                  d3.selectAll('.chart-title').remove();
                  
                  // Set the container to fill ALL available space with app surface color
                  container
                      .style('width', '100%')
                      .style('height', '100%')
                      .style('min-height', '100%')
                      .style('background-color', surfaceColor)
                      .style('position', 'relative')
                      .style('overflow', 'visible')
                      .style('margin', '0')
                      .style('padding', '0'); // Ensure no gaps
                  
                  // Use full container height - no extra space calculation needed
                  const svgHeight = containerHeight;
                  
                  const svg = container.append('svg')
                      .attr('width', containerWidth)
                      .attr('height', svgHeight)
                      .attr('viewBox', '0 0 ' + containerWidth + ' ' + svgHeight)
                      .attr('preserveAspectRatio', 'xMidYMid meet')
                      .style('width', '100%')
                      .style('height', '100%')
                      .style('display', 'block')
                      .style('background-color', surfaceColor)
                      .style('max-width', '100%')
                      .style('max-height', '100%')
                      .style('overflow', 'visible'); // Ensure content isn't clipped
                      
                  const g = svg.append('g')
                      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');
                  
                  // Parse dates and values
                  const parseDate = d3.timeParse('%Y-%m-%d');
                  data.forEach(d => {
                      d.date = parseDate(d.date) || new Date(d.date);
                      d.value = +d.value;
                  });
                  
                  console.log('Parsed data range:', d3.extent(data, d => d.value));
                  
                  // Create scales with smart Y-axis bounds
                  const xScale = d3.scaleTime()
                      .domain(d3.extent(data, d => d.date))
                      .range([0, width]);
                  
                  const yExtent = d3.extent(data, d => d.value);
                  const yMin = Math.floor(yExtent[0] * 2) / 2; // Round down to nearest 0.5
                  const yMax = Math.ceil(yExtent[1] * 2) / 2;  // Round up to nearest 0.5
                  
                  const yScale = d3.scaleLinear()
                      .domain([yMin, yMax])
                      .range([height, 0]);
                  
                  console.log('Y-axis domain:', [yMin, yMax]);
                  
                  console.log('Starting X-axis tick calculation...');
                  
                  // Function to calculate time-based evenly distributed X-labels
                  function calculateTimeBasedXLabels(data, labelCount = 5) {
                      if (data.length <= labelCount) {
                          // Show all actual data points if 5 or fewer
                          console.log('≤5 data points: using actual data point dates');
                          return data.map(d => d.date);
                      }
                      
                      // Get first and last dates for time range calculation
                      const firstDate = data[0].date;
                      const lastDate = data[data.length - 1].date;
                      
                      console.log('Time range calculation:', {
                          firstDate: firstDate.toISOString().split('T')[0],
                          lastDate: lastDate.toISOString().split('T')[0],
                          totalDataPoints: data.length
                      });
                      
                      // Calculate total time span and interval
                      const totalTimeSpan = lastDate.getTime() - firstDate.getTime(); // milliseconds
                      const timeInterval = totalTimeSpan / (labelCount - 1);
                      
                      console.log('Time calculation:', {
                          totalTimeSpanDays: Math.round(totalTimeSpan / (1000 * 60 * 60 * 24)),
                          intervalDays: Math.round(timeInterval / (1000 * 60 * 60 * 24))
                      });
                      
                      // Generate evenly spaced dates in time
                      const timeBasedLabels = [];
                      for (let i = 0; i < labelCount; i++) {
                          const calculatedDate = new Date(firstDate.getTime() + (i * timeInterval));
                          timeBasedLabels.push(calculatedDate);
                      }
                      
                      console.log('Generated time-based labels:', 
                          timeBasedLabels.map(d => d.toISOString().split('T')[0])
                      );
                      
                      return timeBasedLabels;
                  }
                  
                  // Create exactly 5 time-based X-axis ticks for optimal readability
                  const xTickValues = calculateTimeBasedXLabels(data, 5);
                  console.log('X-axis ticks calculated using time-based distribution');
                  
                  // Create exactly 5 Y-axis ticks
                  const yTickValues = [];
                  for (let i = 0; i < 5; i++) {
                      yTickValues.push(yMin + (yMax - yMin) * i / 4);
                  }
                  console.log('Y-axis ticks calculated');
                  
                  // Area and line generators
                  console.log('Creating area and line generators...');
                  const area = d3.area()
                      .x(d => xScale(d.date))
                      .y0(height)
                      .y1(d => yScale(d.value))
                      .curve(d3.curveMonotoneX);
                      
                  const line = d3.line()
                      .x(d => xScale(d.date))
                      .y(d => yScale(d.value))
                      .curve(d3.curveMonotoneX);
                  console.log('Generators created');
                  
                  // Add subtle horizontal grid lines first (behind everything)
                  console.log('Adding horizontal grid lines...');
                  g.append('g')
                      .attr('class', 'grid horizontal-grid')
                      .attr('opacity', 0.2)
                      .call(d3.axisLeft(yScale)
                          .tickValues(yTickValues)
                          .tickSize(-width)
                          .tickFormat('')
                      );
                  console.log('Horizontal grid lines added');
                  
                  // Add subtle vertical grid lines
                  console.log('Adding vertical grid lines...');
                  g.append('g')
                      .attr('class', 'grid vertical-grid')
                      .attr('opacity', 0.2)
                      .attr('transform', 'translate(0,' + height + ')')
                      .call(d3.axisBottom(xScale)
                          .tickValues(xTickValues)
                          .tickSize(-height)
                          .tickFormat('')
                      );
                  console.log('Vertical grid lines added');
                  
                  // Add X axis with exactly 5 ticks and system font
                  console.log('Adding X-axis...');
                  g.append('g')
                      .attr('class', 'x-axis')
                      .attr('transform', 'translate(0,' + height + ')')
                      .call(d3.axisBottom(xScale)
                          .tickValues(xTickValues)
                          .tickFormat(d3.timeFormat('%m/%d')))
                      .selectAll('text')
                      .style('font-family', '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif')
                      .style('font-size', '13px')
                      .style('font-weight', '500')
                      .style('fill', onSurfaceColor)
                      .attr('dy', '1.35em'); // Move labels 1 pixel down (from default 0.35em to 1.35em)
                  console.log('X-axis added');
                  
                  // Style X axis line and ticks
                  console.log('Styling X-axis...');
                  g.select('.x-axis')
                      .selectAll('path, line')
                      .style('stroke', outlineColor);
                  console.log('X-axis styled');
                  
                  // Year axis is now handled by the separate addYearAxis method
                  console.log('Year axis handled by addYearAxis method');
                  
                  // Add Y axis with exactly 5 ticks and system font
                  console.log('Adding Y-axis...');
                  g.append('g')
                      .attr('class', 'y-axis')
                      .call(d3.axisLeft(yScale)
                          .tickValues(yTickValues)
                          .tickFormat(d3.format('.1f')))
                      .selectAll('text')
                      .style('font-family', '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif')
                      .style('font-size', '13px')
                      .style('font-weight', '500')
                      .style('fill', onSurfaceColor);
                  console.log('Y-axis added');
                  
                  // Style Y axis line and ticks
                  g.select('.y-axis')
                      .selectAll('path, line')
                      .style('stroke', outlineColor);
                  
                  console.log('X-axis tick values:', xTickValues);
                  console.log('Y-axis tick values:', yTickValues);
                  
                  // Calculate year positioning for second X-axis layer
                  let yearData = [];
                  console.log('Starting year calculation...');
                  
                  try {
                      // Extract years from parsed dates
                      const yearSet = new Set();
                      data.forEach((d, index) => {
                          if (d.date && typeof d.date === 'object' && d.date.getFullYear) {
                              const year = d.date.getFullYear();
                              yearSet.add(year);
                          }
                      });
                      
                      const years = Array.from(yearSet).sort((a, b) => a - b);
                      console.log('Extracted years:', years);
                      
                      // Position years in the middle of equal intervals
                      if (years.length === 1) {
                          // Single year - center of entire X-axis
                          yearData = [{ year: years[0], position: width / 2 }];
                      } else {
                          // Multiple years - divide X-axis into n equal intervals
                          const intervalWidth = width / years.length;
                          yearData = years.map((year, index) => ({
                              year: year,
                              position: (index * intervalWidth) + (intervalWidth / 2)
                          }));
                      }
                      
                      console.log('Year data calculated:', yearData);
                  } catch (error) {
                      console.error('Error in year calculation:', error);
                      yearData = [];
                  }
                  
                  console.log('Year positioning:', yearData);
                  
                  // Add area with gradient using theme colors
                  const gradient = svg.append('defs')
                      .append('linearGradient')
                      .attr('id', 'areaGradient')
                      .attr('gradientUnits', 'userSpaceOnUse')
                      .attr('x1', 0).attr('y1', margin.top + height)
                      .attr('x2', 0).attr('y2', margin.top);
                  
                  gradient.append('stop')
                      .attr('offset', '0%')
                      .attr('stop-color', primaryColor)
                      .attr('stop-opacity', 0.1);
                  
                  gradient.append('stop')
                      .attr('offset', '100%')
                      .attr('stop-color', primaryColor)
                      .attr('stop-opacity', 0.4);
                  
                  g.append('path')
                      .datum(data)
                      .attr('class', 'area')
                      .attr('d', area)
                      .style('fill', 'url(#areaGradient)');
                  
                  // Add line using theme color
                  g.append('path')
                      .datum(data)
                      .attr('class', 'line')
                      .attr('d', line)
                      .style('fill', 'none')
                      .style('stroke', primaryColor)
                      .style('stroke-width', 3);
                  
                  // Add circles for each data point with visual distinction for period types
                  g.selectAll('.dot')
                      .data(data)
                      .enter().append('circle')
                      .attr('class', d => {
                          const baseClass = 'dot';
                          if (d.hasOwnProperty('isComplexPeriod')) {
                              return d.isComplexPeriod ? baseClass + ' complex-period' : baseClass + ' simple-period';
                          }
                          return baseClass;
                      })
                      .attr('cx', d => xScale(d.date))
                      .attr('cy', d => yScale(d.value))
                      .attr('r', 4) // Standard radius for all dots
                      .style('fill', primaryColor) // Always use green (primary theme color)
                      .style('stroke', surfaceColor) // Standard stroke color
                      .style('stroke-width', 2)
                      .style('cursor', 'pointer')
                      .on('click', function(event, d) {
                          // Stop event propagation to prevent chart background click
                          event.stopPropagation();
                          
                          // FIRST: Reset ALL data points to original state
                          g.selectAll('.dot')
                              .attr('r', 4) // Reset to original size
                              .style('fill', primaryColor) // Back to green
                              .style('stroke', surfaceColor) // Back to original stroke
                              .style('stroke-width', 2); // Reset stroke width
                          
                          // THEN: Activate the clicked data point
                          const clickedElement = d3.select(this);
                          clickedElement.attr('r', 6); // Enlarged on click
                          
                          // Change appearance on click with subtle visual feedback
                          clickedElement
                              .style('fill', primaryColor) // Keep the same green
                              .style('stroke', '#e0e0e0') // Lighter gray outer ring
                              .style('stroke-width', 3); // Slightly thicker stroke
                          
                          // Format the date
                          const formatDate = d3.timeFormat('%B %d, %Y');
                          const dateText = formatDate(d.date);
                          
                          // Format the value with unit
                          const unit = options.unit || '';
                          const valueText = d.value.toFixed(2);
                          const valueWithUnit = unit ? valueText + ' ' + unit : valueText;
                          
                          // Build enhanced tooltip content with period information
                          let tooltipContent = '<div class="tooltip-date">' + dateText + '</div>';
                          tooltipContent += '<div class="tooltip-value">' + valueWithUnit + '</div>';
                          
                          // Add simple period information if available
                          if (d.totalEntries && d.totalEntries > 1) {
                              tooltipContent += '<div class="tooltip-separator"></div>';
                              tooltipContent += '<div class="tooltip-period-info" style="color: #666;">';
                              tooltipContent += d.totalEntries + ' entries';
                              tooltipContent += '</div>';
                          }
                          
                          // Always show "click for details" message for all data points
                          tooltipContent += '<div class="tooltip-click-hint" style="cursor: pointer; background: rgba(0,0,0,0.1); padding: 4px 8px; border-radius: 4px; margin-top: 8px;">Click for details</div>';
                          
                          // Show tooltip with smart positioning and make it clickable
                          const chartContainer = document.querySelector('#chart');
                          const smartPosition = getSmartTooltipPosition(event, d, chartContainer);
                          
                          // Store current data point reference for tooltip click handling
                          tooltip.datum(d);
                          
                          tooltip.transition().duration(200).style('opacity', 1);
                          tooltip.html(tooltipContent)
                              .style('left', smartPosition.x + 'px')
                              .style('top', smartPosition.y + 'px')
                              .style('pointer-events', 'all') // Make tooltip clickable
                              .on('click', function(tooltipEvent) {
                                  // Handle tooltip click - show period details
                                  tooltipEvent.stopPropagation();
                                  console.log('🔍 TOOLTIP CLICKED:', d);
                                  
                                  if (d.periodData) {
                                      // Send click event with period data to Flutter
                                      if (window.flutter_inappwebview) {
                                          window.flutter_inappwebview.callHandler('chartEvent', JSON.stringify({
                                              eventType: 'click',
                                              data: d
                                          }));
                                      } else if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.chartEvent) {
                                          window.webkit.messageHandlers.chartEvent.postMessage(JSON.stringify({
                                              eventType: 'click',
                                              data: d
                                          }));
                                      } else {
                                          console.log('Chart click event (no Flutter bridge):', d);
                                      }
                                  }
                              });
                      });
                  
                  // Add click handler to chart background to dismiss tooltip
                  svg.on('click', function(event) {
                      // Reset all data points to original state
                      g.selectAll('.dot')
                          .attr('r', 4) // Reset to original size
                          .style('fill', primaryColor) // Back to green
                          .style('stroke', surfaceColor) // Back to original stroke
                          .style('stroke-width', 2); // Reset stroke width
                      
                      // Hide tooltip
                      tooltip.transition().duration(200).style('opacity', 0)
                          .style('pointer-events', 'none');
                      
                      console.log('🔍 CHART BACKGROUND CLICKED: Tooltip dismissed');
                  });
                  
                  // Add cache-busting timestamp in title for verification
                  const timestamp = new Date().toISOString();
                  console.log('🔥 CACHE BUSTER: Chart rendered at', timestamp);
                  
                  // Add centered chart title with titleMedium styling (h2/h3 level)
                  if (options.title) {
                    console.log('🎯 Setting chart title:', options.title);
                    svg.append('text')
                        .attr('class', 'chart-title')
                        .attr('x', containerWidth / 2)
                        .attr('y', 25)
                        .style('text-anchor', 'middle')
                        .style('font-family', 'Roboto, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif')
                        .style('font-size', '16px')
                        .style('font-weight', '500')
                        .style('line-height', '24px')
                        .style('letter-spacing', '0.15px')
                        .style('fill', onSurfaceColor)
                        .text(options.title);
                    console.log('✅ Chart title set successfully');
                  } else {
                    console.log('❌ No title provided in options');
                  }
                  
                      // Legend removed per user request - color distinction now only on hover/click

                      // Add year axis directly here with access to all variables
                      console.log('Adding year axis with main chart context...');
                      
                      if (yearData.length > 0) {
                          try {
                              console.log('Creating year axis group with yearData:', yearData);
                              
                              // Create year axis group positioned below x-axis
                              const yearAxisY = height + 50; // Below x-axis labels
                              console.log('Year axis positioned at:', yearAxisY, 'chart height:', height);
                              
                              const yearAxisGroup = g.append('g')
                                  .attr('class', 'year-axis')
                                  .attr('transform', 'translate(0,' + yearAxisY + ')');
                              
                              // Add year labels with normal styling
                              const labels = yearAxisGroup.selectAll('.year-label')
                                  .data(yearData)
                                  .enter()
                                  .append('text')
                                  .attr('class', 'year-label')
                                  .attr('x', d => d.position)
                                  .attr('y', 0)
                                  .attr('dy', '0.35em')
                                  .style('text-anchor', 'middle')
                                  .style('font-family', '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif')
                                  .style('font-size', '13px')
                                  .style('font-weight', 'normal')
                                  .style('fill', '#666')
                                  .text(d => d.year);
                              
                              console.log('Year labels created:', labels.size(), 'elements');
                              console.log('Year axis added successfully in main context');
                          } catch (yearError) {
                              console.error('Year axis error:', yearError);
                          }
                      } else {
                          console.log('No year data available for axis creation');
                      }
                      
                      console.log('Optimized area chart rendered successfully');
                      
                  } catch (error) {
                      console.error('Error in renderAreaChart:', error);
                      console.error('Error stack:', error.stack);
                  } finally {
                      this._rendering = false;
                  }
              };
              
              // Save original renderBarChart method before overriding
              if (ChartManager.prototype.renderBarChart && !ChartManager.prototype._originalRenderBarChart) {
                  ChartManager.prototype._originalRenderBarChart = ChartManager.prototype.renderBarChart;
              }
              
              // Override the renderBarChart method to ensure consistent title rendering
              ChartManager.prototype.renderBarChart = function(data, options) {
                  console.log('🔍 ENHANCED: Custom renderBarChart called with', data.length, 'data points');
                  console.log('🔍 ENHANCED: Bar chart options:', options);
                  
                  // Call the original renderBarChart method first
                  if (this._originalRenderBarChart) {
                      this._originalRenderBarChart.call(this, data, options);
                  } else {
                      // Fallback: try to call parent method if available
                      console.log('No original renderBarChart found, using default rendering');
                      // This would be the default chart rendering logic
                      this.renderChart(data, options);
                  }
                  
                  // Add chart title after rendering (consistent with area chart)
                  const chartContainer = d3.select('#chart');
                  const containerWidth = chartContainer.node().getBoundingClientRect().width;
                  
                  // Find the SVG element
                  const svg = chartContainer.select('svg');
                  if (svg.empty()) {
                      console.log('❌ No SVG found for bar chart title');
                      return;
                  }
                  
                  // Get theme colors from options
                  const onSurfaceColor = options?.theme?.onSurface || '#1C1B1F';
                  
                  // Remove any existing title first
                  svg.selectAll('.chart-title').remove();
                  
                  // Add centered chart title with titleMedium styling (consistent with area chart)
                  if (options.title) {
                      console.log('🎯 Setting bar chart title:', options.title);
                      svg.append('text')
                          .attr('class', 'chart-title')
                          .attr('x', containerWidth / 2)
                          .attr('y', 25)
                          .style('text-anchor', 'middle')
                          .style('font-family', 'Roboto, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif')
                          .style('font-size', '16px')
                          .style('font-weight', '500')
                          .style('line-height', '24px')
                          .style('letter-spacing', '0.15px')
                          .style('fill', onSurfaceColor)
                          .text(options.title);
                      console.log('✅ Bar chart title set successfully');
                  } else {
                      console.log('❌ No title provided for bar chart');
                  }
              };
          </script>
          <script>
              document.addEventListener('DOMContentLoaded', function() {
                  console.log('D3.js DOM ready, initializing ChartManager...');
                  window.chartManager = new ChartManager();
                  console.log('ChartManager created');
                  
                  // Override console.log to send logs to Flutter
                  const originalLog = console.log;
                  console.log = function(...args) {
                      originalLog.apply(console, args);
                      if (window.chartEvent) {
                          window.chartEvent.postMessage(JSON.stringify({
                              type: 'log',
                              message: args.join(' ')
                          }));
                      }
                  };
                  
                  // Send ready signal to Flutter
                  if (window.flutter_inappwebview) {
                      console.log('Sending ready signal via flutter_inappwebview...');
                      window.flutter_inappwebview.callHandler('onChartReady');
                  } else {
                      console.log('Sending ready signal via chartEvent...');
                      // Fallback - send ready message via postMessage
                      setTimeout(() => {
                          console.log('Sending ready via postMessage...');
                          window.postMessage(JSON.stringify({
                              type: 'ready',
                              message: 'Chart system ready'
                          }), '*');
                      }, 100);
                  }
              });

              window.addEventListener('message', function(event) {
                  console.log('D3.js received message:', event.data);
                  if (event.data && window.chartManager) {
                      try {
                          const data = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
                          console.log('Parsed message data:', data);
                          window.chartManager.handleFlutterMessage(data);
                      } catch (e) {
                          console.error('Error parsing message:', e, 'Raw data:', event.data);
                      }
                  }
              });
          </script>
      </body>
      </html>
      ''';
      
      print('Loading self-contained chart HTML...');
      
      await _controller!.loadHtmlString(completeHtml);
    } catch (e) {
      print('Error loading chart HTML: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load chart: $e';
        _isLoading = false;
      });
      widget.onError?.call('Failed to load chart: $e');
    }
  }

  void _renderChart() {
    print('_renderChart called: ready=$_isWebViewReady, dataCount=${widget.data.length}');
    _sendDataToMobileWebView();
  }

  void _updateChart() {
    print('_updateChart called');
    _sendDataToMobileWebView();
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
    // Use D3.js WebView for area and bar charts on mobile platforms
    // Keep fl_chart for other chart types and web platform until fully migrated
    if (kIsWeb || (widget.config.type != ChartType.area && widget.config.type != ChartType.bar)) {
      return _buildWebFallback(context);
    } else {
      return _buildWebViewForMobile(context);
    }
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

  Widget _buildWebViewForMobile(BuildContext context) {
    // For iOS/Android, use WebView with D3.js charts
    if (_controller == null) {
      return _buildLoadingWidget();
    }

    return WebViewWidget(controller: _controller!);
  }
  
  void _sendDataToMobileWebView() {
    if (!_isWebViewReady || widget.data.isEmpty) {
      print('Not ready to send data: ready=$_isWebViewReady, dataCount=${widget.data.length}');
      return;
    }
    
    // Use theme provider colors instead of extracting from context
    final themeColors = ref.read(chartThemeColorsProvider);
    
    // Send chart data to D3.js in mobile WebView
    final message = {
      'type': 'renderChart',
      'chartType': widget.config.type.name,
      'data': widget.data,
      'options': {
        'title': widget.config.title,
        'xLabel': widget.config.xLabel,
        'yLabel': widget.config.yLabel,
        'unit': widget.config.unit,
        'className': widget.config.className,
        'theme': themeColors
      }
    };
    
    print('Sending chart data: ${widget.data.length} points, type: ${widget.config.type.name}');
    print('Chart title: ${widget.config.title}');
    print('Chart unit: ${widget.config.unit}');
    
    _controller?.runJavaScript('window.postMessage(${jsonEncode(jsonEncode(message))}, "*");');
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

  /// Smart tick selection algorithm for x-axis optimization
  /// Returns list of indices that should show labels
  List<int> _getOptimalTickIndices(int dataLength, {int maxTicks = 10}) {
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
      // Distribute intermediate ticks evenly across data points
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
  /// Calculate comprehensive Y-axis configuration for clean chart display
  /// Handles all edge cases: 0 data points, 1 data point, identical values, and large datasets
  Map<String, double> _calculateYAxisConfig() {
    // Handle empty data - show a meaningful default range
    if (widget.data.isEmpty) {
      return {'minY': 0.0, 'maxY': 10.0, 'interval': 2.0};
    }
    
    // Extract all numeric values from data
    final values = widget.data
        .map((item) => item['value'] as double? ?? 0.0)
        .where((value) => value.isFinite) // Filter out NaN and infinity
        .toList();
    
    // Handle case where no valid values exist
    if (values.isEmpty) {
      return {'minY': 0.0, 'maxY': 10.0, 'interval': 2.0};
    }
    
    final dataMin = values.reduce((a, b) => a < b ? a : b);
    final dataMax = values.reduce((a, b) => a > b ? a : b);
    final dataRange = dataMax - dataMin;
    
    
    // Handle identical values (single point or all same values)
    if (dataRange <= 0.001) { // Use small epsilon for floating point comparison
      final center = dataMin;
      
      // Create appropriate range based on the magnitude of the value
      if (center.abs() < 1.0) {
        // For small values (< 1), use 0.5 interval
        return {
          'minY': center - 1.0,
          'maxY': center + 1.0,
          'interval': 0.5
        };
      } else if (center.abs() < 10.0) {
        // For medium values (1-10), use 1.0 interval
        return {
          'minY': center - 2.0,
          'maxY': center + 2.0,
          'interval': 1.0
        };
      } else {
        // For larger values (>10), use simple interval
        final interval = center.abs() * 0.1; // 10% of value as interval
        return {
          'minY': center - interval * 2,
          'maxY': center + interval * 2,
          'interval': interval
        };
      }
    }
    
    // Control exact Y-axis labels
    final minY = _roundDown(dataMin, 0.5); // Round down to nearest 0.5
    final maxY = _roundUp(dataMax, 0.5);   // Round up to nearest 0.5
    final interval = (maxY - minY) / 4;    // 4 intervals for exactly 5 labels
    
    // Use very small interval to force fl_chart to generate all possible ticks
    final flInterval = 0.01; // Very small to generate many ticks, we'll filter in getTitlesWidget
    
    print('  FORCE-TICK Y-AXIS: dataMin=$dataMin→$minY, dataMax=$dataMax→$maxY');
    print('  Our interval: $interval, fl_chart interval: $flInterval (force all ticks)');
    print('  Expected labels: $minY, ${minY + interval}, ${minY + 2*interval}, ${minY + 3*interval}, ${minY + 4*interval}');
    print('');
    
    return {
      'minY': minY,
      'maxY': maxY,
      'interval': flInterval  // Very small to force many ticks
    };
  }
  
  /// Round value down to nearest step (e.g., 6.05 with step 0.5 → 6.0)
  double _roundDown(double value, double step) {
    return (value / step).floor() * step;
  }
  
  /// Round value up to nearest step (e.g., 7.7 with step 0.5 → 8.0)
  double _roundUp(double value, double step) {
    return (value / step).ceil() * step;
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
          horizontalInterval: yAxisConfig['interval'], // Force grid to use our interval
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
              getTitlesWidget: (value, meta) {
                // Calculate our 5 exact labels
                final minY = yAxisConfig['minY']!;
                final maxY = yAxisConfig['maxY']!;
                final ourInterval = (maxY - minY) / 4;
                
                final exactLabels = [
                  minY,                        // 5.5
                  minY + ourInterval,          // 6.125
                  minY + 2 * ourInterval,      // 6.75  
                  minY + 3 * ourInterval,      // 7.375
                  minY + 4 * ourInterval       // 8.0 (maxY)
                ];
                
                // Only show if value exactly matches one of our labels
                if (!exactLabels.any((label) => (value - label).abs() < 0.001)) {
                  return const SizedBox.shrink();
                }
                
                // Format nicely
                return Text(
                  value.toStringAsFixed(value % 1 == 0 ? 0 : (value * 10) % 1 == 0 ? 1 : 2),
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
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
              getTitlesWidget: (value, meta) {
                // Calculate our 5 exact labels
                final minY = yAxisConfig['minY']!;
                final maxY = yAxisConfig['maxY']!;
                final ourInterval = (maxY - minY) / 4;
                
                final exactLabels = [
                  minY,                        // 5.5
                  minY + ourInterval,          // 6.125
                  minY + 2 * ourInterval,      // 6.75  
                  minY + 3 * ourInterval,      // 7.375
                  minY + 4 * ourInterval       // 8.0 (maxY)
                ];
                
                // Only show if value exactly matches one of our labels
                if (!exactLabels.any((label) => (value - label).abs() < 0.001)) {
                  return const SizedBox.shrink();
                }
                
                // Format nicely
                return Text(
                  value.toStringAsFixed(value % 1 == 0 ? 0 : (value * 10) % 1 == 0 ? 1 : 2),
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60, // Increased for month names + year headers with better spacing
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                
                // Show only alternating labels (every other bar)
                if (index >= 0 && index < widget.data.length && index % 2 == 0) {
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
          horizontalInterval: yAxisConfig['interval'], // Force grid to use our interval
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
              getTitlesWidget: (value, meta) {
                // Calculate our 5 exact labels
                final minY = yAxisConfig['minY']!;
                final maxY = yAxisConfig['maxY']!;
                final ourInterval = (maxY - minY) / 4;
                
                final exactLabels = [
                  minY,                        // 5.5
                  minY + ourInterval,          // 6.125
                  minY + 2 * ourInterval,      // 6.75  
                  minY + 3 * ourInterval,      // 7.375
                  minY + 4 * ourInterval       // 8.0 (maxY)
                ];
                
                // Only show if value exactly matches one of our labels
                if (!exactLabels.any((label) => (value - label).abs() < 0.001)) {
                  return const SizedBox.shrink();
                }
                
                // Format nicely
                return Text(
                  value.toStringAsFixed(value % 1 == 0 ? 0 : (value * 10) % 1 == 0 ? 1 : 2),
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
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