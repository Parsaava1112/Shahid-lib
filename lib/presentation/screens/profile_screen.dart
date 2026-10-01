// lib/presentation/screens/profile_screen.dart (بخش نشان‌ها)
Widget _buildBadgesSection(List<dynamic> badges) {
  return Card(
    margin: const EdgeInsets.all(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نشان‌های شما',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          badges.isEmpty
              ? const Text('هنوز نشانی کسب نکرده‌اید. شروع کنید!')
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: badges.map<Widget>((badge) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            badge['icon'],
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            badge['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(delay: 200.ms).fadeIn();
                  }).toList(),
                ),
        ],
      ),
    ),
  );
}