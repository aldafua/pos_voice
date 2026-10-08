import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import '../../services/voice_action_planner.dart';
import '../../services/voice_service.dart';

Future<void> showVoiceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const VoiceSheet(),
  );
}

enum _VState { idle, listening, confirm, running, done, unavailable }

class VoiceSheet extends StatefulWidget {
  const VoiceSheet({super.key});

  @override
  State<VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends State<VoiceSheet> {
  late final VoiceService _voice;
  final TextEditingController _textCtrl = TextEditingController();

  _VState _state = _VState.idle;
  String _heard = '';
  String? _message;
  VoicePlan? _plan;
  VoiceResult? _result;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _voice = context.read<VoiceService>();
    _voice.statusListener = _onStatus;
    _voice.errorListener = _onError;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
  }

  @override
  void dispose() {
    _voice.statusListener = null;
    _voice.errorListener = null;
    _voice.cancel();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (!mounted) return;
    setState(() {
      _state = _VState.listening;
      _heard = '';
      _plan = null;
      _result = null;
      _message = null;
      _handled = false;
    });
    var ok = false;
    try {
      ok = await _voice.ensureInitialized();
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _state = _VState.unavailable;
        _message = 'Pengenalan suara tidak tersedia. Periksa izin mikrofon atau ketik perintah di bawah.';
      });
      return;
    }
    await _voice.startListening((words, isFinal) {
      if (!mounted) return;
      setState(() => _heard = words);
      if (isFinal) _process(words);
    });
  }

  void _onStatus(String status) {
    if (!mounted || _state != _VState.listening) return;
    if (status == 'done' || status == 'notListening') {
      if (_heard.trim().isNotEmpty) {
        _process(_heard);
      } else {
        setState(() {
          _state = _VState.idle;
          _message = 'Suara tidak terdeteksi. Tekan mikrofon untuk mencoba lagi.';
        });
      }
    }
  }

  void _onError(String msg) {
    if (!mounted || _state != _VState.listening) return;
    setState(() {
      _state = _VState.idle;
      _message = (msg == 'error_no_match' || msg == 'error_speech_timeout')
          ? 'Suara kurang jelas. Coba lagi atau ketik perintah.'
          : 'Pengenalan suara gagal ($msg). Coba lagi atau ketik perintah.';
    });
  }

  void _process(String text) {
    if (_handled) return;
    _handled = true;
    final planner = VoiceActionPlanner(
      products: context.read<ProductProvider>().all,
      cart: context.read<CartProvider>(),
      sales: context.read<SaleProvider>(),
    );
    final plan = planner.plan(text);
    setState(() {
      _heard = text;
      _plan = plan;
      _message = null;
      _state = plan.error != null
          ? _VState.idle
          : (plan.needsConfirm ? _VState.confirm : _VState.running);
    });
    if (plan.error == null && !plan.needsConfirm) _execute();
  }

  Future<void> _execute() async {
    final plan = _plan;
    if (plan == null || plan.run == null) return;
    setState(() => _state = _VState.running);
    final res = await plan.run!();
    if (!mounted) return;
    if (plan.opensPayment && res.ok) {
      final nav = Navigator.of(context);
      nav.pop();
      nav.pushNamed(Routes.payment);
      return;
    }
    setState(() {
      _result = res;
      _state = _VState.done;
    });
  }

  void _cancelPlan() {
    setState(() {
      _plan = null;
      _state = _VState.idle;
      _message = 'Dibatalkan. Tidak ada perubahan pada keranjang.';
    });
  }

  Future<void> _toggleMic() async {
    if (_state == _VState.listening) {
      await _voice.stop();
    } else {
      await _voice.cancel();
      await _startListening();
    }
  }

  Future<void> _submitText() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    await _voice.cancel();
    if (!mounted) return;
    _handled = false;
    _textCtrl.clear();
    _process(text);
  }

  String get _statusText {
    switch (_state) {
      case _VState.listening:
        return 'Mendengarkan… ucapkan perintah';
      case _VState.confirm:
        return 'Periksa perintah, lalu tekan Jalankan';
      case _VState.running:
        return 'Memproses…';
      case _VState.done:
        return 'Selesai. Ucapkan perintah lain bila perlu.';
      case _VState.unavailable:
        return 'Mode ketik';
      case _VState.idle:
        return 'Tekan mikrofon untuk mulai';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Voice Assistant',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(_statusText, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 14),
            Center(
              child: GestureDetector(
                onTap: _toggleMic,
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.accent,
                  child: Icon(_state == _VState.listening ? Icons.stop : Icons.mic,
                      size: 34, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (_heard.isNotEmpty) _InfoCard(color: Colors.white, label: 'Terdengar', text: '“$_heard”', border: true),
            if (_plan?.error != null) _InfoCard(color: AppTheme.dangerSoft, text: _plan!.error!),
            if (_state == _VState.confirm && _plan != null) ...[
              _InfoCard(color: AppTheme.primarySoft, text: 'Aksi: ${_plan!.description}', bold: true),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      onPressed: _cancelPlan,
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: _execute, child: const Text('Jalankan'))),
                ],
              ),
            ],
            if (_state == _VState.done && _result != null)
              _InfoCard(color: _result!.ok ? AppTheme.successSoft : AppTheme.dangerSoft, text: _result!.message),
            if (_message != null) _InfoCard(color: Colors.white, text: _message!, border: true),
            const SizedBox(height: 10),
            TextField(
              controller: _textCtrl,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitText(),
              decoration: AppTheme.input(
                'Atau ketik perintah',
                suffix: IconButton(icon: const Icon(Icons.send), onPressed: _submitText),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Contoh: "tambah dua mie goreng", "cek stok gula", "harga teh celup", "total penjualan hari ini", "bayar"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.color, required this.text, this.label, this.bold = false, this.border = false});

  final Color color;
  final String text;
  final String? label;
  final bool bold;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: border ? Border.all(color: const Color(0xFFD5DFDC)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(label!, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          Text(text, style: TextStyle(fontSize: 15, fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}
