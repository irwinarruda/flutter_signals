import 'package:flutter/material.dart';

typedef SignalSubscriber = void Function();

class ContextType {
  ContextType();
  void Function()? execute;
  void Function()? dispose;
  call() {
    if (execute == null) return;
    return execute!();
  }

  setDispose(void Function()? dispose) {
    this.dispose = dispose;
  }

  setExecute(void Function() execute) {
    this.execute = execute;
  }
}

class SignalContext {
  static List<ContextType> context = [];
  static int get count => context.length;
  static int push(ContextType item) {
    SignalContext.context.add(item);
    return SignalContext.count;
  }

  static ContextType pop() {
    return SignalContext.context.removeLast();
  }

  static ContextType peek() {
    return SignalContext.context.last;
  }
}

class SignalEffect {
  static void Function() createEffect(SignalSubscriber callback) {
    final context = ContextType();
    void execute() {
      context.setExecute(execute);
      SignalContext.push(context);
      callback();
      SignalContext.pop();
    }

    execute();
    return () {
      if (context.dispose != null) {
        context.dispose!();
      }
    };
  }
}

class SignalBuilder<T> {
  SignalBuilder(T initialValue) {
    this.value = initialValue;
  }
  late Set<ContextType> subscribers = {};
  late T value;

  T call() {
    if (SignalContext.count > 0) {
      final lastCtx = SignalContext.peek();
      lastCtx.setDispose(() {
        subscribers.remove(lastCtx);
      });
      subscribers.add(lastCtx);
    }
    return value;
  }

  bool set(T newValue) {
    this.value = newValue;
    for (var subscriber in subscribers) {
      subscriber();
    }
    return true;
  }

  bool update(T Function(T) cb) {
    return set(cb(value));
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

abstract class ObserverWidget extends StatelessWidget {
  const ObserverWidget({super.key});
  @override
  ObserverElement createElement() => ObserverElement(this);
}

class ObserverElement extends StatelessElement {
  ObserverElement(super.widget);

  void Function()? dispose;
  Widget? element;

  @override
  void unmount() {
    if (dispose != null) {
      dispose!();
      dispose = null;
    }
    super.unmount();
  }

  @override
  Widget build() {
    if (dispose == null) {
      dispose = SignalEffect.createEffect(() {
        if (dispose != null) {
          markNeedsBuild();
          return;
        }
        element = super.build();
      });
    } else {
      element = super.build();
    }
    return element!;
  }
}
