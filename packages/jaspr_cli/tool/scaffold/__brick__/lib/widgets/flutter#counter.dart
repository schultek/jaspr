import 'package:flutter/material.dart';

class CounterWidget extends StatelessWidget {
  const CounterWidget({this.count = 0, required this.onChange, super.key});

  final int count;
  final void Function(int) onChange;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF01589B)),
          borderRadius: .circular(10),
        ),
        child: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                onChange(count - 1);
              },
            ),
            const SizedBox(width: 5),
            Column(
              mainAxisAlignment: .center,
              children: [
                const Text('Flutter Counter'),
                Text('$count', style: TextStyle(fontWeight: .bold)),
              ],
            ),
            const SizedBox(width: 5),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                onChange(count + 1);
              },
            ),
          ],
        ),
      ),
    );
  }
}
