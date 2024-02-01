import 'dart:async';

import 'package:meta/meta.dart';

import '../builder.dart';
import '../core/async_value.dart';
import '../framework.dart';
import 'async_notifier.dart';
import 'provider.dart' show Provider;
import 'stream_provider.dart' show StreamProvider;

/// {@template riverpod.future_provider}
/// A provider that asynchronously creates a value.
///
/// [FutureProvider] can be considered as a combination of [Provider] and
/// `FutureBuilder`.
/// By using [FutureProvider], the UI will be able to read the state of the
/// future synchronously, handle the loading/error states, and rebuild when the
/// future completes.
///
/// A common use-case for [FutureProvider] is to represent an asynchronous operation
/// such as reading a file or making an HTTP request, that is then listened to by the UI.
///
/// It can then be combined with:
/// - [FutureProvider.family], to parameterize the http request based on external
///   parameters, such as fetching a `User` from its id.
/// - [FutureProvider.autoDispose], to cancel the HTTP request if the user
///   leaves the screen before the [Future] completed.
///
/// ## Usage example: reading a configuration file
///
/// [FutureProvider] can be a convenient way to expose a `Configuration` object
/// created by reading a JSON file.
///
/// Creating the configuration would be done with your typical async/await
/// syntax, but inside the provider.
/// Using Flutter's asset system, this would be:
///
/// ```dart
/// final configProvider = FutureProvider<Configuration>((ref) async {
///   final content = json.decode(
///     await rootBundle.loadString('assets/configurations.json'),
///   ) as Map<String, Object?>;
///
///   return Configuration.fromJson(content);
/// });
/// ```
///
/// Then, the UI can listen to configurations like so:
///
/// ```dart
/// Widget build(BuildContext context, WidgetRef ref) {
///   AsyncValue<Configuration> config = ref.watch(configProvider);
///
///   return config.when(
///     loading: () => const CircularProgressIndicator(),
///     error: (err, stack) => Text('Error: $err'),
///     data: (config) {
///       return Text(config.host);
///     },
///   );
/// }
/// ```
///
/// This will automatically rebuild the UI when the [Future] completes.
///
/// As you can see, listening to a [FutureProvider] inside a widget returns
/// an [AsyncValue] – which allows handling the error/loading states.
///
/// See also:
///
/// - [AsyncNotifierProvider], similar to [FutureProvider] but also enables
///   modifying the state from the UI.
/// - [Provider], a provider that synchronously creates a value
/// - [StreamProvider], a provider that asynchronously exposes a value that
///   can change over time.
/// - [FutureProvider.family], to create a [FutureProvider] from external parameters
/// - [FutureProvider.autoDispose], to destroy the state of a [FutureProvider] when no longer needed.
/// {@endtemplate}
final class FutureProvider<StateT> extends FunctionalProvider<
    AsyncValue<StateT>,
    FutureOr<StateT>,
    FutureProviderRef<StateT>> with FutureModifier<StateT> {
  /// {@macro riverpod.future_provider}
  FutureProvider(
    this._create, {
    super.name,
    super.dependencies,
    super.isAutoDispose = false,
  }) : super(
          allTransitiveDependencies:
              computeAllTransitiveDependencies(dependencies),
          from: null,
          argument: null,
          debugGetCreateSourceHash: null,
        );

  FutureProvider._autoDispose(
    this._create, {
    super.name,
    super.dependencies,
  }) : super(
          allTransitiveDependencies:
              computeAllTransitiveDependencies(dependencies),
          isAutoDispose: true,
          from: null,
          argument: null,
          debugGetCreateSourceHash: null,
        );

  /// An implementation detail of Riverpod
  @internal
  FutureProvider.internal(
    this._create, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required super.argument,
    required super.isAutoDispose,
  });

  /// {@macro riverpod.autoDispose}
  static const autoDispose = AutoDisposeFutureProviderBuilder();

  /// {@macro riverpod.family}
  static const family = FutureProviderFamilyBuilder();

  /// TODO make all "create" public, for the sake of dartdocs.
  final Create<FutureOr<StateT>, FutureProviderRef<StateT>> _create;

  @override
  FutureProviderElement<StateT> createElement(ProviderContainer container) {
    return FutureProviderElement(this, container);
  }

  @mustBeOverridden
  @visibleForOverriding
  @override
  FutureProvider<StateT> copyWithCreate(
    Create<FutureOr<StateT>, FutureProviderRef<StateT>> create,
  ) {
    return FutureProvider<StateT>.internal(
      create,
      name: name,
      dependencies: dependencies,
      allTransitiveDependencies: allTransitiveDependencies,
      debugGetCreateSourceHash: debugGetCreateSourceHash,
      from: from,
      argument: argument,
      isAutoDispose: isAutoDispose,
    );
  }
}

/// {@macro riverpod.provider_ref_base}
abstract class FutureProviderRef<StateT> implements Ref<AsyncValue<StateT>> {
  /// Obtains the [Future] associated to this provider.
  ///
  /// This is equivalent to doing `ref.read(myProvider.future)`.
  /// See also [FutureProvider.future].
  // TODO move to Ref
  Future<StateT> get future;
}

/// The element of a [FutureProvider]
class FutureProviderElement<StateT>
    extends ProviderElementBase<AsyncValue<StateT>>
    with FutureModifierElement<StateT>
    implements FutureProviderRef<StateT> {
  /// The element of a [FutureProvider]
  @internal
  FutureProviderElement(this.provider, super.container);

  @override
  final FutureProvider<StateT> provider;

  @override
  Future<StateT> get future {
    flush();
    return futureNotifier.value;
  }

  @override
  void create({required bool didChangeDependency}) {
    handleFuture(
      () => provider._create(this),
      didChangeDependency: didChangeDependency,
    );
  }

  @override
  bool updateShouldNotify(
    AsyncValue<StateT> previous,
    AsyncValue<StateT> next,
  ) {
    return FutureModifierElement.handleUpdateShouldNotify(
      previous,
      next,
    );
  }
}

/// The [Family] of a [FutureProvider]
class FutureProviderFamily<StateT, ArgT> extends FunctionalFamily<
    FutureProviderRef<StateT>,
    AsyncValue<StateT>,
    ArgT,
    FutureOr<StateT>,
    FutureProvider<StateT>> {
  FutureProviderFamily(
    super._createFn, {
    super.name,
    super.dependencies,
    super.isAutoDispose = false,
  }) : super(
          providerFactory: FutureProvider<StateT>.internal,
          allTransitiveDependencies:
              computeAllTransitiveDependencies(dependencies),
          debugGetCreateSourceHash: null,
        );

  FutureProviderFamily._autoDispose(
    super._createFn, {
    super.name,
    super.dependencies,
  }) : super(
          providerFactory: FutureProvider<StateT>.internal,
          isAutoDispose: true,
          allTransitiveDependencies:
              computeAllTransitiveDependencies(dependencies),
          debugGetCreateSourceHash: null,
        );

  /// Implementation detail of the code-generator.
  @internal
  FutureProviderFamily.internal(
    super._createFn, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.isAutoDispose,
  }) : super(providerFactory: FutureProvider<StateT>.internal);
}
