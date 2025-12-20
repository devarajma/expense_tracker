class BookingModel {
  final int? id;
  final int userId;
  final String customerName;
  final String title;
  final String? description;
  final DateTime bookingDate;
  final String bookingTime; // Format: HH:mm
  final int reminderBefore; // Minutes before (e.g., 60 for 1 hour, 1440 for 1 day)
  final bool isCompleted;
  final DateTime createdAt;

  BookingModel({
    this.id,
    required this.userId,
    required this.customerName,
    required this.title,
    this.description,
    required this.bookingDate,
    required this.bookingTime,
    this.reminderBefore = 60, // Default 1 hour before
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'customer_name': customerName,
      'title': title,
      'description': description,
      'booking_date': bookingDate.toIso8601String(),
      'booking_time': bookingTime,
      'reminder_before': reminderBefore,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      customerName: map['customer_name'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      bookingDate: DateTime.parse(map['booking_date'] as String),
      bookingTime: map['booking_time'] as String,
      reminderBefore: map['reminder_before'] as int? ?? 60,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // CopyWith for immutability
  BookingModel copyWith({
    int? id,
    int? userId,
    String? customerName,
    String? title,
    String? description,
    DateTime? bookingDate,
    String? bookingTime,
    int? reminderBefore,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      title: title ?? this.title,
      description: description ?? this.description,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      reminderBefore: reminderBefore ?? this.reminderBefore,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Check if booking is today
  bool get isToday {
    final now = DateTime.now();
    return bookingDate.year == now.year &&
        bookingDate.month == now.month &&
        bookingDate.day == now.day;
  }

  // Check if booking is upcoming (future)
  bool get isUpcoming {
    return bookingDate.isAfter(DateTime.now()) || isToday;
  }

  // Get formatted date time
  DateTime get fullDateTime {
    final timeParts = bookingTime.split(':');
    return DateTime(
      bookingDate.year,
      bookingDate.month,
      bookingDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }
}
