import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/models/booking_model.dart';
import 'package:expense_tracker/utils/constants.dart';
import 'package:expense_tracker/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class BookingService {
  final _db = DatabaseHelper.instance;
  final _notificationService = NotificationService.instance;

  // Add new booking
  Future<int> addBooking(BookingModel booking) async {
    try {
      final id = await _db.insert(AppStrings.tableBookings, booking.toMap());
      
      // Schedule notification (don't let this block the save)
      if (id > 0) {
        try {
          await _scheduleBookingNotification(booking.copyWith(id: id));
        } catch (e) {
          // Log notification error but don't fail the save
          print('Failed to schedule notification: $e');
        }
      }
      
      return id;
    } catch (e) {
      print('Failed to add booking: $e');
      return 0;
    }
  }

  // Get all bookings for a user
  Future<List<BookingModel>> getBookings({required int userId}) async {
    final maps = await _db.queryWhere(
      AppStrings.tableBookings,
      'user_id = ?',
      [userId],
    );
    return maps.map((map) => BookingModel.fromMap(map)).toList()
      ..sort((a, b) => a.fullDateTime.compareTo(b.fullDateTime));
  }

  // Get upcoming bookings (today and future)
  Future<List<BookingModel>> getUpcomingBookings({required int userId}) async {
    final allBookings = await getBookings(userId: userId);
    final now = DateTime.now();
    return allBookings.where((booking) {
      return booking.fullDateTime.isAfter(now) || booking.isToday;
    }).toList();
  }

  // Get today's bookings
  Future<List<BookingModel>> getTodayBookings({required int userId}) async {
    final allBookings = await getBookings(userId: userId);
    return allBookings.where((booking) => booking.isToday).toList();
  }

  // Update booking
  Future<int> updateBooking(BookingModel booking) async {
    try {
      // Cancel old notification
      if (booking.id != null) {
        try {
          await _cancelBookingNotification(booking.id!);
        } catch (e) {
          print('Failed to cancel notification: $e');
        }
      }
      
      final result = await _db.update(AppStrings.tableBookings, booking.toMap());
      
      // Reschedule notification
      if (result > 0) {
        try {
          await _scheduleBookingNotification(booking);
        } catch (e) {
          print('Failed to reschedule notification: $e');
        }
      }
      
      return result;
    } catch (e) {
      print('Failed to update booking: $e');
      return 0;
    }
  }

  // Delete booking
  Future<int> deleteBooking(int id) async {
    await _cancelBookingNotification(id);
    return await _db.delete(AppStrings.tableBookings, id);
  }

  // Mark booking as completed
  Future<int> markAsCompleted(int id) async {
    final bookings = await _db.queryWhere(
      AppStrings.tableBookings,
      'id = ?',
      [id],
    );
    
    if (bookings.isNotEmpty) {
      final booking = BookingModel.fromMap(bookings.first);
      return await updateBooking(booking.copyWith(isCompleted: true));
    }
    
    return 0;
  }

  // Schedule notification for booking
  Future<void> _scheduleBookingNotification(BookingModel booking) async {
    try {
      if (booking.id == null) return;

      final scheduledDate = booking.fullDateTime;
      
      // Don't schedule if in the past
      if (scheduledDate.isBefore(DateTime.now())) return;

      // Calculate reminder time
      final reminderTime = scheduledDate.subtract(
        Duration(minutes: booking.reminderBefore),
      );

      // Only schedule if reminder time is in the future
      if (reminderTime.isAfter(DateTime.now())) {
        await _notificationService.notifications.zonedSchedule(
          booking.id! * 100, // Unique ID
          'Booking Reminder',
          '${booking.title} for ${booking.customerName} at ${booking.bookingTime}',
          tz.TZDateTime.from(reminderTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'bookings',
              'Booking Reminders',
              channelDescription: 'Reminders for upcoming bookings',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    } catch (e) {
      // Log error but don't throw - notifications are optional
      print('Notification scheduling error: $e');
    }
  }

  // Cancel booking notification
  Future<void> _cancelBookingNotification(int bookingId) async {
    await _notificationService.notifications.cancel(bookingId * 100);
  }

  // Get booking count for today
  Future<int> getTodayBookingCount({required int userId}) async {
    final todayBookings = await getTodayBookings(userId: userId);
    return todayBookings.length;
  }

  // Get upcoming booking count
  Future<int> getUpcomingBookingCount({required int userId}) async {
    final upcomingBookings = await getUpcomingBookings(userId: userId);
    return upcomingBookings.length;
  }
}
