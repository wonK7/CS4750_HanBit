import 'package:flutter/material.dart';

class RecoPage extends StatelessWidget {
  const RecoPage({super.key});

  static const routeName = '/recommendations';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      appBar: AppBar(
        title: const Text('Recommendations'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildRecoItem(
            Icons.restaurant,
            'K-Food',
            'Warm Citron Tea (Yuja-cha) to balance your energy.',
          ),
          _buildRecoItem(
            Icons.self_improvement,
            'K-Spirit',
            "10 minutes of 'Seon' meditation for a clear mind.",
          ),
          _buildRecoItem(
            Icons.spa,
            'K-Beauty',
            'Ginseng-based essence for skin vitality.',
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              debugPrint('Data saved to Firestore (Simulated)');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your wellness log has been recorded!'),
                ),
              );
            },
            child: const Text('Record My Today\'s Log'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoItem(IconData icon, String title, String desc) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF789288)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(desc),
      ),
    );
  }
}
