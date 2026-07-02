String formatLastSyncedLabel(DateTime? lastSynced) {
  if (lastSynced == null) return 'Not synced yet';

  final local = lastSynced.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final syncDay = DateTime(local.year, local.month, local.day);
  final hour = local.hour > 12
      ? local.hour - 12
      : (local.hour == 0 ? 12 : local.hour);
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  final time = '$hour:$minute $period';

  if (syncDay == today) return 'Last synced today, $time';
  if (syncDay == today.subtract(const Duration(days: 1))) {
    return 'Last synced yesterday, $time';
  }
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return 'Last synced ${weekdays[local.weekday - 1]}, $time';
}
