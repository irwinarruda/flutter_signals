# Flutter Signals

For now, this project is a proof of concept to test if [Solid's Signals](https://www.solidjs.com/docs/latest/api#createsignal) implementation works on flutter. Here is an example of how it would be used:

```dart
class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  late var count = signal<int>(0);
  late var doubleCount = computed<int>(() => count() * 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test App 1'),
      ),
      body: Center(
        child: Observer(
          builder: (cx) => Text(
            'Count: ${count()} | Double ${doubleCount()}',
            style: Theme.of(cx).textTheme.headlineMedium,
          ),
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
```

For now, the main problem with this implementation is that `Hot Reloading` calls the `signal` function again breaking the state.

For more code, go to `/example` folder.
