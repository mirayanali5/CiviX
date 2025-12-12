import 'package:flutter/material.dart';
import 'dart:async';

class ComplaintSuccessDialog extends StatefulWidget {
  final Map<String, dynamic> complaint;

  const ComplaintSuccessDialog({
    super.key,
    required this.complaint,
  });

  @override
  State<ComplaintSuccessDialog> createState() => _ComplaintSuccessDialogState();
}

class _ComplaintSuccessDialogState extends State<ComplaintSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // Auto close after 4 seconds
    _autoCloseTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in-progress':
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return 'Open';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
        return Colors.orange;
      case 'in-progress':
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF00FFCC), // Teal color from image
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Complaint Registered Successfully!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Complaint Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Complaint ID',
                        complaint['id']?.toString().substring(0, 8) ?? 'N/A',
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Department',
                        complaint['department'] ?? 'Pending Classification',
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Status',
                        _getStatusText(complaint['status']),
                        statusColor: _getStatusColor(complaint['status']),
                      ),
                      if (complaint['tags'] != null && (complaint['tags'] as List).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Tags',
                          (complaint['tags'] as List).join(', '),
                        ),
                      ],
                      if (complaint['latitude'] != null && complaint['longitude'] != null) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Location',
                          '${(complaint['latitude'] as num).toStringAsFixed(6)}, ${(complaint['longitude'] as num).toStringAsFixed(6)}',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Redirecting message
                const Text(
                  'Redirecting to Dashboard...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: statusColor ?? Colors.black,
              fontWeight: statusColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
