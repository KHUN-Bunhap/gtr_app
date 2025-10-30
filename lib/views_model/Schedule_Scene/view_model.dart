import 'package:flutter/material.dart';
import '../../services/schedule_service.dart';
import '../../services/auth_service.dart';
import '../../ui_utils/color_size_style.dart';

/// ViewModel for Schedule Scene
/// Handles all business logic, state management, and data operations
class ScheduleViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();

  // User role state
  bool _canEdit = false;
  bool _isLoadingRole = true;

  bool get canEdit => _canEdit;
  bool get isLoadingRole => _isLoadingRole;

  // Constructor - load user role
  ScheduleViewModel() {
    _loadUserRole();
  }

  // Load user role from AuthService
  // Admin and Teacher can edit schedules, Students cannot
  Future<void> _loadUserRole() async {
    _isLoadingRole = true;
    notifyListeners();

    try {
      _canEdit = await _authService.canEditSchedule();
    } catch (e) {
      _canEdit = false;
    }

    _isLoadingRole = false;
    notifyListeners();
  }

  // Group selection state
  String _selectedGroup = 'All Groups';

  final List<String> groupOptions = [
    'All Groups',
    'Group A',
    'Group B',
    'Group C',
    'Group AB',
  ];

  String get selectedGroup => _selectedGroup;

  void setSelectedGroup(String group) {
    _selectedGroup = group;
    notifyListeners();
  }

  // Time slots configuration
  final List<String> timeSlots = [
    '07:00 - 07:55', // Morning session
    '08:00 - 08:55',
    '09:10 - 10:05', // 15-minute break after 08:55
    '10:10 - 11:05', // 5-minute break
    'LUNCH_BREAK', // Lunch break separator from 11:05 to 13:00
    '13:00 - 13:55', // Afternoon session starts at 1:00 PM
    '14:00 - 14:55',
    '15:10 - 16:05', // 15-minute break after 14:55
    '16:10 - 17:05', // Classes end at 5:05 PM
  ];

  // Available colors for class selection
  final List<Color> availableColors = [
    Colors.amber,
    Colors.orange,
    Colors.deepOrangeAccent,
    Colors.pinkAccent,
    Colors.pink,
    Colors.redAccent,
    Colors.red,
    Colors.purpleAccent,
    Colors.purple,
    Colors.lightGreen,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.blue,
    Colors.indigo,
  ];

  /// Stream of all schedules from Firebase
  Stream<List<Map<String, dynamic>>> get schedulesStream {
    return _scheduleService.getAllSchedulesStream().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID for future operations
        return data;
      }).toList();
    });
  }

  /// Get class information for a specific time slot and day from Firebase data
  Map<String, dynamic>? getClassForTimeSlot(
    String timeSlot,
    int dayIndex,
    List<Map<String, dynamic>> schedules,
  ) {
    // Return null for lunch break separator
    if (timeSlot == 'LUNCH_BREAK') {
      return null;
    }

    // Find matching class from Firebase data with group filtering
    for (var schedule in schedules) {
      final scheduleGroup = schedule['group'] ?? 'All Groups';
      final matchesGroup =
          _selectedGroup == 'All Groups' ||
          scheduleGroup == 'All Groups' ||
          scheduleGroup == _selectedGroup;

      if (schedule['timeSlot'] == timeSlot &&
          schedule['dayOfWeek'] == dayIndex &&
          matchesGroup) {
        return schedule;
      }
    }

    return null;
  }

  /// Handle time slot tap - shows class details for existing classes
  void onTimeSlotTap(
    String timeSlot,
    int dayIndex,
    List<Map<String, dynamic>> schedules,
    BuildContext context,
  ) {
    // Don't allow interaction with lunch break separator
    if (timeSlot == 'LUNCH_BREAK') {
      return;
    }

    final existingClass = getClassForTimeSlot(timeSlot, dayIndex, schedules);

    if (existingClass != null) {
      showClassDetails(context, existingClass);
    }
  }

  /// Show class details dialog from Firebase data with Edit/Delete options
  /// Only Admin and Teachers can edit/delete
  void showClassDetails(BuildContext context, Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(classData['subject'] ?? 'Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Time:', classData['timeSlot'] ?? ''),
              _buildDetailRow('Room:', classData['room'] ?? ''),
              _buildDetailRow('Teacher:', classData['teacher'] ?? ''),
              _buildDetailRow('Day:', _getDayName(classData['dayOfWeek'] ?? 0)),
              _buildDetailRow('Type:', classData['classType'] ?? ''),
              _buildDetailRow('Group:', classData['group'] ?? 'All Groups'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            // Only show Edit/Delete buttons for admin and teachers
            if (_canEdit) ...[
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showEditClassDialog(context, classData);
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmDialog(context, classData);
                },
              ),
            ],
          ],
        );
      },
    );
  }

  String _getDayName(int dayIndex) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return days[dayIndex];
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Show admin schedule management dialog - only for adding new classes
  void showAdminScheduleDialog(BuildContext context) {
    // Directly show add class dialog
    showAddClassDialog(context);
  }

  /// Show add class dialog with form
  void showAddClassDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final roomController = TextEditingController();
    final teacherController = TextEditingController();
    String selectedTimeSlot = timeSlots[0];
    String selectedDay = 'Monday';
    String selectedClassType = 'Course';
    String selectedGroup = 'All Groups';
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    hintText: 'e.g., Mobile Application',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: roomController,
                  decoration: const InputDecoration(
                    labelText: 'Room',
                    hintText: 'e.g., J-502',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: teacherController,
                  decoration: const InputDecoration(
                    labelText: 'Teacher',
                    hintText: 'e.g., Dr. Sreng Sokchenda',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedGroup,
                  decoration: const InputDecoration(labelText: 'Group'),
                  items: groupOptions
                      .map(
                        (group) =>
                            DropdownMenuItem(value: group, child: Text(group)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => selectedGroup = value!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(labelText: 'Day'),
                  items:
                      [
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday',
                            'Saturday',
                          ]
                          .map(
                            (day) =>
                                DropdownMenuItem(value: day, child: Text(day)),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => selectedDay = value!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedTimeSlot,
                  decoration: const InputDecoration(labelText: 'Time Slot'),
                  items: timeSlots
                      .where((slot) => slot != 'LUNCH_BREAK')
                      .map(
                        (slot) =>
                            DropdownMenuItem(value: slot, child: Text(slot)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedTimeSlot = value!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedClassType,
                  decoration: const InputDecoration(labelText: 'Class Type'),
                  items: ['Course', 'TP', 'TD']
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedClassType = value!),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Select Color',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableColors.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _handleAddClass(
                  context,
                  subjectController,
                  roomController,
                  teacherController,
                  selectedDay,
                  selectedTimeSlot,
                  selectedClassType,
                  selectedGroup,
                  selectedColor,
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle add class form submission
  Future<void> _handleAddClass(
    BuildContext context,
    TextEditingController subjectController,
    TextEditingController roomController,
    TextEditingController teacherController,
    String selectedDay,
    String selectedTimeSlot,
    String selectedClassType,
    String selectedGroup,
    Color selectedColor,
  ) async {
    // Validate required fields
    if (subjectController.text.isEmpty ||
        roomController.text.isEmpty ||
        teacherController.text.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all required fields'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      // Convert day name to index
      final dayIndex = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ].indexOf(selectedDay);

      // Save to Firebase
      await _scheduleService.addScheduleClass(
        subject: subjectController.text,
        room: roomController.text,
        teacher: teacherController.text,
        timeSlot: selectedTimeSlot,
        dayOfWeek: dayIndex,
        classType: selectedClassType,
        group: selectedGroup == 'All Groups' ? null : selectedGroup,
        color: selectedColor.value,
      );

      if (context.mounted) {
        // Pop the add dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Show edit class dialog with pre-filled data
  void _showEditClassDialog(
    BuildContext context,
    Map<String, dynamic> classData,
  ) {
    final subjectController = TextEditingController(
      text: classData['subject'] ?? '',
    );
    final roomController = TextEditingController(text: classData['room'] ?? '');
    final teacherController = TextEditingController(
      text: classData['teacher'] ?? '',
    );
    String selectedTimeSlot = classData['timeSlot'] ?? timeSlots[0];
    String selectedDay = _getDayName(classData['dayOfWeek'] ?? 0);
    String selectedClassType = classData['classType'] ?? 'Course';
    String selectedGroup = classData['group'] ?? 'All Groups';
    Color selectedColor = Color(classData['color'] ?? Colors.blue.value);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    hintText: 'e.g., Mobile Application',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: roomController,
                  decoration: const InputDecoration(
                    labelText: 'Room',
                    hintText: 'e.g., J-502',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: teacherController,
                  decoration: const InputDecoration(
                    labelText: 'Teacher',
                    hintText: 'e.g., Dr. Sreng Sokchenda',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedGroup,
                  decoration: const InputDecoration(labelText: 'Group'),
                  items: groupOptions
                      .map(
                        (group) =>
                            DropdownMenuItem(value: group, child: Text(group)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => selectedGroup = value!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(labelText: 'Day'),
                  items:
                      [
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday',
                            'Saturday',
                          ]
                          .map(
                            (day) =>
                                DropdownMenuItem(value: day, child: Text(day)),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => selectedDay = value!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedTimeSlot,
                  decoration: const InputDecoration(labelText: 'Time Slot'),
                  items: timeSlots
                      .where((slot) => slot != 'LUNCH_BREAK')
                      .map(
                        (slot) =>
                            DropdownMenuItem(value: slot, child: Text(slot)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedTimeSlot = value!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedClassType,
                  decoration: const InputDecoration(labelText: 'Class Type'),
                  items: ['Course', 'TP', 'TD']
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedClassType = value!),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Select Color',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableColors.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _handleUpdateClass(
                  context,
                  classData['id'],
                  subjectController,
                  roomController,
                  teacherController,
                  selectedDay,
                  selectedTimeSlot,
                  selectedClassType,
                  selectedGroup,
                  selectedColor,
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle update class form submission
  Future<void> _handleUpdateClass(
    BuildContext context,
    String classId,
    TextEditingController subjectController,
    TextEditingController roomController,
    TextEditingController teacherController,
    String selectedDay,
    String selectedTimeSlot,
    String selectedClassType,
    String selectedGroup,
    Color selectedColor,
  ) async {
    // Validate required fields
    if (subjectController.text.isEmpty ||
        roomController.text.isEmpty ||
        teacherController.text.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all required fields'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      // Convert day name to index
      final dayIndex = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ].indexOf(selectedDay);

      // Update in Firebase
      await _scheduleService.updateScheduleClass(
        classId: classId,
        subject: subjectController.text,
        room: roomController.text,
        teacher: teacherController.text,
        timeSlot: selectedTimeSlot,
        dayOfWeek: dayIndex,
        classType: selectedClassType,
        group: selectedGroup == 'All Groups' ? null : selectedGroup,
        color: selectedColor.value,
      );

      if (context.mounted) {
        // Pop the edit dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmDialog(
    BuildContext context,
    Map<String, dynamic> classData,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text(
          'Are you sure you want to delete "${classData['subject'] ?? 'this class'}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await _handleDeleteClass(context, classData['id']);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Handle delete class
  Future<void> _handleDeleteClass(BuildContext context, String classId) async {
    try {
      await _scheduleService.deleteScheduleClass(classId);

      if (context.mounted) {
        // Pop the delete confirmation dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class deleted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
