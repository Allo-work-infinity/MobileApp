// lib/modules/usage/cooldown_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_finding/modules/home/controller/job_offer_controller.dart';

class CooldownScreen extends StatefulWidget {
  const CooldownScreen({Key? key}) : super(key: key);

  @override
  State<CooldownScreen> createState() => _CooldownScreenState();
}

class _CooldownScreenState extends State<CooldownScreen> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTick();
  }

  void _startTick() {
    final ctrl = context.read<JobOfferController>();
    final retryAt = ctrl.retryAt;
    if (retryAt == null) return;

    void tick() {
      final now = DateTime.now();
      final diff = retryAt.difference(now);
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });
      if (diff.isNegative) {
        _timer?.cancel();
      }
    }

    tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<JobOfferController>();
    final canRetry = _remaining == Duration.zero;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_clock, size: 84),
              const SizedBox(height: 16),
              const Text(
                'Temps d’utilisation écoulé',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vous avez atteint la limite d’1 heure.\nVeuillez revenir après la période de 24h.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (ctrl.retryAt != null) ...[
                const Text('Prochaine tentative dans :'),
                const SizedBox(height: 6),
                Text(
                  _format(_remaining),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
              ],
              ElevatedButton(
                onPressed: canRetry
                    ? () async {
                  await context.read<JobOfferController>().tryAgainAfterCooldown();
                  if (!mounted) return;
                  if (!context.read<JobOfferController>().cooldownActive) {
                    Navigator.pop(context); // back to app
                  }
                }
                    : null,
                child: const Text('Réessayer maintenant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
