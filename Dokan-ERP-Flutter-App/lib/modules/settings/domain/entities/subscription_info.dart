class SubscriptionInvoice {
  const SubscriptionInvoice({
    required this.id,
    required this.billingDate,
    required this.billableAccounts,
    required this.ratePerAccount,
    required this.totalAmount,
    required this.paidAmount,
    required this.amountDue,
    required this.status,
  });

  final String id;
  final String billingDate;
  final int billableAccounts;
  final double ratePerAccount;
  final double totalAmount;
  final double paidAmount;
  final double amountDue;
  final String status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'billingDate': billingDate,
        'billableAccounts': billableAccounts,
        'ratePerAccount': ratePerAccount,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'amountDue': amountDue,
        'status': status,
      };

  factory SubscriptionInvoice.fromJson(Map<String, dynamic> json) {
    return SubscriptionInvoice(
      id: json['id'] as String? ?? '',
      billingDate: json['billingDate'] as String? ?? '',
      billableAccounts: (json['billableAccounts'] as num?)?.toInt() ?? 0,
      ratePerAccount: (json['ratePerAccount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      amountDue: (json['amountDue'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
    );
  }
}

class SubscriptionPayment {
  const SubscriptionPayment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.method,
    this.trxId,
    required this.status,
    required this.paidAt,
    this.billingDate,
  });

  final String id;
  final String invoiceId;
  final double amount;
  final String method;
  final String? trxId;
  final String status;
  final String paidAt;
  final String? billingDate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceId': invoiceId,
        'amount': amount,
        'method': method,
        'trxId': trxId,
        'status': status,
        'paidAt': paidAt,
        'billingDate': billingDate,
      };

  factory SubscriptionPayment.fromJson(Map<String, dynamic> json) {
    return SubscriptionPayment(
      id: json['id'] as String? ?? '',
      invoiceId: json['invoiceId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: json['method'] as String? ?? '',
      trxId: json['trxId'] as String?,
      status: json['status'] as String? ?? '',
      paidAt: json['paidAt'] as String? ?? json['createdAt'] as String? ?? '',
      billingDate: json['billingDate'] as String?,
    );
  }
}

class SubscriptionInfo {
  const SubscriptionInfo({
    required this.allowed,
    required this.status,
    required this.tier,
    required this.trialEndsAt,
    this.billingDate,
    required this.billableAccounts,
    required this.ratePerAccount,
    required this.totalAmount,
    required this.paidAmount,
    required this.amountDue,
    this.message,
    required this.recentInvoices,
    required this.recentPayments,
  });

  final bool allowed;
  final String status;
  final String tier;
  final String trialEndsAt;
  final String? billingDate;
  final int billableAccounts;
  final double ratePerAccount;
  final double totalAmount;
  final double paidAmount;
  final double amountDue;
  final String? message;
  final List<SubscriptionInvoice> recentInvoices;
  final List<SubscriptionPayment> recentPayments;

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    final rawSubscription = json['subscription'];
    final sub = rawSubscription is Map
        ? Map<String, dynamic>.from(rawSubscription)
        : const <String, dynamic>{};
    final recentInvoicesJson = json['recentInvoices'] as List? ?? const [];
    final recentPaymentsJson = json['recentPayments'] as List? ?? const [];

    return SubscriptionInfo(
      allowed: sub['allowed'] as bool? ?? false,
      status: sub['status'] as String? ?? 'TRIAL',
      tier: sub['tier'] as String? ?? 'TRIAL',
      trialEndsAt: sub['trialEndsAt'] as String? ?? '',
      billingDate: sub['billingDate'] as String?,
      billableAccounts: (sub['billableAccounts'] as num?)?.toInt() ?? 0,
      ratePerAccount: (sub['ratePerAccount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (sub['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (sub['paidAmount'] as num?)?.toDouble() ?? 0.0,
      amountDue: (sub['amountDue'] as num?)?.toDouble() ?? 0.0,
      message: sub['message'] as String?,
      recentInvoices: recentInvoicesJson
          .whereType<Map>()
          .map(
              (i) => SubscriptionInvoice.fromJson(Map<String, dynamic>.from(i)))
          .toList(),
      recentPayments: recentPaymentsJson
          .whereType<Map>()
          .map(
              (p) => SubscriptionPayment.fromJson(Map<String, dynamic>.from(p)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'subscription': {
          'allowed': allowed,
          'status': status,
          'tier': tier,
          'trialEndsAt': trialEndsAt,
          'billingDate': billingDate,
          'billableAccounts': billableAccounts,
          'ratePerAccount': ratePerAccount,
          'totalAmount': totalAmount,
          'paidAmount': paidAmount,
          'amountDue': amountDue,
          'message': message,
        },
        'recentInvoices': recentInvoices.map((i) => i.toJson()).toList(),
        'recentPayments': recentPayments.map((p) => p.toJson()).toList(),
      };
}
