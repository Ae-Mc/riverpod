part of '../async_notifier.dart';

/// {@macro riverpod.async_notifier}
///
/// {@macro riverpod.async_notifier_provider_modifier}
abstract class FamilyAsyncNotifier<State, Arg> extends $AsyncNotifier<State> {
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
  FutureOr<State> build(Arg arg);

  @internal
  @override
  FutureOr<State> runBuild() => build(arg);
}

/// The [Family] of [AsyncNotifierProvider].
class AsyncNotifierProviderFamily< //
        NotifierT extends FamilyAsyncNotifier<StateT, ArgT>,
        StateT,
        ArgT> //
    extends ClassFamily< //
        NotifierT,
        AsyncValue<StateT>,
        Ref<AsyncValue<StateT>>,
        ArgT,
        FutureOr<StateT>,
        FamilyAsyncNotifierProvider<NotifierT, StateT, ArgT>> {
  /// The [Family] of [AsyncNotifierProvider].
  @internal
  AsyncNotifierProviderFamily.internal(
    super._createFn, {
    super.name,
    super.dependencies,
    super.isAutoDispose = false,
  }) : super(
          providerFactory: FamilyAsyncNotifierProvider._,
          allTransitiveDependencies:
              computeAllTransitiveDependencies(dependencies),
        );
}

/// The provider returned by [AsyncNotifierProviderFamily].
final class FamilyAsyncNotifierProvider< //
        NotifierT extends FamilyAsyncNotifier<StateT, ArgT>,
        StateT,
        ArgT> //
    extends $AsyncNotifierProvider<NotifierT, StateT>
    with LegacyProviderMixin<AsyncValue<StateT>> {
  /// An implementation detail of Riverpod
  const FamilyAsyncNotifierProvider._(
    this._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.from,
    required super.argument,
    required super.isAutoDispose,
    required super.runNotifierBuildOverride,
  });

  FamilyAsyncNotifierProvider<NotifierT, StateT, ArgT> _copyWith({
    NotifierT Function()? create,
    RunNotifierBuild<NotifierT, FutureOr<StateT>, Ref<AsyncValue<StateT>>>?
        build,
  }) {
    return FamilyAsyncNotifierProvider<NotifierT, StateT, ArgT>._(
      create ?? _createNotifier,
      name: name,
      dependencies: dependencies,
      allTransitiveDependencies: allTransitiveDependencies,
      from: from,
      argument: argument,
      isAutoDispose: isAutoDispose,
      runNotifierBuildOverride: build ?? runNotifierBuildOverride,
    );
  }

  final NotifierT Function() _createNotifier;

  @override
  NotifierT create() => _createNotifier();

  @internal
  @override
  $AsyncNotifierProviderElement<NotifierT, StateT> createElement(
    ProviderContainer container,
  ) {
    return $AsyncNotifierProviderElement(this, container);
  }

  @mustBeOverridden
  @visibleForOverriding
  @override
  FamilyAsyncNotifierProvider<NotifierT, StateT, ArgT> $copyWithBuild(
    RunNotifierBuild<NotifierT, FutureOr<StateT>, Ref<AsyncValue<StateT>>>?
        build,
  ) {
    return _copyWith(build: build);
  }

  @mustBeOverridden
  @visibleForOverriding
  @override
  FamilyAsyncNotifierProvider<NotifierT, StateT, ArgT> $copyWithCreate(
    NotifierT Function() create,
  ) {
    return _copyWith(create: create);
  }
}
