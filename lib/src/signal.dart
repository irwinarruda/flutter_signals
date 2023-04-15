import 'package:flutter/material.dart';

typedef SignalSubscriber = void Function();

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

class ComputedBuilder<T> {
  ComputedBuilder(this.callback);
  T Function() callback;

  T call() {
    return this.callback();
  }
}

SignalBuilder<T> signal<T>(T initialValue) {
  return SignalBuilder(initialValue);
}

ComputedBuilder<T> computed<T>(T Function() cb) {
  return ComputedBuilder(cb);
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

  void startReaction() {
    SignalEffect.createEffect(() {
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
      startReaction();
    }
    return built!;
  }
}
