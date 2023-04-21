import 'package:flutter/material.dart';
import 'package:flutter_signals/flutter_signals.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  static var count = signal<int>(0);
  static var doubleCount = computed<int>(() => count() * 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test App 1'),
      ),
      body: Center(
        child: Column(
          children: [
            Observer(
              builder: (cx) => Text(
                'Count: ${count()} | Double ${doubleCount()}',
                style: Theme.of(cx).textTheme.headlineMedium,
              ),
            ),
            const MyButton(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => count.update((prev) => prev + 1),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MyButton extends ObserverWidget {
  const MyButton({super.key});

  static var count = signal<int>(0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: ${count()}'),
        FilledButton(
          child: const Text('Increment'),
          onPressed: () => count.set(count() + 1),
        ),
        const MyInput(),
      ],
    );
  }
}

class MyInput extends ObserverWidget {
  const MyInput({super.key});

  static var text = signal<String>('');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(onChanged: (v) => text.set(v)),
        Text(text()),
      ],
    );
  }
}
