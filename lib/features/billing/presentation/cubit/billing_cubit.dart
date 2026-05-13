import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/invoice_model.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../../products/data/models/product_model.dart';

part 'billing_state.dart';

/// Represents one open invoice tab in the POS
class InvoiceTab extends Equatable {
  final String tabId;
  final String label;
  final List<InvoiceItemModel> items;
  final String? paymentMethod;

  const InvoiceTab({
    required this.tabId,
    required this.label,
    this.items = const [],
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [tabId, label, items, paymentMethod];

  double get total => items.fold(0, (sum, i) => sum + i.subtotal);

  InvoiceTab copyWith({
    List<InvoiceItemModel>? items,
    String? paymentMethod,
    String? label,
  }) =>
      InvoiceTab(
        tabId: tabId,
        label: label ?? this.label,
        items: items ?? this.items,
        paymentMethod: paymentMethod ?? this.paymentMethod,
      );

  Map<String, dynamic> toMap() => {
        'tabId': tabId,
        'label': label,
        'items': items.map((i) => i.toMap()).toList(),
        'paymentMethod': paymentMethod,
      };

  factory InvoiceTab.fromMap(Map<String, dynamic> map) => InvoiceTab(
        tabId: map['tabId'] as String,
        label: map['label'] as String,
        items: (map['items'] as List).map((i) => InvoiceItemModel.fromMap(i)).toList(),
        paymentMethod: map['paymentMethod'] as String?,
      );
}

class BillingCubit extends Cubit<BillingState> {
  final InvoiceRepository _repo;
  int _tabCounter = 1;

  BillingCubit(this._repo)
      : super(const BillingState(tabs: [], activeTabIndex: -1)) {
    _loadState();
  }

  static const _prefKey = 'billing_state_v2';

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'tabs': state.tabs.map((t) => t.toMap()).toList(),
      'activeTabIndex': state.activeTabIndex,
      'tabCounter': _tabCounter,
    };
    await prefs.setString(_prefKey, jsonEncode(data));
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null) {
        final data = jsonDecode(raw);
        _tabCounter = data['tabCounter'] as int;
        final tabs = (data['tabs'] as List).map((t) => InvoiceTab.fromMap(t)).toList();
        final activeIndex = (data['activeTabIndex'] as int).clamp(0, tabs.length - 1);
        emit(state.copyWith(tabs: tabs, activeTabIndex: activeIndex));
      }
    } catch (_) {}
  }

  void addTab({String? label}) {
    _tabCounter++;
    final newTab = InvoiceTab(
      tabId: '$_tabCounter',
      label: label ?? '$_tabCounter',
    );
    final tabs = List<InvoiceTab>.from(state.tabs)..add(newTab);
    emit(state.copyWith(tabs: tabs, activeTabIndex: tabs.length - 1));
    _saveState();
  }

  void renameTab(int index, String newName) {
    if (index < 0 || index >= state.tabs.length) return;
    final tabs = List<InvoiceTab>.from(state.tabs);
    tabs[index] = tabs[index].copyWith(label: newName);
    emit(state.copyWith(tabs: tabs));
    _saveState();
  }

  void removeTab(int index) {
    if (state.tabs.isEmpty) return;
    final tabs = List<InvoiceTab>.from(state.tabs)..removeAt(index);
    final newIndex = tabs.isEmpty ? -1 : (index >= tabs.length ? tabs.length - 1 : index);
    emit(state.copyWith(tabs: tabs, activeTabIndex: newIndex));
    _saveState();
  }

  void setActiveTab(int index) {
    emit(state.copyWith(activeTabIndex: index));
    _saveState();
  }

  void addProductToCurrentTab(ProductModel product) {
    if (state.activeTabIndex == -1 || state.tabs.isEmpty) return;
    
    final tabs = List<InvoiceTab>.from(state.tabs);
    final tab = tabs[state.activeTabIndex];
    final existingIndex = tab.items.indexWhere((i) => i.productId == product.id);
    
    List<InvoiceItemModel> newItems;
    if (existingIndex >= 0) {
      newItems = List<InvoiceItemModel>.from(tab.items);
      newItems[existingIndex] = newItems[existingIndex].copyWith(
        quantity: newItems[existingIndex].quantity + 1,
      );
    } else {
      newItems = List<InvoiceItemModel>.from(tab.items)
        ..add(InvoiceItemModel(
          id: '',
          invoiceId: '',
          productId: product.id,
          productName: product.localizedName,
          price: product.price,
          quantity: 1,
        ));
    }
    tabs[state.activeTabIndex] = tab.copyWith(items: newItems);
    emit(state.copyWith(tabs: tabs));
    _saveState();
  }

  void updateQuantity(int itemIndex, int qty) {
    if (qty <= 0) {
      removeItem(itemIndex);
      return;
    }
    final tabs = List<InvoiceTab>.from(state.tabs);
    final tab = tabs[state.activeTabIndex];
    final items = List<InvoiceItemModel>.from(tab.items);
    items[itemIndex] = items[itemIndex].copyWith(quantity: qty);
    tabs[state.activeTabIndex] = tab.copyWith(items: items);
    emit(state.copyWith(tabs: tabs));
    _saveState();
  }

  void removeItem(int itemIndex) {
    final tabs = List<InvoiceTab>.from(state.tabs);
    final tab = tabs[state.activeTabIndex];
    final items = List<InvoiceItemModel>.from(tab.items)..removeAt(itemIndex);
    tabs[state.activeTabIndex] = tab.copyWith(items: items);
    emit(state.copyWith(tabs: tabs));
    _saveState();
  }

  void setPaymentMethod(String method) {
    final tabs = List<InvoiceTab>.from(state.tabs);
    tabs[state.activeTabIndex] = tabs[state.activeTabIndex].copyWith(paymentMethod: method);
    emit(state.copyWith(tabs: tabs));
    _saveState();
  }

  Future<void> saveCurrentInvoice() async {
    if (state.activeTabIndex == -1 || state.tabs.isEmpty) return;
    
    final tab = state.tabs[state.activeTabIndex];
    if (tab.items.isEmpty || tab.paymentMethod == null) return;

    final invoice = InvoiceModel(
      id: '',
      createdAt: DateTime.now(),
      paymentMethod: tab.paymentMethod!,
      total: tab.total,
      items: tab.items,
    );

    emit(state.copyWith(isSaving: true));
    try {
      await _repo.saveInvoice(invoice);
      
      // Remove the tab after saving instead of replacing
      final tabs = List<InvoiceTab>.from(state.tabs);
      final idx = state.activeTabIndex;
      tabs.removeAt(idx);
      final newIndex = tabs.isEmpty ? -1 : (idx >= tabs.length ? tabs.length - 1 : idx);
      
      emit(state.copyWith(
        tabs: tabs,
        activeTabIndex: newIndex,
        isSaving: false,
        lastSavedMessage: 'invoiceSaved',
        lastSavedInvoice: invoice,
      ));
      _saveState();
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  void clearLastSaved() {
    emit(state.copyWith(lastSavedMessage: null, lastSavedInvoice: null));
  }
}
