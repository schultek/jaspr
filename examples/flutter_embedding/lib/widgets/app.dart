import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state_provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// Here the widget state does not know or care about interoperability,
/// since this is handled by the riverpod provider.
///
/// Therefore this implementation is a standard riverpod app without
/// any special bits. For those, check out the [AppStateNotifier] and [InteropNotifier].
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Element embedding',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: Consumer(
        builder: (context, ref, _) {
          var screen = ref.watch(appStateProvider).currentScreen;
          return demoScreenRouter(screen);
        },
      ),
    );
  }

  Widget demoScreenRouter(DemoScreen which) {
    switch (which) {
      case DemoScreen.counter:
        return CounterDemo(title: 'Counter');
      case DemoScreen.textField:
        return const TextFieldDemo(title: 'Note to Self');
      case DemoScreen.custom:
        return const CustomDemo(title: 'Character Counter');
    }
  }
}

class CounterDemo extends ConsumerStatefulWidget {
  final String title;

  const CounterDemo({super.key, required this.title});

  @override
  ConsumerState<CounterDemo> createState() => _CounterDemoState();
}

class _CounterDemoState extends ConsumerState<CounterDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('${ref.watch(appStateProvider).count}', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(appStateProvider.notifier).increment();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TextFieldDemo extends StatelessWidget {
  const TextFieldDemo({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(14.0),
          child: TextField(
            maxLines: null,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              // hintText: 'Text goes here!',
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDemo extends StatefulWidget {
  final String title;

  const CustomDemo({super.key, required this.title});

  @override
  State<CustomDemo> createState() => _CustomDemoState();
}

class _CustomDemoState extends State<CustomDemo> {
  final double textFieldHeight = 80;
  final Color colorPrimary = const Color(0xff027dfd);
  // const Color(0xffd43324);
  // const Color(0xff6200ee);
  // const Color.fromARGB(255, 255, 82, 44);
  final TextEditingController _textController = TextEditingController();
  late FocusNode textFocusNode;

  int totalCharCount = 0;

  @override
  void initState() {
    super.initState();
    textFocusNode = FocusNode();
    textFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height - textFieldHeight,
        flexibleSpace: Container(
          color: colorPrimary,
          height: MediaQuery.of(context).size.height - textFieldHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('COUNT WITH DASH!', style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 26),
              Container(
                width: 98,
                height: 98,
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/dash.png'), fit: BoxFit.cover),
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(totalCharCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 52)),
              // const Text(
              //   'characters typed',
              //   style: TextStyle(color: Colors.white, fontSize: 14),
              // ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: textFieldHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: textFocusNode,
                        onSubmitted: (value) {
                          textFocusNode.requestFocus();
                        },
                        onChanged: (value) {
                          handleChange();
                        },
                        maxLines: 1,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Center(
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(color: colorPrimary, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.refresh),
                          color: Colors.white,
                          onPressed: () {
                            handleClear();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void handleChange() {
    setState(() {
      totalCharCount = _textController.value.text.toString().length;
    });
  }

  void handleClear() {
    setState(() {
      _textController.clear();
      totalCharCount = 0;
    });
    textFocusNode.requestFocus();
  }
}
