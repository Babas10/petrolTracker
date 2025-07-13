import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrol_tracker/services/app_initialization_service.dart';

/// Screen displayed when app initialization fails critically
/// 
/// This screen provides detailed error information, recovery options,
/// and diagnostic tools to help users resolve initialization issues.
class InitializationErrorScreen extends StatefulWidget {
  /// The initialization error that occurred
  final AppInitializationException error;
  
  /// Callback when user requests to retry initialization
  final VoidCallback? onRetry;
  
  /// Callback when user requests to exit the app
  final VoidCallback? onExit;
  
  const InitializationErrorScreen({
    super.key,
    required this.error,
    this.onRetry,
    this.onExit,
  });

  @override
  State<InitializationErrorScreen> createState() => _InitializationErrorScreenState();
}

class _InitializationErrorScreenState extends State<InitializationErrorScreen> {
  bool _showDetailedError = false;
  bool _isRetrying = false;
  Map<String, dynamic>? _diagnosticInfo;
  
  @override
  void initState() {
    super.initState();
    _loadDiagnosticInfo();
  }
  
  Future<void> _loadDiagnosticInfo() async {
    try {
      final info = await AppInitializationService.getInitializationStatus();
      if (mounted) {
        setState(() {
          _diagnosticInfo = info;
        });
      }
    } catch (e) {
      // Ignore errors during diagnostic loading
    }
  }
  
  Future<void> _handleRetry() async {
    if (!widget.error.canRetry) return;
    
    setState(() {
      _isRetrying = true;
    });
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Brief delay for UX
      widget.onRetry?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }
  
  void _copyErrorToClipboard() {
    final errorDetails = _formatErrorForClipboard();
    Clipboard.setData(ClipboardData(text: errorDetails));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error details copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  String _formatErrorForClipboard() {
    final buffer = StringBuffer();
    buffer.writeln('Petrol Tracker - Initialization Error');
    buffer.writeln('=====================================');
    buffer.writeln();
    buffer.writeln('Error: ${widget.error.message}');
    
    if (widget.error.originalError != null) {
      buffer.writeln('Original Error: ${widget.error.originalError}');
    }
    
    if (widget.error.recoveryHint != null) {
      buffer.writeln('Recovery Hint: ${widget.error.recoveryHint}');
    }
    
    buffer.writeln();
    buffer.writeln('Diagnostic Information:');
    buffer.writeln('-----------------------');
    
    if (_diagnosticInfo != null) {
      _diagnosticInfo!.forEach((key, value) {
        buffer.writeln('$key: $value');
      });
    } else {
      buffer.writeln('Diagnostic information not available');
    }
    
    buffer.writeln();
    buffer.writeln('Timestamp: ${DateTime.now().toIso8601String()}');
    
    return buffer.toString();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      
                      // Error Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.error,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Title
                      Text(
                        'Initialization Failed',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // User-friendly error message
                      Text(
                        widget.error.userFriendlyMessage,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      if (widget.error.recoveryHint != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.error.recoveryHint!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Detailed Error Section
                      _buildDetailedErrorSection(),
                      
                      const SizedBox(height: 32),
                      
                      // Diagnostic Information
                      _buildDiagnosticSection(),
                    ],
                  ),
                ),
              ),
              
              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailedErrorSection() {
    return Card(
      child: ExpansionTile(
        title: const Text('Technical Details'),
        leading: const Icon(Icons.bug_report),
        initiallyExpanded: _showDetailedError,
        onExpansionChanged: (expanded) {
          setState(() {
            _showDetailedError = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Error Type', widget.error.runtimeType.toString()),
                _buildDetailRow('Message', widget.error.message),
                
                if (widget.error.originalError != null)
                  _buildDetailRow('Original Error', widget.error.originalError.toString()),
                
                if (widget.error.stackTrace != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Stack Trace:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.error.stackTrace.toString(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Copy button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _copyErrorToClipboard,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Error Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDiagnosticSection() {
    if (_diagnosticInfo == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Loading diagnostic information...'),
          trailing: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    
    return Card(
      child: ExpansionTile(
        title: const Text('System Information'),
        leading: const Icon(Icons.info),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in _diagnosticInfo!.entries)
                  _buildDetailRow(entry.key, entry.value.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action buttons
        Row(
          children: [
            if (widget.error.canRetry) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRetrying ? null : _handleRetry,
                  icon: _isRetrying 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isRetrying ? 'Retrying...' : 'Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onExit,
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Exit App'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Help text
        Text(
          'If the problem persists, try clearing app data or reinstalling the application.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onErrorContainer.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}