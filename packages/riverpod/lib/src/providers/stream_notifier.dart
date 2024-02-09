import 'dart:async';

import 'package:meta/meta.dart';

import '../builder.dart';
import '../core/async_value.dart';
import '../framework.dart';
import 'future_provider.dart' show FutureProvider;

part 'stream_notifier/family.dart';
part 'stream_notifier/orphan.dart';

/// Implementation detail of `riverpod_generator`.
/// Do not use.
abstract class $StreamNotifier<StateT> extends $ClassBase< //
        AsyncValue<StateT>,
        Stream<StateT>> //
    with
        $AsyncClassModifier<StateT, Stream<StateT>> {}

/// Implementation detail of `riverpod_generator`.
/// Do not use.
abstract base class $StreamNotifierProvider<
        NotifierT extends $StreamNotifier<StateT>, //
        StateT> //
    extends $ClassProvider< //
        NotifierT,
        AsyncValue<StateT>,
        Stream<StateT>,
        Ref<AsyncValue<StateT>>> //
    with
        $FutureModifier<StateT> {
  const $StreamNotifierProvider({
    required super.name,
    required super.from,
    required super.argument,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.isAutoDispose,
    required super.runNotifierBuildOverride,
  });
}

/// Implementation detail of `riverpod_generator`.
/// Do not use.
class $StreamNotifierProviderElement< //
        NotifierT extends $StreamNotifier<StateT>,
        StateT> //
    extends ClassProviderElement< //
        NotifierT,
        AsyncValue<StateT>,
        Stream<StateT>> //
    with
        FutureModifierElement<StateT> {
  $StreamNotifierProviderElement(this.provider, super.container);

  @override
  final $StreamNotifierProvider<NotifierT, StateT> provider;

  @override
  void handleError(
    Object error,
    StackTrace stackTrace, {
    required bool didChangeDependency,
  }) {
    onError(AsyncError(error, stackTrace), seamless: !didChangeDependency);
  }

  @override
  void handleValue(
    Stream<StateT> created, {
    required bool didChangeDependency,
  }) {
    handleStream(
      () => created,
      didChangeDependency: didChangeDependency,
    );
  }
}
