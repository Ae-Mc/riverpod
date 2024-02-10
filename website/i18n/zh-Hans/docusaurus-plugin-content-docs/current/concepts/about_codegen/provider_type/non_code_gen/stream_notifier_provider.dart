import 'package:flutter_riverpod/flutter_riverpod.dart';

/* SNIPPET START */
final exampleProvider =
    StreamNotifierProvider.autoDispose<ExampleNotifier, String>(() {
  return ExampleNotifier();
});

class ExampleNotifier extends StreamNotifier<String> {
  @override
  Stream<String> build() async* {
    yield 'foo';
  }

  // 添加改变状态的方法
}
