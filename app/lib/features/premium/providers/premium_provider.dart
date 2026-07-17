import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/storage/hive_boxes.dart';

/// The three Mirra+ plans. Product ids must match App Store Connect.
enum MirraPlan {
  weekly('mirra_plus_weekly', 'Weekly', '4,99 €', '7,99 €', '-38%', 'per week'),
  monthly(
    'mirra_plus_monthly',
    'Monthly',
    '10,99 €',
    '20,99 €',
    '-48%',
    'per month',
  ),
  annual(
    'mirra_plus_annual',
    'Annual',
    '44,99 €',
    '99,99 €',
    '-55%',
    'per year — 3,75 €/mo',
  );

  const MirraPlan(
    this.productId,
    this.label,
    this.fallbackPrice,
    this.originalPrice,
    this.discountBadge,
    this.period,
  );

  final String productId;
  final String label;

  /// Shown until the real localized price arrives from the store.
  final String fallbackPrice;

  /// Pre-promo price, shown struck through next to the current one.
  final String originalPrice;

  /// Promo badge derived from originalPrice → fallbackPrice.
  final String discountBadge;
  final String period;
}

class PremiumState {
  const PremiumState({
    required this.isPremium,
    this.products = const {},
    this.purchasing = false,
    this.storeAvailable = false,
  });

  final bool isPremium;

  /// Loaded store products by plan (empty until the store responds).
  final Map<MirraPlan, ProductDetails> products;
  final bool purchasing;
  final bool storeAvailable;

  PremiumState copyWith({
    bool? isPremium,
    Map<MirraPlan, ProductDetails>? products,
    bool? purchasing,
    bool? storeAvailable,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      products: products ?? this.products,
      purchasing: purchasing ?? this.purchasing,
      storeAvailable: storeAvailable ?? this.storeAvailable,
    );
  }

  String priceOf(MirraPlan plan) => products[plan]?.price ?? plan.fallbackPrice;
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  PremiumNotifier()
    : super(PremiumState(isPremium: MirraBoxes.current.isPremium)) {
    _init();
  }

  StreamSubscription<List<PurchaseDetails>>? _purchasesSub;

  Future<void> _init() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!mounted) return;
    state = state.copyWith(storeAvailable: available);
    if (!available) return;

    _purchasesSub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdates,
    );

    final response = await InAppPurchase.instance.queryProductDetails(
      MirraPlan.values.map((p) => p.productId).toSet(),
    );
    if (!mounted) return;
    state = state.copyWith(
      products: {
        for (final plan in MirraPlan.values)
          for (final product in response.productDetails)
            if (product.id == plan.productId) plan: product,
      },
    );
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      final isOurs = MirraPlan.values.any(
        (p) => p.productId == purchase.productID,
      );
      if (!isOurs) continue;

      final plan = MirraPlan.values
          .where((p) => p.productId == purchase.productID)
          .firstOrNull;
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grantPremium(plan);
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          if (mounted) state = state.copyWith(purchasing: false);
        case PurchaseStatus.pending:
          break;
      }
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  /// Starts the App Store purchase flow. In debug builds without a
  /// configured store (e.g. simulator), simulates a successful purchase so
  /// the whole funnel stays testable end-to-end.
  Future<void> buy(MirraPlan plan) async {
    final product = state.products[plan];
    if (product == null) {
      if (kDebugMode) {
        state = state.copyWith(purchasing: true);
        await Future<void>.delayed(const Duration(milliseconds: 600));
        await _grantPremium(plan);
      }
      return;
    }

    state = state.copyWith(purchasing: true);
    final param = PurchaseParam(productDetails: product);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() async {
    if (state.storeAvailable) {
      await InAppPurchase.instance.restorePurchases();
    }
  }

  Future<void> _grantPremium(MirraPlan? plan) async {
    await MirraBoxes.updatePrefs(
      (p) => p.copyWith(
        isPremium: true,
        premiumPlan: plan?.label ?? p.premiumPlan ?? 'Mirra+',
        premiumSince:
            p.premiumSince ?? DateTime.now().toIso8601String().substring(0, 10),
      ),
    );
    if (mounted) {
      state = state.copyWith(isPremium: true, purchasing: false);
    }
  }

  @override
  void dispose() {
    _purchasesSub?.cancel();
    super.dispose();
  }
}

final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>(
  (ref) => PremiumNotifier(),
);

/// Convenience: just the boolean, for gates.
final isPremiumProvider = Provider<bool>(
  (ref) => ref.watch(premiumProvider).isPremium,
);
