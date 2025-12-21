enum ChecklistStatusFilter { all, checked, unchecked }

enum ChecklistSortOrder { none, az, za }

class ChecklistFilter {
  final ChecklistStatusFilter status;
  final ChecklistSortOrder order;

  const ChecklistFilter({required this.status, required this.order});

  static const reset = ChecklistFilter(
    status: ChecklistStatusFilter.all,
    order: ChecklistSortOrder.none,
  );
}
