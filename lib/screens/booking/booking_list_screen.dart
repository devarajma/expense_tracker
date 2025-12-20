import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/booking_provider.dart';
import 'package:expense_tracker/models/booking_model.dart';
import 'package:expense_tracker/screens/booking/add_booking_screen.dart';
import 'package:expense_tracker/utils/helpers.dart';
import 'package:intl/intl.dart';

class BookingListScreen extends ConsumerWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingNotifierProvider);
    final todayCount = ref.watch(todayBookingCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        actions: [
          if (todayCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text('$todayCount Today'),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
        ],
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No bookings yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your first booking order',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _BookingCard(
                booking: booking,
                onTap: () => _editBooking(context, ref, booking),
                onDelete: () => _deleteBooking(context, ref, booking.id!),
                onComplete: () => _completeBooking(ref, booking.id!),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addBooking(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Booking'),
      ),
    );
  }

  void _addBooking(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddBookingScreen()),
    );
  }

  void _editBooking(BuildContext context, WidgetRef ref, BookingModel booking) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddBookingScreen(booking: booking),
      ),
    );
  }

  void _deleteBooking(BuildContext context, WidgetRef ref, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure you want to delete this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref.read(bookingNotifierProvider.notifier).deleteBooking(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Booking deleted' : 'Failed to delete booking'),
          ),
        );
      }
    }
  }

  void _completeBooking(WidgetRef ref, int id) async {
    await ref.read(bookingNotifierProvider.notifier).markAsCompleted(id);
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  const _BookingCard({
    required this.booking,
    required this.onTap,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = booking.isToday;
    final isPast = booking.fullDateTime.isBefore(DateTime.now()) && !isToday;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isToday
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.event,
                      color: isToday ? Colors.white : null,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                booking.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      decoration: booking.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                              ),
                            ),
                            if (isToday)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'TODAY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Customer: ${booking.customerName}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (booking.description != null &&
                            booking.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            booking.description!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Helpers.formatDate(booking.bookingDate),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    booking.bookingTime,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (booking.reminderBefore > 0) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.notifications_active,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getReminderText(booking.reminderBefore),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!booking.isCompleted && !isPast)
                    TextButton.icon(
                      onPressed: onComplete,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Mark Complete'),
                    ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getReminderText(int minutes) {
    if (minutes >= 1440) {
      final days = minutes ~/ 1440;
      return '$days day${days > 1 ? 's' : ''} before';
    } else if (minutes >= 60) {
      final hours = minutes ~/ 60;
      return '$hours hour${hours > 1 ? 's' : ''} before';
    } else {
      return '$minutes min before';
    }
  }
}
