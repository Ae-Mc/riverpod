part of '../stream_notifier.dart';

/// {@macro riverpod.async_notifier}
///
/// {@macro riverpod.async_notifier_provider_modifier}
abstract class FamilyStreamNotifier<State, Arg> extends $StreamNotifier<State> {
  /// {@template riverpod.notifier.family_arg}
  /// The argument that was passed to this family.
  ///
  /// For example, when doing:
  ///
  /// ```dart
  /// ref.watch(provider(0));
  /// ```
  ///
  /// then [arg] will be `0`.
  /// {@endtemplate}
  late final Arg arg = (ref as ProviderElementBase).origin.argument as Arg;

  /// {@macro riverpod.async_notifier.build}
  @visibleForOverriding
  Stream<State> build(Arg arg);

  @internal
  @override
  Stream<State> runBuild() => build(arg);
}

final class FamilyStreamNotifierProvider< //
        NotifierT extends FamilyStreamNotifier<StateT, ArgT>,
        StateT,
        ArgT> //
    extends $StreamNotifierProvider<NotifierT, StateT>
    with LegacyProviderEqualMixin<AsyncValue<StateT>> {
  /// An implementation detail of Riverpod
  const FamilyStreamNotifierProvider._(
    this._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required super.argument,
    required super.isAutoDispose,
    required super.runNotifierBuildOverride,
  });

  final NotifierT Function() _createNotifier;

  @override
  NotifierT create() => _createNotifier();

  @override
  $StreamNotifierProviderElement<NotifierT, StateT> createElement(
    ProviderContainer container,
  ) {
    return $StreamNotifierProviderElement(this, container);
  }

  FamilyStreamNotifierProvider<NotifierT, StateT, ArgT> _copyWith({
    NotifierT Function()? create,
    RunNotifierBuild< //
            NotifierT,
            Stream<StateT>,
            Ref<AsyncValue<StateT>>>?
        build,
  }) {
    return FamilyStreamNotifierProvider._(
      create ?? _createNotifier,
      name: name,
      dependencies: dependencies,
      allTransitiveDependencies: allTransitiveDependencies,
      debugGetCreateSourceHash: debugGetCreateSourceHash,
      isAutoDispose: isAutoDispose,
      runNotifierBuildOverride: build ?? runNotifierBuildOverride,
      from: from,
      argument: argument,
    );
  }

  @override
  @mustBeOverridden
  @visibleForOverriding
  FamilyStreamNotifierProvider<NotifierT, StateT, ArgT> copyWithBuild(
    RunNotifierBuild<NotifierT, Stream<StateT>, Ref<AsyncValue<StateT>>> build,
  ) {
    return _copyWith(build: build);
  }

  @override
  @mustBeOverridden
  @visibleForOverriding
  FamilyStreamNotifierProvider<NotifierT, StateT, ArgT> copyWithCreate(
    NotifierT Function() create,
  ) {
    return _copyWith(create: create);
  }
}

/// The [Family] of [StreamNotifierProvider].
class StreamNotifierProviderFamily< //
        NotifierT extends FamilyStreamNotifier<StateT, ArgT>,
        StateT,
        ArgT> //
    extends ClassFamily< //
        NotifierT,
        AsyncValue<StateT>,
        Ref<AsyncValue<StateT>>,
        ArgT,
        Stream<StateT>,
        FamilyStreamNotifierProvider<NotifierT, StateT, ArgT>> {
  /// The [Family] of [StreamNotifierProvider].
  @internal
  StreamNotifierProviderFamily.internal(
    super._createFn, {
    super.name,
    super.dependencies,
    super.isAutoDispose = false,
  }) : super(
          providerFactory: FamilyStreamNotifierProvider._,
          allTransitiveDependencies:
              computeAllTransitiveDependencies(dependencies),
          debugGetCreateSourceHash: null,
        );
}
