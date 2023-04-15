import 'package:flutter/material.dart';

typedef SignalSubscriber = void Function();

typedef ComputedSubscriber<T> = T Function();

class SignalContext {
  static List<SignalSubscriber> context = [];
}

class SignalEffect {
  static void createEffect(SignalSubscriber callback) {
    void execute() {
      SignalContext.context.add(execute);
      callback();
      SignalContext.context.removeLast();
    }

    execute();
  }
}

class SignalBuilder<T> {
  SignalBuilder(T initialValue) {
    print('called signal');
    this.value = initialValue;
  }
  late Set<SignalSubscriber> subscribers = {};
  late T value;

  T call() {
    if (SignalContext.context.isNotEmpty) {
      this.subscribers.add(SignalContext.context.last);
    }
    return value;
  }

  bool set(T newValue) {
    this.value = newValue;
    for (var subscriber in this.subscribers) {
      subscriber();
    }
    return true;
  }

  bool update(T Function(T) cb) {
    return set(cb(this.value));
  }
}

SignalBuilder<T> signal<T>(T initialValue) {
  return SignalBuilder(initialValue);
}

ComputedSubscriber<T> computed<T>(ComputedSubscriber<T> cb) {
  return cb;
}

void createEffect(void Function() cb) {
  SignalEffect.createEffect(cb);
}

class Observer extends StatelessWidget {
  const Observer({super.key, required this.builder});
  final Widget Function(BuildContext) builder;

  @override
  Widget build(BuildContext context) => builder(context);

  @override
  StatelessElement createElement() => ObserverElement(this);
}

class ObserverElement extends StatelessElement {
  ObserverElement(super.widget);

  Widget? built;

  void startEffect() {
    createEffect(() {
      built = super.build();
      invalidate();
    });
  }

  void invalidate() {
    markNeedsBuild();
  }

  @override
  Widget build() {
    if (built == null) {
      startEffect();
    }
    return built!;
  }
}
