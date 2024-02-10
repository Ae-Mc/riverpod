// ignore_for_file: unused_local_variable

import 'package:riverpod/riverpod.dart';

final otherProvider = Provider<int>((ref) => 0);

/* SNIPPET START */
final notifierProvider = NotifierProvider<MyNotifier, int>(MyNotifier.new);

class MyNotifier extends Notifier<int> {
  @override
  int build() {
    // Bad! Do not use "read" here as it is not reactive
    ref.read(otherProvider);

    return 0;
  }

  void increment() {
    ref.read(otherProvider); // Using "read" here is fine
  }
}
