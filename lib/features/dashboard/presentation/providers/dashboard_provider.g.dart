// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardServiceHash() => r'a035b95820ce7ddab6f45ab212b78315c7576574';

/// See also [dashboardService].
@ProviderFor(dashboardService)
final dashboardServiceProvider = AutoDisposeProvider<DashboardService>.internal(
  dashboardService,
  name: r'dashboardServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardServiceRef = AutoDisposeProviderRef<DashboardService>;
String _$dashboardBranchesServiceHash() =>
    r'2ac0ffae14fca5210ddededbb7da0a51180b7209';

/// See also [dashboardBranchesService].
@ProviderFor(dashboardBranchesService)
final dashboardBranchesServiceProvider =
    AutoDisposeProvider<BranchesService>.internal(
      dashboardBranchesService,
      name: r'dashboardBranchesServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardBranchesServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardBranchesServiceRef = AutoDisposeProviderRef<BranchesService>;
String _$dashboardBranchesHash() => r'46bfa62f8c525257c008f589e75c146ec7cdc71d';

/// See also [dashboardBranches].
@ProviderFor(dashboardBranches)
final dashboardBranchesProvider =
    AutoDisposeFutureProvider<List<BranchModel>>.internal(
      dashboardBranches,
      name: r'dashboardBranchesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardBranchesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardBranchesRef = AutoDisposeFutureProviderRef<List<BranchModel>>;
String _$dashboardSummaryHash() => r'6ef1a5b2c73ed0b9f37f505a0a573855ada009df';

/// See also [dashboardSummary].
@ProviderFor(dashboardSummary)
final dashboardSummaryProvider =
    AutoDisposeFutureProvider<List<DashboardCalendarItem>>.internal(
      dashboardSummary,
      name: r'dashboardSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardSummaryRef =
    AutoDisposeFutureProviderRef<List<DashboardCalendarItem>>;
String _$dashboardDayDetailHash() =>
    r'7815cc63ffb0f3935a7008900633529a64c19b17';

/// See also [dashboardDayDetail].
@ProviderFor(dashboardDayDetail)
final dashboardDayDetailProvider =
    AutoDisposeFutureProvider<DashboardDayDetail?>.internal(
      dashboardDayDetail,
      name: r'dashboardDayDetailProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardDayDetailHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardDayDetailRef =
    AutoDisposeFutureProviderRef<DashboardDayDetail?>;
String _$dashboardSelectedDateNotifierHash() =>
    r'b6bbc18881ea2436c6669ed8212dff70ac7a8f23';

/// See also [DashboardSelectedDateNotifier].
@ProviderFor(DashboardSelectedDateNotifier)
final dashboardSelectedDateNotifierProvider =
    AutoDisposeNotifierProvider<DashboardSelectedDateNotifier, String>.internal(
      DashboardSelectedDateNotifier.new,
      name: r'dashboardSelectedDateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardSelectedDateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DashboardSelectedDateNotifier = AutoDisposeNotifier<String>;
String _$dashboardSelectedBranchIdNotifierHash() =>
    r'5b9be1db0a81e11c0e13c7b01b2f09fdeda80fed';

/// See also [DashboardSelectedBranchIdNotifier].
@ProviderFor(DashboardSelectedBranchIdNotifier)
final dashboardSelectedBranchIdNotifierProvider =
    AutoDisposeNotifierProvider<
      DashboardSelectedBranchIdNotifier,
      String?
    >.internal(
      DashboardSelectedBranchIdNotifier.new,
      name: r'dashboardSelectedBranchIdNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardSelectedBranchIdNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DashboardSelectedBranchIdNotifier = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
