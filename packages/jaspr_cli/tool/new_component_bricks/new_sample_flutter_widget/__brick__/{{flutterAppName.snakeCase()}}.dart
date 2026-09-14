import 'package:flutter/material.dart';

class {{flutterAppName.pascalCase()}} extends StatefulWidget {
  const {{flutterAppName.pascalCase()}}({super.key});

  @override
  State<{{flutterAppName.pascalCase()}}> createState() => _{{flutterAppName.pascalCase()}}State();
}

class _{{flutterAppName.pascalCase()}}State extends State<{{flutterAppName.pascalCase()}}> {
  int count = 0;

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
                setState(() {
                  count -= 1;
                });
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
                setState(() {
                  count += 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
