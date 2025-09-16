// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currencyServiceHash() => r'a8c3f4511e4cd253763ca5001ef1a962b5909276';

/// Provider for the currency service
///
/// Provides access to the singleton instance of CurrencyService for
/// converting currencies and fetching exchange rates.
///
/// Copied from [currencyService].
@ProviderFor(currencyService)
final currencyServiceProvider = AutoDisposeProvider<CurrencyService>.internal(
  currencyService,
  name: r'currencyServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currencyServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrencyServiceRef = AutoDisposeProviderRef<CurrencyService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
