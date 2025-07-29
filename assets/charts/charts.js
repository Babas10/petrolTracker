/**
 * Chart Manager for Petrol Tracker D3.js Charts
 * Handles chart rendering, data processing, and Flutter communication
 */
class ChartManager {
    constructor() {
        this.currentChart = null;
        this.currentData = null;
        this.currentType = null;
        this.margin = { top: 40, right: 80, bottom: 60, left: 80 };
        this.tooltip = null;
        this.initializeTooltip();
    }

    /**
     * Initialize tooltip element
     */
    initializeTooltip() {
        this.tooltip = d3.select('body')
            .append('div')
            .attr('class', 'tooltip');
    }

    /**
     * Handle messages from Flutter
     */
    handleFlutterMessage(message) {
        try {
            const { type, data, chartType, options } = message;
            
            switch (type) {
                case 'renderChart':
                    this.renderChart(chartType, data, options);
                    break;
                case 'updateData':
                    this.updateChart(data);
                    break;
                case 'resize':
                    this.resizeChart();
                    break;
                case 'clearChart':
                    this.clearChart();
                    break;
                default:
                    console.warn('Unknown message type:', type);
            }
        } catch (error) {
            console.error('Error handling Flutter message:', error);
            this.showError('Error processing chart data');
        }
    }

    /**
     * Render a chart based on type and data
     */
    renderChart(chartType, data, options = {}) {
        try {
            this.hideLoading();
            this.hideError();
            this.clearChart();

            this.currentType = chartType;
            this.currentData = data;

            if (!data || data.length === 0) {
                this.showError('No data available');
                return;
            }

            switch (chartType) {
                case 'line':
                    this.renderLineChart(data, options);
                    break;
                case 'bar':
                    this.renderBarChart(data, options);
                    break;
                case 'area':
                    this.renderAreaChart(data, options);
                    break;
                case 'multiLine':
                    this.renderMultiLineChart(data, options);
                    break;
                default:
                    this.showError(`Unsupported chart type: ${chartType}`);
                    return;
            }

            this.showChart();
            this.notifyFlutter('chartRendered', { chartType, dataPoints: data.length });
        } catch (error) {
            console.error('Error rendering chart:', error);
            this.showError('Error rendering chart');
        }
    }

    /**
     * Render line chart
     */
    renderLineChart(data, options) {
        const container = d3.select('#chart');
        const containerRect = container.node().getBoundingClientRect();
        const width = containerRect.width - this.margin.left - this.margin.right;
        const height = containerRect.height - this.margin.top - this.margin.bottom;

        const svg = container.append('svg')
            .attr('width', containerRect.width)
            .attr('height', containerRect.height);

        const g = svg.append('g')
            .attr('transform', `translate(${this.margin.left},${this.margin.top})`);

        // Parse dates
        const parseDate = d3.timeParse('%Y-%m-%d');
        data.forEach(d => {
            d.date = parseDate(d.date) || new Date(d.date);
            d.value = +d.value;
        });

        // Scales
        const xScale = d3.scaleTime()
            .domain(d3.extent(data, d => d.date))
            .range([0, width]);

        const yScale = d3.scaleLinear()
            .domain(d3.extent(data, d => d.value))
            .nice()
            .range([height, 0]);

        // Line generator
        const line = d3.line()
            .x(d => xScale(d.date))
            .y(d => yScale(d.value))
            .curve(d3.curveMonotoneX);

        // Add grid
        this.addGrid(g, xScale, yScale, width, height);

        // Add axes
        this.addAxes(g, xScale, yScale, width, height, options);

        // Add line
        g.append('path')
            .datum(data)
            .attr('class', `line ${options.className || 'consumption'}`)
            .attr('d', line);

        // Add dots
        g.selectAll('.dot')
            .data(data)
            .enter().append('circle')
            .attr('class', `dot ${options.className || 'consumption'}`)
            .attr('cx', d => xScale(d.date))
            .attr('cy', d => yScale(d.value))
            .on('mouseover', (event, d) => this.showTooltip(event, d, options))
            .on('mouseout', () => this.hideTooltip())
            .on('click', (event, d) => this.notifyFlutter('dataPointClicked', d));

        // Add title
        if (options.title) {
            svg.append('text')
                .attr('class', 'chart-title')
                .attr('x', containerRect.width / 2)
                .attr('y', 25)
                .text(options.title);
        }

        this.currentChart = { svg, g, xScale, yScale, data };
    }

    /**
     * Render bar chart
     */
    renderBarChart(data, options) {
        const container = d3.select('#chart');
        const containerRect = container.node().getBoundingClientRect();
        const width = containerRect.width - this.margin.left - this.margin.right;
        const height = containerRect.height - this.margin.top - this.margin.bottom;

        const svg = container.append('svg')
            .attr('width', containerRect.width)
            .attr('height', containerRect.height);

        const g = svg.append('g')
            .attr('transform', `translate(${this.margin.left},${this.margin.top})`);

        // Ensure numeric values
        data.forEach(d => {
            d.value = +d.value;
        });

        // Scales
        const xScale = d3.scaleBand()
            .domain(data.map(d => d.label))
            .range([0, width])
            .padding(0.1);

        const yScale = d3.scaleLinear()
            .domain([0, d3.max(data, d => d.value)])
            .nice()
            .range([height, 0]);

        // Add grid
        this.addGrid(g, xScale, yScale, width, height, true);

        // Add axes
        this.addAxes(g, xScale, yScale, width, height, options, true);

        // Add bars
        g.selectAll('.bar')
            .data(data)
            .enter().append('rect')
            .attr('class', `bar ${options.className || 'consumption'}`)
            .attr('x', d => xScale(d.label))
            .attr('width', xScale.bandwidth())
            .attr('y', d => yScale(d.value))
            .attr('height', d => height - yScale(d.value))
            .on('mouseover', (event, d) => this.showTooltip(event, d, options))
            .on('mouseout', () => this.hideTooltip())
            .on('click', (event, d) => this.notifyFlutter('dataPointClicked', d));

        // Add title
        if (options.title) {
            svg.append('text')
                .attr('class', 'chart-title')
                .attr('x', containerRect.width / 2)
                .attr('y', 25)
                .text(options.title);
        }

        this.currentChart = { svg, g, xScale, yScale, data };
    }

    /**
     * Render area chart
     */
    renderAreaChart(data, options) {
        const container = d3.select('#chart');
        const containerRect = container.node().getBoundingClientRect();
        const width = containerRect.width - this.margin.left - this.margin.right;
        const height = containerRect.height - this.margin.top - this.margin.bottom;

        const svg = container.append('svg')
            .attr('width', containerRect.width)
            .attr('height', containerRect.height);

        const g = svg.append('g')
            .attr('transform', `translate(${this.margin.left},${this.margin.top})`);

        // Parse dates
        const parseDate = d3.timeParse('%Y-%m-%d');
        data.forEach(d => {
            d.date = parseDate(d.date) || new Date(d.date);
            d.value = +d.value;
        });

        // Scales
        const xScale = d3.scaleTime()
            .domain(d3.extent(data, d => d.date))
            .range([0, width]);

        const yScale = d3.scaleLinear()
            .domain([0, d3.max(data, d => d.value)])
            .nice()
            .range([height, 0]);

        // Area generator
        const area = d3.area()
            .x(d => xScale(d.date))
            .y0(height)
            .y1(d => yScale(d.value))
            .curve(d3.curveMonotoneX);

        // Line generator
        const line = d3.line()
            .x(d => xScale(d.date))
            .y(d => yScale(d.value))
            .curve(d3.curveMonotoneX);

        // Add grid
        this.addGrid(g, xScale, yScale, width, height);

        // Add axes
        this.addAxes(g, xScale, yScale, width, height, options);

        // Add area
        g.append('path')
            .datum(data)
            .attr('class', `area ${options.className || 'consumption'}`)
            .attr('d', area);

        // Add line
        g.append('path')
            .datum(data)
            .attr('class', `line ${options.className || 'consumption'}`)
            .attr('d', line);

        // Add dots
        g.selectAll('.dot')
            .data(data)
            .enter().append('circle')
            .attr('class', `dot ${options.className || 'consumption'}`)
            .attr('cx', d => xScale(d.date))
            .attr('cy', d => yScale(d.value))
            .on('mouseover', (event, d) => this.showTooltip(event, d, options))
            .on('mouseout', () => this.hideTooltip())
            .on('click', (event, d) => this.notifyFlutter('dataPointClicked', d));

        // Add title
        if (options.title) {
            svg.append('text')
                .attr('class', 'chart-title')
                .attr('x', containerRect.width / 2)
                .attr('y', 25)
                .text(options.title);
        }

        this.currentChart = { svg, g, xScale, yScale, data };
    }

    /**
     * Render multi-line chart
     */
    renderMultiLineChart(data, options) {
        const container = d3.select('#chart');
        const containerRect = container.node().getBoundingClientRect();
        const width = containerRect.width - this.margin.left - this.margin.right;
        const height = containerRect.height - this.margin.top - this.margin.bottom;

        const svg = container.append('svg')
            .attr('width', containerRect.width)
            .attr('height', containerRect.height);

        const g = svg.append('g')
            .attr('transform', `translate(${this.margin.left},${this.margin.top})`);

        // Process data
        const parseDate = d3.timeParse('%Y-%m-%d');
        const series = options.series || Object.keys(data[0]).filter(key => key !== 'date');
        
        data.forEach(d => {
            d.date = parseDate(d.date) || new Date(d.date);
            series.forEach(key => {
                d[key] = +d[key];
            });
        });

        // Scales
        const xScale = d3.scaleTime()
            .domain(d3.extent(data, d => d.date))
            .range([0, width]);

        const yScale = d3.scaleLinear()
            .domain([0, d3.max(data, d => d3.max(series, key => d[key]))])
            .nice()
            .range([height, 0]);

        const colorScale = d3.scaleOrdinal()
            .domain(series)
            .range(['#4caf50', '#2196f3', '#ff9800', '#e91e63', '#9c27b0']);

        // Line generator
        const line = d3.line()
            .x(d => xScale(d.date))
            .y(d => yScale(d.value))
            .curve(d3.curveMonotoneX);

        // Add grid
        this.addGrid(g, xScale, yScale, width, height);

        // Add axes
        this.addAxes(g, xScale, yScale, width, height, options);

        // Add lines
        series.forEach(key => {
            const lineData = data.map(d => ({ date: d.date, value: d[key] }));
            
            g.append('path')
                .datum(lineData)
                .attr('class', 'line')
                .attr('stroke', colorScale(key))
                .attr('d', line);

            // Add dots
            g.selectAll(`.dot-${key}`)
                .data(lineData)
                .enter().append('circle')
                .attr('class', 'dot')
                .attr('cx', d => xScale(d.date))
                .attr('cy', d => yScale(d.value))
                .attr('fill', colorScale(key))
                .on('mouseover', (event, d) => this.showTooltip(event, { ...d, series: key }, options))
                .on('mouseout', () => this.hideTooltip())
                .on('click', (event, d) => this.notifyFlutter('dataPointClicked', { ...d, series: key }));
        });

        // Add legend
        this.addLegend(svg, series, colorScale, containerRect.width, options);

        // Add title
        if (options.title) {
            svg.append('text')
                .attr('class', 'chart-title')
                .attr('x', containerRect.width / 2)
                .attr('y', 25)
                .text(options.title);
        }

        this.currentChart = { svg, g, xScale, yScale, data, series, colorScale };
    }

    /**
     * Smart tick selection algorithm for x-axis optimization
     * Returns array of indices that should show labels
     */
    getOptimalTickIndices(dataLength, maxTicks = 10) {
        if (dataLength <= maxTicks) {
            // If we have few data points, show all
            return Array.from({ length: dataLength }, (_, i) => i);
        }

        const ticks = [];
        
        // Always include first and last
        ticks.push(0);
        if (dataLength > 1) {
            ticks.push(dataLength - 1);
        }

        // Calculate how many intermediate ticks we can fit
        const intermediateTicks = maxTicks - 2; // Subtract first and last
        
        if (intermediateTicks > 0) {
            // Distribute intermediate ticks evenly across data points
            for (let i = 1; i <= intermediateTicks; i++) {
                const position = (dataLength - 1) * i / (intermediateTicks + 1);
                const index = Math.round(position);
                
                // Avoid duplicates with first/last and ensure valid range
                if (index > 0 && index < dataLength - 1 && !ticks.includes(index)) {
                    ticks.push(index);
                }
            }
        }

        // Sort to ensure proper order
        return ticks.sort((a, b) => a - b);
    }

    /**
     * Check if an index should show a label based on optimal tick selection
     */
    shouldShowTick(index, dataLength) {
        const optimalTicks = this.getOptimalTickIndices(dataLength);
        return optimalTicks.includes(index);
    }

    /**
     * Add grid lines
     */
    addGrid(g, xScale, yScale, width, height, isBandScale = false) {
        // X grid
        if (!isBandScale) {
            g.append('g')
                .attr('class', 'grid')
                .attr('transform', `translate(0,${height})`)
                .call(d3.axisBottom(xScale)
                    .tickSize(-height)
                    .tickFormat('')
                );
        }

        // Y grid
        g.append('g')
            .attr('class', 'grid')
            .call(d3.axisLeft(yScale)
                .tickSize(-width)
                .tickFormat('')
            );
    }

    /**
     * Add axes with smart tick selection
     */
    addAxes(g, xScale, yScale, width, height, options, isBandScale = false) {
        // Create X axis with controlled tick count
        let xAxis;
        if (isBandScale) {
            // For bar charts, control number of ticks
            const domain = xScale.domain();
            const maxTicks = Math.min(6, domain.length);
            const optimalTicks = this.getOptimalTickIndices(domain.length, maxTicks);
            
            xAxis = d3.axisBottom(xScale)
                .tickValues(optimalTicks.map(i => domain[i]))
                .tickFormat(d => d);
        } else {
            // For time-based charts, control tick count directly
            const dataLength = this.currentData ? this.currentData.length : 0;
            const maxTicks = 10; // Always try to show 10 ticks
            
            if (dataLength > 0) {
                const optimalIndices = this.getOptimalTickIndices(dataLength, maxTicks);
                const tickValues = optimalIndices.map(i => this.currentData[i].date);
                
                xAxis = d3.axisBottom(xScale)
                    .tickValues(tickValues)
                    .tickFormat(d3.timeFormat('%m/%d'));
            } else {
                xAxis = d3.axisBottom(xScale)
                    .ticks(maxTicks)
                    .tickFormat(d3.timeFormat('%m/%d'));
            }
        }
        
        g.append('g')
            .attr('class', 'axis')
            .attr('transform', `translate(0,${height})`)
            .call(xAxis);

        // Y axis (unchanged)
        g.append('g')
            .attr('class', 'axis')
            .call(d3.axisLeft(yScale));

        // Axis labels
        if (options.xLabel) {
            g.append('text')
                .attr('transform', `translate(${width / 2}, ${height + 50})`)
                .style('text-anchor', 'middle')
                .style('font-size', '12px')
                .style('fill', '#666')
                .text(options.xLabel);
        }

        if (options.yLabel) {
            g.append('text')
                .attr('transform', 'rotate(-90)')
                .attr('y', 0 - this.margin.left + 20)
                .attr('x', 0 - (height / 2))
                .style('text-anchor', 'middle')
                .style('font-size', '12px')
                .style('fill', '#666')
                .text(options.yLabel);
        }
    }

    /**
     * Add legend
     */
    addLegend(svg, series, colorScale, containerWidth, options) {
        const legend = svg.append('g')
            .attr('class', 'legend')
            .attr('transform', `translate(${containerWidth - 120}, 50)`);

        const legendItems = legend.selectAll('.legend-item')
            .data(series)
            .enter().append('g')
            .attr('class', 'legend-item')
            .attr('transform', (d, i) => `translate(0, ${i * 20})`);

        legendItems.append('rect')
            .attr('width', 12)
            .attr('height', 12)
            .attr('fill', colorScale);

        legendItems.append('text')
            .attr('x', 18)
            .attr('y', 9)
            .attr('dy', '0.35em')
            .text(d => options.seriesLabels?.[d] || d);
    }

    /**
     * Show tooltip
     */
    showTooltip(event, data, options) {
        const formatValue = options.formatValue || (d => d.value?.toFixed(2) || d.value);
        const formatDate = d3.timeFormat('%B %d, %Y');
        
        let content = '';
        
        // Add date on first line
        if (data.date) {
            content += `${formatDate(data.date)}<br>`;
        }
        
        // Add value with unit on second line
        const valueText = formatValue(data);
        const unit = options.unit || '';
        content += `${valueText}${unit ? ` ${unit}` : ''}`;

        this.tooltip
            .html(content)
            .style('left', (event.pageX + 10) + 'px')
            .style('top', (event.pageY - 10) + 'px')
            .classed('visible', true);
    }

    /**
     * Hide tooltip
     */
    hideTooltip() {
        this.tooltip.classed('visible', false);
    }

    /**
     * Update chart with new data
     */
    updateChart(newData) {
        if (!this.currentChart || !this.currentType) {
            console.warn('No chart to update');
            return;
        }

        this.renderChart(this.currentType, newData, this.currentOptions);
    }

    /**
     * Resize chart
     */
    resizeChart() {
        if (!this.currentChart || !this.currentType) {
            return;
        }

        this.renderChart(this.currentType, this.currentData, this.currentOptions);
    }

    /**
     * Clear chart
     */
    clearChart() {
        d3.select('#chart').selectAll('*').remove();
        this.currentChart = null;
    }

    /**
     * Show loading state
     */
    showLoading() {
        document.getElementById('loading').classList.remove('hidden');
        document.getElementById('error').classList.add('hidden');
        document.getElementById('chart').classList.add('hidden');
    }

    /**
     * Hide loading state
     */
    hideLoading() {
        document.getElementById('loading').classList.add('hidden');
    }

    /**
     * Show error state
     */
    showError(message) {
        document.getElementById('error').classList.remove('hidden');
        document.getElementById('loading').classList.add('hidden');
        document.getElementById('chart').classList.add('hidden');
        document.querySelector('.error-message').textContent = message;
    }

    /**
     * Hide error state
     */
    hideError() {
        document.getElementById('error').classList.add('hidden');
    }

    /**
     * Show chart
     */
    showChart() {
        document.getElementById('chart').classList.remove('hidden');
        document.getElementById('chart').classList.add('chart-enter');
    }

    /**
     * Retry chart rendering
     */
    retryChart() {
        if (this.currentType && this.currentData) {
            this.renderChart(this.currentType, this.currentData, this.currentOptions);
        } else {
            this.notifyFlutter('retryRequested');
        }
    }

    /**
     * Notify Flutter of events
     */
    notifyFlutter(eventType, data = {}) {
        const message = { eventType, data, timestamp: Date.now() };
        
        try {
            // Try different communication methods
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('onChartEvent', JSON.stringify(message));
            } else if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.chartEvent) {
                window.webkit.messageHandlers.chartEvent.postMessage(JSON.stringify(message));
            } else if (window.parent && window.parent !== window) {
                window.parent.postMessage(message, '*');
            } else {
                console.log('Chart event:', message);
            }
        } catch (error) {
            console.error('Error notifying Flutter:', error);
        }
    }
}