# Flutter Signals

For now, this project is a proof of concept to test if [Solid's Signals](https://www.solidjs.com/docs/latest/api#createsignal) implementation works on flutter. It can be used in two ways:

## Observer Builder

The `Observer Builder` will track any signals inside it. When they change, only the ObserverWidget will rerender. Use this if you need fine-grained reactivity in a `Widget`.

```dart
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
```

## ObserverWidget

The `ObserverWidget` extends `StatelessWidget` and can be used like it. The difference between both is that ObserverWidget rerenders if a signal changes.

```dart
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
```

For now, the main problem with this implementation is that `Hot Reloading` calls the `signal` function again breaking the state if we don't use static variables.

For more code, go to `/example` folder.
