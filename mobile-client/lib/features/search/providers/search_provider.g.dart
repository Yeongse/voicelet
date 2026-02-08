// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchUsersHash() => r'c7412b2485d9ccaaf983cbc63a94b231b46a2e9e';

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

/// See also [searchUsers].
@ProviderFor(searchUsers)
const searchUsersProvider = SearchUsersFamily();

/// See also [searchUsers].
class SearchUsersFamily extends Family<AsyncValue<SearchUsersResponse>> {
  /// See also [searchUsers].
  const SearchUsersFamily();

  /// See also [searchUsers].
  SearchUsersProvider call({
    required String query,
    int page = 1,
    int limit = 20,
  }) {
    return SearchUsersProvider(query: query, page: page, limit: limit);
  }

  @override
  SearchUsersProvider getProviderOverride(
    covariant SearchUsersProvider provider,
  ) {
    return call(
      query: provider.query,
      page: provider.page,
      limit: provider.limit,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchUsersProvider';
}

/// See also [searchUsers].
class SearchUsersProvider
    extends AutoDisposeFutureProvider<SearchUsersResponse> {
  /// See also [searchUsers].
  SearchUsersProvider({required String query, int page = 1, int limit = 20})
    : this._internal(
        (ref) => searchUsers(
          ref as SearchUsersRef,
          query: query,
          page: page,
          limit: limit,
        ),
        from: searchUsersProvider,
        name: r'searchUsersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$searchUsersHash,
        dependencies: SearchUsersFamily._dependencies,
        allTransitiveDependencies: SearchUsersFamily._allTransitiveDependencies,
        query: query,
        page: page,
        limit: limit,
      );

  SearchUsersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
    required this.page,
    required this.limit,
  }) : super.internal();

  final String query;
  final int page;
  final int limit;

  @override
  Override overrideWith(
    FutureOr<SearchUsersResponse> Function(SearchUsersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchUsersProvider._internal(
        (ref) => create(ref as SearchUsersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
        page: page,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SearchUsersResponse> createElement() {
    return _SearchUsersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchUsersProvider &&
        other.query == query &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchUsersRef on AutoDisposeFutureProviderRef<SearchUsersResponse> {
  /// The parameter `query` of this provider.
  String get query;

  /// The parameter `page` of this provider.
  int get page;

  /// The parameter `limit` of this provider.
  int get limit;
}

class _SearchUsersProviderElement
    extends AutoDisposeFutureProviderElement<SearchUsersResponse>
    with SearchUsersRef {
  _SearchUsersProviderElement(super.provider);

  @override
  String get query => (origin as SearchUsersProvider).query;
  @override
  int get page => (origin as SearchUsersProvider).page;
  @override
  int get limit => (origin as SearchUsersProvider).limit;
}

String _$searchQueryHash() => r'b07ebd22fb9cb0db36c8d833cc6e21f4fcbd9b7b';

/// See also [SearchQuery].
@ProviderFor(SearchQuery)
final searchQueryProvider =
    AutoDisposeNotifierProvider<SearchQuery, String>.internal(
      SearchQuery.new,
      name: r'searchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
