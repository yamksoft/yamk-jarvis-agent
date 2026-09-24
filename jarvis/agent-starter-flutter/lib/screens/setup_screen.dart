import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_ctrl.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _urlCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load existing preferences if any
    final appCtrl = context.read<AppCtrl>();
    _urlCtrl.text = appCtrl.livekitUrl ?? 'ws://localhost:7880';
    _keyCtrl.text = appCtrl.apiKey ?? 'devkey';
    _secretCtrl.text = appCtrl.apiSecret ?? 'secret';
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _keyCtrl.dispose();
    _secretCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAndApply() async {
    if (!_formKey.currentState!.validate()) return;
    
    final appCtrl = context.read<AppCtrl>();
    await appCtrl.saveSettings(
      url: _urlCtrl.text.trim(),
      key: _keyCtrl.text.trim(),
      secret: _secretCtrl.text.trim(),
    );
    
    appCtrl.appScreenState = AppScreenState.welcome;
    appCtrl.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '⚙️ Configuration',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your LiveKit credentials to connect.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _urlCtrl,
                        decoration: const InputDecoration(
                          labelText: 'LiveKit URL',
                          hintText: 'ws://localhost:7880',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'URL is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _keyCtrl,
                        decoration: const InputDecoration(
                          labelText: 'API Key',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'API Key is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _secretCtrl,
                        decoration: const InputDecoration(
                          labelText: 'API Secret',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (v) => v!.isEmpty ? 'API Secret is required' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveAndApply,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Save & Apply', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
