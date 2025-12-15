import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

/// Indicador visual de status de conectividade e sincronização
class SyncIndicator extends StatefulWidget {
  final ConnectivityService connectivity;

  const SyncIndicator({
    super.key,
    required this.connectivity,
  });

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _isOnline = widget.connectivity.isOnline;
    widget.connectivity.connectivityStream.listen((isOnline) {
      if (mounted) {
        setState(() => _isOnline = isOnline);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isOnline ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          _isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 12,
            color: _isOnline ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}



