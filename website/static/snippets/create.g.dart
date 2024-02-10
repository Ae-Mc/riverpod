// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names

part of 'create.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

typedef BoredSuggestionRef = Ref<AsyncValue<String>>;

@ProviderFor(boredSuggestion)
const boredSuggestionProvider = BoredSuggestionProvider._();

final class BoredSuggestionProvider extends $FunctionalProvider<
        AsyncValue<String>, FutureOr<String>, BoredSuggestionRef>
    with $FutureModifier<String>, $FutureProvider<String, BoredSuggestionRef> {
  const BoredSuggestionProvider._(
      {FutureOr<String> Function(
        BoredSuggestionRef ref,
      )? create})
      : _createCb = create,
        super(
          from: null,
          argument: null,
          name: r'boredSuggestionProvider',
          isAutoDispose: true,
          dependencies: null,
          allTransitiveDependencies: null,
        );

  final FutureOr<String> Function(
    BoredSuggestionRef ref,
  )? _createCb;

  @override
  String debugGetCreateSourceHash() => _$boredSuggestionHash();

  @override
  $FutureProviderElement<String> createElement(ProviderContainer container) =>
      $FutureProviderElement(this, container);

  @override
  BoredSuggestionProvider $copyWithCreate(
    FutureOr<String> Function(
      BoredSuggestionRef ref,
    ) create,
  ) {
    return BoredSuggestionProvider._(create: create);
  }

  @override
  FutureOr<String> create(BoredSuggestionRef ref) {
    final fn = _createCb ?? boredSuggestion;
    return fn(ref);
  }
}

String _$boredSuggestionHash() => r'5975efd623c41e5bc92ecd326209e6124cb1736d';

const $kDebugMode = bool.fromEnvironment('dart.vm.product');
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use_from_same_package
