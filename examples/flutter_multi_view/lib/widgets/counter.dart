import 'package:flutter/material.dart';
import '../constants/theme.dart';

class CounterWidget extends StatelessWidget {
  const CounterWidget({this.count = 0, required this.onChange, super.key});

  final int count;
  final Function(int) onChange;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Card(
        margin: EdgeInsets.zero,
        color: Color(0xFF000000 | surfaceColorValue),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF000000 | primaryColorValue)),
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                onChange(count - 1);
              },
            ),
            const SizedBox(width: 5),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Flutter Counter'),
                Text('$count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
