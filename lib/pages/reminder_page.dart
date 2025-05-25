import 'package:flutter/material.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final _controller = TextEditingController();
  final List<String> _reminders = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addReminder() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _reminders.add(text);
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengingat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Tambah catatan pengingat',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addReminder,
              child: const Text('Tambah'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _reminders.isEmpty
                  ? const Center(child: Text('Belum ada pengingat'))
                  : ListView.builder(
                      itemCount: _reminders.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.notifications),
                          title: Text(_reminders[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
