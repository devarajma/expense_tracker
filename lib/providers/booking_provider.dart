import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/models/booking_model.dart';
import 'package:expense_tracker/services/booking_service.dart';
import 'package:expense_tracker/providers/auth_provider.dart';

final bookingServiceProvider = Provider((ref) => BookingService());

// Booking list state notifier
class BookingNotifier extends StateNotifier<AsyncValue<List<BookingModel>>> {
  final BookingService _bookingService;
  final int _userId;

  BookingNotifier(this._bookingService, this._userId)
      : super(const AsyncValue.loading()) {
    loadBookings();
  }

  Future<void> loadBookings() async {
    state = const AsyncValue.loading();
    try {
      final bookings = await _bookingService.getBookings(userId: _userId);
      state = AsyncValue.data(bookings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addBooking(BookingModel booking) async {
    try {
      final id = await _bookingService.addBooking(booking);
      if (id > 0) {
        await loadBookings();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBooking(BookingModel booking) async {
    try {
      final result = await _bookingService.updateBooking(booking);
      if (result > 0) {
        await loadBookings();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBooking(int id) async {
    try {
      final result = await _bookingService.deleteBooking(id);
      if (result > 0) {
        await loadBookings();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAsCompleted(int id) async {
    try {
      final result = await _bookingService.markAsCompleted(id);
      if (result > 0) {
        await loadBookings();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final bookingNotifierProvider =
    StateNotifierProvider<BookingNotifier, AsyncValue<List<BookingModel>>>((ref) {
  final user = ref.watch(authNotifierProvider).value;
  final bookingService = ref.watch(bookingServiceProvider);
  
  if (user == null) {
    return BookingNotifier(bookingService, 0);
  }
  
  return BookingNotifier(bookingService, user.id!);
});

// Filter providers
final upcomingBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookingsAsync = ref.watch(bookingNotifierProvider);
  return bookingsAsync.when(
    data: (bookings) {
      final now = DateTime.now();
      return bookings.where((booking) {
        return booking.fullDateTime.isAfter(now) || booking.isToday;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final todayBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookingsAsync = ref.watch(bookingNotifierProvider);
  return bookingsAsync.when(
    data: (bookings) => bookings.where((b) => b.isToday).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final upcomingBookingCountProvider = Provider<int>((ref) {
  final upcomingBookings = ref.watch(upcomingBookingsProvider);
  return upcomingBookings.length;
});

final todayBookingCountProvider = Provider<int>((ref) {
  final todayBookings = ref.watch(todayBookingsProvider);
  return todayBookings.length;
});
