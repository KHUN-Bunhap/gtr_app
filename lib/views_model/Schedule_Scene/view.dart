import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui_utils/utils.dart';
import 'view_model.dart';

class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScheduleViewModel(),
      child: Builder(
        builder: (context) {
          final vm = context.watch<ScheduleViewModel>();
          return Scaffold(
            appBar: UIHelpers.gtrAppBar(
              title: 'Class Schedule',
              context: context,
              actions: [
                // Only show add button for admin and teachers
                if (vm.canEdit)
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      size: ResponsiveUtils.responsiveScale(
                        mobile: 25,
                        deviceType: ResponsiveUtils.getDeviceTypeFromContext(
                          context,
                        ),
                      ),
                    ),
                    onPressed: () => vm.showAdminScheduleDialog(context),
                    tooltip: 'Manage Schedule (Admin/Teacher Only)',
                  ),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                // Simplified responsive design detection
                final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
                  constraints,
                );

                // Create layout configuration using simplified ResponsiveUtils
                final LayoutConfig config = _getLayoutConfig(
                  constraints: constraints,
                  deviceType: deviceType,
                );

                return Column(
                  children: [
                    // Group selection dropdown
                    _buildGroupDropdown(context, vm, config),

                    // Semester Info Header
                    // _buildSemesterInfoHeader(context, config),

                    // Time slots and schedule grid with Firebase data
                    Expanded(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: vm.schedulesStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          final schedules = snapshot.data ?? [];

                          return _buildResponsiveScheduleBody(
                            vm,
                            config,
                            context,
                            schedules,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Group selection dropdown
  Widget _buildGroupDropdown(
    BuildContext context,
    ScheduleViewModel vm,
    LayoutConfig config,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: config.horizontalPadding,
        vertical: config.verticalPadding * 0.6, // More compact padding
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Group Filter: ',
            style: TextStyle(
              fontSize: config.dayHeaderFontSize,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: config.isComputer ? 16 : 12,
              vertical: config.isComputer ? 8 : 6,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: vm.selectedGroup,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).primaryColor,
                  size: config.isComputer ? 24 : 20,
                ),
                style: TextStyle(
                  fontSize: config.dayHeaderFontSize,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    vm.setSelectedGroup(newValue);
                  }
                },
                items: vm.groupOptions.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Semester information header
  // Widget _buildSemesterInfoHeader(BuildContext context, LayoutConfig config) {
  //   return Container(
  //     width: double.infinity,
  //     padding: EdgeInsets.symmetric(
  //       horizontal: config.horizontalPadding + 4,
  //       vertical: config.verticalPadding * 0.5, // More compact
  //     ),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
  //       border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(
  //           Icons.calendar_today,
  //           size: config.dayHeaderFontSize,
  //           color: Theme.of(context).primaryColor,
  //         ),
  //         SizedBox(width: 8),
  //         Text(
  //           'Semester 1, 2024-2025',
  //           style: TextStyle(
  //             fontSize: config.dayHeaderFontSize - 1,
  //             fontWeight: FontWeight.w500,
  //             color: Theme.of(context).primaryColor,
  //           ),
  //         ),
  //         const Spacer(),
  //         Text(
  //           'Week Schedule',
  //           style: TextStyle(
  //             fontSize: config.dayHeaderFontSize - 2,
  //             color: Colors.grey[600],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ResponsiveUtils-based layout configuration method
  LayoutConfig _getLayoutConfig({
    required BoxConstraints constraints,
    required DeviceType deviceType,
  }) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    final isComputer = deviceType == DeviceType.computer;
    final isCompact = constraints.maxWidth < 400;

    return LayoutConfig(
      isPhone: isMobile,
      isTablet: isTablet,
      isComputer: isComputer,
      isCompact: isCompact,
      isLandscape: constraints.maxWidth > constraints.maxHeight,
      screenWidth: constraints.maxWidth,
      screenHeight: constraints.maxHeight,
      deviceType: deviceType, // Add deviceType to LayoutConfig
      // Simplified ResponsiveUtils-based adaptive padding
      horizontalPadding: ResponsiveUtils.responsiveScale(
        mobile: isCompact ? 8.0 : 12.0,
        deviceType: deviceType,
      ),
      verticalPadding: ResponsiveUtils.responsiveScale(
        mobile: 8.0,
        deviceType: deviceType,
      ),
      // Responsive font sizes
      headerFontSize: ResponsiveUtils.responsiveScale(
        mobile: 18.0,
        deviceType: deviceType,
      ),
      dayHeaderFontSize: ResponsiveUtils.responsiveScale(
        mobile: 14.0,
        deviceType: deviceType,
      ),
      timeFontSize: ResponsiveUtils.responsiveScale(
        mobile: 13.0,
        deviceType: deviceType,
      ),
      classFontSize: ResponsiveUtils.responsiveScale(
        mobile: 12.0,
        deviceType: deviceType,
      ),
      classRoomFontSize: ResponsiveUtils.responsiveScale(
        mobile: 10.0,
        deviceType: deviceType,
      ),
      // Responsive cell dimensions
      cellHeight: ResponsiveUtils.responsiveScale(
        mobile: 90.0,
        deviceType: deviceType,
      ),
      cellPadding: ResponsiveUtils.responsiveScale(
        mobile: 6.0,
        deviceType: deviceType,
      ),
      innerCellPadding: ResponsiveUtils.responsiveScale(
        mobile: 4.0,
        deviceType: deviceType,
      ),
      // Icon sizes
      addIconSize: ResponsiveUtils.responsiveScale(
        mobile: 20.0,
        deviceType: deviceType,
      ),
      navigationIconSize: ResponsiveUtils.responsiveScale(
        mobile: 24.0,
        deviceType: deviceType,
      ),
      // Grid configuration - Wider columns
      timeColumnFlex: 3,
      dayColumnFlex: (deviceType == DeviceType.computer) ? 5 : 4,
      // Show/hide elements based on screen size
      showTeacherInCell:
          isComputer ||
          (isTablet && constraints.maxWidth > constraints.maxHeight),
      enableHorizontalScroll: true, // Always enable horizontal scroll
    );
  }

  // Responsive schedule body with enhanced horizontal scrolling
  Widget _buildResponsiveScheduleBody(
    ScheduleViewModel vm,
    LayoutConfig config,
    BuildContext context,
    List<Map<String, dynamic>> schedules,
  ) {
    // Create scroll controller for desktop horizontal scrollbar
    final horizontalScrollController = ScrollController();
    Widget scheduleContent = Container(
      padding: EdgeInsets.symmetric(
        horizontal: config.horizontalPadding,
        vertical: config.verticalPadding,
      ),
      child: Column(
        children: [
          // Days of week header
          _buildAdaptiveDaysHeader(context, config),
          SizedBox(height: config.isComputer ? 12 : 8),

          // Schedule grid
          _buildAdaptiveScheduleGrid(vm, config, context, schedules),
        ],
      ),
    );

    // Always enable horizontal scroll with wider minimum width
    // Calculate minimum width based on our fixed column widths
    final timeColumnWidth = config.isComputer
        ? 150.0
        : (config.isTablet ? 130.0 : 120.0);
    final dayColumnWidth = config.isComputer
        ? 300.0 // Increased from 220.0 to make computer day columns wider
        : (config.isTablet ? 280.0 : 250.0);
    final totalMinWidth =
        timeColumnWidth +
        (dayColumnWidth * 6) +
        20; // +20 for padding, 6 days (Mon-Sat)

    // Enable horizontal scrollbar for computer displays
    if (config.isComputer) {
      return Scrollbar(
        controller: horizontalScrollController,
        scrollbarOrientation: ScrollbarOrientation.bottom,
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          controller: horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: totalMinWidth),
            child: SingleChildScrollView(child: scheduleContent),
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: totalMinWidth),
          child: SingleChildScrollView(child: scheduleContent),
        ),
      );
    }
  }

  Widget _buildAdaptiveDaysHeader(BuildContext context, LayoutConfig config) {
    final days = [
      'Time',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ]; // Removed Sunday

    // Define fixed widths for better table layout
    final timeColumnWidth = config.isComputer
        ? 150.0
        : (config.isTablet ? 130.0 : 120.0);
    final dayColumnWidth = config.isComputer
        ? 300.0 // Increased from 220.0 to make computer day columns wider
        : (config.isTablet ? 280.0 : 250.0);

    return Row(
      children: days.map((day) {
        final isTimeColumn = day == 'Time';
        final width = isTimeColumn ? timeColumnWidth : dayColumnWidth;

        return Container(
          width: width,
          padding: EdgeInsets.symmetric(
            vertical: config.cellPadding + 4,
            horizontal: config.cellPadding,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: config.dayHeaderFontSize,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdaptiveScheduleGrid(
    ScheduleViewModel vm,
    LayoutConfig config,
    BuildContext context,
    List<Map<String, dynamic>> schedules,
  ) {
    // Use the same fixed widths as the header
    final timeColumnWidth = config.isComputer
        ? 150.0
        : (config.isTablet ? 130.0 : 120.0);
    final dayColumnWidth = config.isComputer
        ? 300.0 // Increased from 220.0 to make computer day columns wider
        : (config.isTablet ? 280.0 : 250.0);

    return Column(
      children: vm.timeSlots.map((timeSlot) {
        // Check if this is the lunch break separator
        if (timeSlot == 'LUNCH_BREAK') {
          return _buildLunchBreakSeparator(
            timeColumnWidth,
            dayColumnWidth,
            config,
            context,
          );
        }

        return Row(
          children: [
            // Time column with fixed width
            Container(
              width: timeColumnWidth,
              height: config.cellHeight,
              padding: EdgeInsets.all(config.cellPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  timeSlot,
                  style: TextStyle(
                    fontSize: config.timeFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Day columns with fixed width (Mon-Sat only, 6 days)
            ...List.generate(6, (dayIndex) {
              final classInfo = vm.getClassForTimeSlot(
                timeSlot,
                dayIndex,
                schedules,
              );

              return Container(
                width: dayColumnWidth,
                child: GestureDetector(
                  onTap: () =>
                      vm.onTimeSlotTap(timeSlot, dayIndex, schedules, context),
                  child: Container(
                    height: config.cellHeight,
                    padding: EdgeInsets.all(config.innerCellPadding),
                    decoration: BoxDecoration(
                      color: classInfo != null
                          ? Color(
                              classInfo['color'] ?? Colors.blue.value,
                            ).withValues(alpha: 0.7)
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: classInfo != null
                        ? _buildClassCell(classInfo, config)
                        : Container(), // Empty container for empty slots
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  // Build lunch break separator row
  Widget _buildLunchBreakSeparator(
    double timeColumnWidth,
    double dayColumnWidth,
    LayoutConfig config,
    BuildContext context,
  ) {
    return Row(
      children: [
        // Time column - completely blank
        Container(width: timeColumnWidth, height: config.cellHeight * 0.6),
      ],
    );
  }

  Widget _buildClassCell(Map<String, dynamic> classInfo, LayoutConfig config) {
    final classColor = Color(classInfo['color'] ?? Colors.blue.value);

    return Stack(
      children: [
        // Class type in upper right corner
        Positioned(
          top: 2,
          right: 4,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              classInfo['classType'] ?? '',
              style: TextStyle(
                fontSize: config.isComputer ? 10 : 8,
                fontWeight: FontWeight.bold,
                color: classColor,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 2,
          left: 4,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              classInfo['group'] ?? 'All Groups',
              style: TextStyle(
                fontSize: config.isComputer ? 10 : 8,
                fontWeight: FontWeight.bold,
                color: classColor,
              ),
            ),
          ),
        ),

        // Main content in center
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                classInfo['subject'] ?? '',
                style: TextStyle(
                  fontSize: config.classFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: config.isComputer ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
              if ((classInfo['room'] ?? '').isNotEmpty &&
                  classInfo['room'] != 'TBA') ...[
                SizedBox(height: config.isComputer ? 4 : 2),
                Text(
                  classInfo['room'] ?? '',
                  style: TextStyle(
                    fontSize: config.classRoomFontSize,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // Professor name in bottom right corner
        if ((classInfo['teacher'] ?? '').isNotEmpty &&
            classInfo['teacher'] != 'TBA')
          Positioned(
            bottom: 2,
            right: 4,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.responsiveScale(
                  mobile: 80.0,
                  deviceType: config.deviceType,
                ),
              ),
              child: Text(
                classInfo['teacher'] ?? '',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveScale(
                    mobile: 8.0,
                    deviceType: config.deviceType,
                  ),
                  color: Colors.white.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}

// Layout configuration class for responsive design
class LayoutConfig {
  final bool isPhone;
  final bool isTablet;
  final bool isComputer;
  final bool isCompact;
  final bool isLandscape;
  final double screenWidth;
  final double screenHeight;
  final DeviceType deviceType; // Add deviceType field

  // Spacing
  final double horizontalPadding;
  final double verticalPadding;

  // Typography
  final double headerFontSize;
  final double dayHeaderFontSize;
  final double timeFontSize;
  final double classFontSize;
  final double classRoomFontSize;

  // Dimensions
  final double cellHeight;
  final double cellPadding;
  final double innerCellPadding;
  final double addIconSize;
  final double navigationIconSize;

  // Grid layout
  final int timeColumnFlex;
  final int dayColumnFlex;

  // Features
  final bool showTeacherInCell;
  final bool enableHorizontalScroll;

  const LayoutConfig({
    required this.isPhone,
    required this.isTablet,
    required this.isComputer,
    required this.isCompact,
    required this.isLandscape,
    required this.screenWidth,
    required this.screenHeight,
    required this.deviceType,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.headerFontSize,
    required this.dayHeaderFontSize,
    required this.timeFontSize,
    required this.classFontSize,
    required this.classRoomFontSize,
    required this.cellHeight,
    required this.cellPadding,
    required this.innerCellPadding,
    required this.addIconSize,
    required this.navigationIconSize,
    required this.timeColumnFlex,
    required this.dayColumnFlex,
    required this.showTeacherInCell,
    required this.enableHorizontalScroll,
  });
}
