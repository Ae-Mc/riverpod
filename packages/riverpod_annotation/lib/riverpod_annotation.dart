// Annotations used by code-generators
import 'package:meta/meta.dart' as meta;

export 'dart:async' show FutureOr;

// ignore: invalid_export_of_internal_element
export 'package:riverpod/src/internals.dart'
    show
        // General stuff
        // TODO changelog changed exports,
        ProviderContainer,
        Family,
        ProviderOrFamily,
        Override,
        $FamilyOverride,
        $FunctionalProvider,
        $FutureModifier,
        $ClassBase,
        $AsyncClassModifier,
        $ClassProvider,
        Ref,

        // Provider
        $Provider,
        $ProviderElement,

        // FutureProvider
        $FutureProvider,
        $FutureProviderElement,

        // StreamProvider
        $StreamProvider,
        $StreamProviderElement,

        // AsyncValue
        AsyncValue,
        AsyncLoading,
        AsyncData,
        AsyncError,
        AsyncValueX,

        // AsyncNotifier
        $AsyncNotifierProvider,
        $AsyncNotifier,
        $AsyncNotifierProviderElement,

        // StreamNotifier
        $StreamNotifierProvider,
        $StreamNotifierProviderElement,
        $StreamNotifier,

        // Notifier
        $NotifierProvider,
        $NotifierProviderElement,
        $Notifier;

export 'src/riverpod_annotation.dart';

/// An implementation detail of `riverpod_generator`.
/// Do not use.
const $internal = meta.internal;
