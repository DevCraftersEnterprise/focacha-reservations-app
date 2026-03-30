// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reservationsServiceHash() =>
    r'5db607f168d69bc670335919322388ed533efce0';

/// See also [reservationsService].
@ProviderFor(reservationsService)
final reservationsServiceProvider =
    AutoDisposeProvider<ReservationsService>.internal(
      reservationsService,
      name: r'reservationsServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reservationsServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReservationsServiceRef = AutoDisposeProviderRef<ReservationsService>;
String _$branchesServiceHash() => r'851cbe8f620efe24c2f8d88d499cb85fc75992ca';

/// See also [branchesService].
@ProviderFor(branchesService)
final branchesServiceProvider = AutoDisposeProvider<BranchesService>.internal(
  branchesService,
  name: r'branchesServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$branchesServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BranchesServiceRef = AutoDisposeProviderRef<BranchesService>;
String _$branchesHash() => r'82f65031eb4a9041031315b7d30ab7a3f6362335';

/// See also [branches].
@ProviderFor(branches)
final branchesProvider = AutoDisposeFutureProvider<List<BranchModel>>.internal(
  branches,
  name: r'branchesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$branchesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BranchesRef = AutoDisposeFutureProviderRef<List<BranchModel>>;
String _$branchZonesHash() => r'9efe285b8fad7a7b092991e32e914cc9862ab9ca';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [branchZones].
@ProviderFor(branchZones)
const branchZonesProvider = BranchZonesFamily();

/// See also [branchZones].
class BranchZonesFamily extends Family<AsyncValue<List<ZoneModel>>> {
  /// See also [branchZones].
  const BranchZonesFamily();

  /// See also [branchZones].
  BranchZonesProvider call(String branchId) {
    return BranchZonesProvider(branchId);
  }

  @override
  BranchZonesProvider getProviderOverride(
    covariant BranchZonesProvider provider,
  ) {
    return call(provider.branchId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'branchZonesProvider';
}

/// See also [branchZones].
class BranchZonesProvider extends AutoDisposeFutureProvider<List<ZoneModel>> {
  /// See also [branchZones].
  BranchZonesProvider(String branchId)
    : this._internal(
        (ref) => branchZones(ref as BranchZonesRef, branchId),
        from: branchZonesProvider,
        name: r'branchZonesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$branchZonesHash,
        dependencies: BranchZonesFamily._dependencies,
        allTransitiveDependencies: BranchZonesFamily._allTransitiveDependencies,
        branchId: branchId,
      );

  BranchZonesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.branchId,
  }) : super.internal();

  final String branchId;

  @override
  Override overrideWith(
    FutureOr<List<ZoneModel>> Function(BranchZonesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BranchZonesProvider._internal(
        (ref) => create(ref as BranchZonesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        branchId: branchId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ZoneModel>> createElement() {
    return _BranchZonesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BranchZonesProvider && other.branchId == branchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, branchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BranchZonesRef on AutoDisposeFutureProviderRef<List<ZoneModel>> {
  /// The parameter `branchId` of this provider.
  String get branchId;
}

class _BranchZonesProviderElement
    extends AutoDisposeFutureProviderElement<List<ZoneModel>>
    with BranchZonesRef {
  _BranchZonesProviderElement(super.provider);

  @override
  String get branchId => (origin as BranchZonesProvider).branchId;
}

String _$reservationFiltersNotifierHash() =>
    r'46533f19d5b99485de141ef92376bc996ad0edc2';

/// See also [ReservationFiltersNotifier].
@ProviderFor(ReservationFiltersNotifier)
final reservationFiltersNotifierProvider =
    AutoDisposeNotifierProvider<
      ReservationFiltersNotifier,
      ReservationFilters
    >.internal(
      ReservationFiltersNotifier.new,
      name: r'reservationFiltersNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reservationFiltersNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReservationFiltersNotifier = AutoDisposeNotifier<ReservationFilters>;
String _$reservationsHash() => r'2693b3c9e29904f44e6aa5e1ea15fc711ff7b163';

/// See also [Reservations].
@ProviderFor(Reservations)
final reservationsProvider =
    AutoDisposeAsyncNotifierProvider<
      Reservations,
      List<ReservationModel>
    >.internal(
      Reservations.new,
      name: r'reservationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reservationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Reservations = AutoDisposeAsyncNotifier<List<ReservationModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
