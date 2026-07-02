import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/db/expense_db.dart';
import 'package:tourio/db/tour_db.dart';
import 'package:tourio/models/expense_model.dart';
import 'package:tourio/models/tour_model.dart';
import 'package:tourio/screens/expense/widget/category_config.dart';

class TrashScreen extends StatefulWidget {
  final TourModel tour;
  const TrashScreen({super.key, required this.tour});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final Set<int> _restoringIds = {};
  late TourModel _selectedTour;
  List<TourModel> _tours = [];
  List<ExpenseModel> _deletedExpenses = [];
  bool _isLoading = true;

  double get _totalDeletedAmount =>
      _deletedExpenses.fold(0, (sum, item) => sum + item.amount);

  @override
  void initState() {
    super.initState();
    _selectedTour = widget.tour;
    _tours = [widget.tour];
    _loadTours();
    _loadTrashForSelectedTour();
  }

  Future<void> _loadTours() async {
    final tours = await TourDb.getAllToursDropdown();

    if (!mounted) return;
    setState(() {
      final hasSelectedTour = tours.any((tour) => tour.id == _selectedTour.id);
      _tours = hasSelectedTour ? tours : [_selectedTour, ...tours];
    });
  }

  Future<void> _loadTrashForSelectedTour() async {
    final selectedTourId = _selectedTour.id;
    if (selectedTourId == null) return;

    setState(() => _isLoading = true);

    final expenses = await ExpenseDb.getByTour(
      selectedTourId,
      includeDeleted: true,
    );

    final deleted = expenses.where((item) => item.isDeleted).toList()
      ..sort((a, b) {
        final aDate = a.lastUpdatedAt ?? a.expenseDate;
        final bDate = b.lastUpdatedAt ?? b.expenseDate;
        return bDate.compareTo(aDate);
      });

    if (!mounted || _selectedTour.id != selectedTourId) return;
    setState(() {
      _deletedExpenses = deleted;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle bin'),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _summaryBox(scheme),
            Expanded(child: _body(scheme)),
          ],
        ),
      ),
    );
  }

  Widget _summaryBox(ColorScheme scheme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  LucideIcons.trash2,
                  color: scheme.onErrorContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedTour.tourName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _deletedExpenses.length == 1
                          ? '1 deleted expense'
                          : '${_deletedExpenses.length} deleted expenses',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatAmount(_totalDeletedAmount),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _tourSelector(scheme),
        ],
      ),
    );
  }

  Widget _tourSelector(ColorScheme scheme) {
    final selectedTourId = _selectedTour.id;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: selectedTourId,
          icon: Icon(
            LucideIcons.chevronsUpDown,
            size: 18,
            color: scheme.outline,
          ),
          borderRadius: BorderRadius.circular(16),
          items: _tours
              .where((tour) => tour.id != null)
              .map(
                (tour) => DropdownMenuItem<int>(
                  value: tour.id,
                  child: Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 17, color: scheme.outline),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tour.tourName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: _onTourChanged,
        ),
      ),
    );
  }

  Widget _body(ColorScheme scheme) {
    if (_isLoading) {
      return _loadingState(scheme);
    }

    if (_deletedExpenses.isEmpty) {
      return _emptyState(scheme);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _deletedExpenses.length,
      itemBuilder: (context, index) {
        return _expenseCard(_deletedExpenses[index], scheme);
      },
    );
  }

  Widget _expenseCard(ExpenseModel item, ColorScheme scheme) {
    final category =
        expenseCategoryMap[item.category] ?? expenseCategoryMap['Other']!;
    final deletedAt = item.lastUpdatedAt ?? item.expenseDate;
    final isRestoring = item.id != null && _restoringIds.contains(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(category.icon, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _metaWrap(item, deletedAt, scheme),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 104),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topRight,
                  child: Text(
                    _formatAmount(item.amount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isRestoring ? null : () => _restoreExpense(item),
              icon: isRestoring
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onSurfaceVariant,
                      ),
                    )
                  : const Icon(LucideIcons.rotateCcw, size: 18),
              label: Text(isRestoring ? 'Recovering' : 'Recover expense'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaWrap(ExpenseModel item, DateTime deletedAt, ColorScheme scheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _metaChip(
          LucideIcons.calendar,
          DateFormat('EEE, d MMM yyyy').format(item.expenseDate),
          scheme,
        ),
        _metaChip(LucideIcons.tag, item.category, scheme),
        _metaChip(LucideIcons.user, _paidByLabel(item), scheme),
        _metaChip(
          LucideIcons.clock3,
          DateFormat('d MMM, h:mm a').format(deletedAt),
          scheme,
        ),
      ],
    );
  }

  Widget _metaChip(IconData icon, String label, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.outline),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.outline,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingState(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          Text(
            'Loading deleted expenses',
            style: TextStyle(color: scheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(LucideIcons.inbox, size: 32, color: scheme.outline),
            ),
            const SizedBox(height: 16),
            const Text(
              'No deleted expenses',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Deleted expenses from this tour will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restoreExpense(ExpenseModel item) async {
    final id = item.id;
    if (id == null || _restoringIds.contains(id)) return;

    setState(() => _restoringIds.add(id));

    try {
      await ExpenseDb.restore(id);

      if (!mounted) return;
      setState(() {
        _deletedExpenses.removeWhere((expense) => expense.id == id);
        _restoringIds.remove(id);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${item.title} recovered')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _restoringIds.remove(id));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not recover expense')),
      );
    }
  }

  void _onTourChanged(int? tourId) {
    if (tourId == null || tourId == _selectedTour.id) return;

    final tour = _tours.firstWhere((item) => item.id == tourId);
    setState(() {
      _selectedTour = tour;
      _deletedExpenses = [];
      _restoringIds.clear();
      _isLoading = true;
    });

    _loadTrashForSelectedTour();
  }

  String _paidByLabel(ExpenseModel item) {
    final name = item.paidByName?.trim();
    if (name == null || name.isEmpty) return 'You';
    return name;
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs ',
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return formatter.format(amount);
  }
}
