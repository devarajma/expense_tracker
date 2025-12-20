import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/models/booking_model.dart';
import 'package:expense_tracker/providers/booking_provider.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/widgets/custom_button.dart';
import 'package:expense_tracker/widgets/custom_text_field.dart';
import 'package:expense_tracker/utils/helpers.dart';

class AddBookingScreen extends ConsumerStatefulWidget {
  final BookingModel? booking;

  const AddBookingScreen({super.key, this.booking});

  @override
  ConsumerState<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends ConsumerState<AddBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _reminderBefore = 60; // Default 1 hour
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.booking != null) {
      _customerNameController.text = widget.booking!.customerName;
      _titleController.text = widget.booking!.title;
      _descriptionController.text = widget.booking!.description ?? '';
      _selectedDate = widget.booking!.bookingDate;
      
      final timeParts = widget.booking!.bookingTime.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      _reminderBefore = widget.booking!.reminderBefore;
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.booking == null ? 'Add Booking' : 'Edit Booking'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _customerNameController,
              label: 'Customer Name',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _titleController,
              label: 'Booking Title',
              prefixIcon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter booking title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description (Optional)',
              prefixIcon: Icons.notes,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Booking Date & Time',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(Helpers.formatDate(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectTime,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Time',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_selectedTime.format(context)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Reminder',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _reminderBefore,
              decoration: InputDecoration(
                labelText: 'Remind me before',
                prefixIcon: const Icon(Icons.notifications_active),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('No Reminder')),
                DropdownMenuItem(value: 30, child: Text('30 minutes before')),
                DropdownMenuItem(value: 60, child: Text('1 hour before')),
                DropdownMenuItem(value: 120, child: Text('2 hours before')),
                DropdownMenuItem(value: 1440, child: Text('1 day before')),
                DropdownMenuItem(value: 2880, child: Text('2 days before')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _reminderBefore = value);
                }
              },
            ),
            const SizedBox(height: 32),
            CustomButton(
              onPressed: _isLoading ? null : _saveBooking,
              text: widget.booking == null ? 'Add Booking' : 'Update Booking',
              icon: Icons.save,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    final bookingTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    final booking = BookingModel(
      id: widget.booking?.id,
      userId: user.id!,
      customerName: _customerNameController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      bookingDate: _selectedDate,
      bookingTime: bookingTime,
      reminderBefore: _reminderBefore,
      createdAt: widget.booking?.createdAt,
    );

    final success = widget.booking == null
        ? await ref.read(bookingNotifierProvider.notifier).addBooking(booking)
        : await ref.read(bookingNotifierProvider.notifier).updateBooking(booking);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.booking == null
                  ? 'Booking added successfully'
                  : 'Booking updated successfully',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save booking')),
        );
      }
    }
  }
}
