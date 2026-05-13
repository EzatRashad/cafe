part of 'billing_cubit.dart';

class BillingState extends Equatable {
  final List<InvoiceTab> tabs;
  final int activeTabIndex;
  final bool isSaving;
  final String? lastSavedMessage;
  final String? error;

  final InvoiceModel? lastSavedInvoice;

  const BillingState({
    required this.tabs,
    required this.activeTabIndex,
    this.isSaving = false,
    this.lastSavedMessage,
    this.error,
    this.lastSavedInvoice,
  });

  InvoiceTab get activeTab => tabs[activeTabIndex];

  BillingState copyWith({
    List<InvoiceTab>? tabs,
    int? activeTabIndex,
    bool? isSaving,
    String? lastSavedMessage,
    String? error,
    InvoiceModel? lastSavedInvoice,
  }) =>
      BillingState(
        tabs: tabs ?? this.tabs,
        activeTabIndex: activeTabIndex ?? this.activeTabIndex,
        isSaving: isSaving ?? this.isSaving,
        lastSavedMessage: lastSavedMessage,
        error: error,
        lastSavedInvoice: lastSavedInvoice,
      );

  @override
  List<Object?> get props => [
        tabs,
        activeTabIndex,
        isSaving,
        lastSavedMessage,
        error,
        lastSavedInvoice
      ];
}
