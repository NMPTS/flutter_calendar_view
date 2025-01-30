// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../calendar_event_data.dart';
import '../constants.dart';
import '../enumerations.dart';
import '../extensions.dart';
import '../typedefs.dart';
import 'components.dart';

/// This will be used in day and week view
class DefaultPressDetector extends StatelessWidget {
  /// default press detector builder used in week and day view
  const DefaultPressDetector({
    required this.date,
    required this.height,
    required this.width,
    required this.heightPerMinute,
    required this.minuteSlotSize,
    this.onDateTap,
    this.onDateLongPress,
    required this.onHover,
    required this.onHoverWidget,
    required this.onExit,
    this.startHour = 0,
  });

  final DateTime date;
  final double height;
  final double width;
  final double heightPerMinute;
  final MinuteSlotSize minuteSlotSize;
  final DateTapCallback? onDateTap;
  final DatePressCallback? onDateLongPress;
  final void Function(DateTime dateTime, Offset position) onHover;
  final void Function() onExit;
  final Widget onHoverWidget;
  final int startHour;

  @override
  Widget build(BuildContext context) {
    final heightPerSlot = minuteSlotSize.minutes * heightPerMinute;
    final slots = (Constants.hoursADay * 60) ~/ minuteSlotSize.minutes;

    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: [
          for (int i = 0; i < slots; i++)
            Positioned(
              top: heightPerSlot * i,
              left: 0,
              right: 0,
              bottom: height - (heightPerSlot * (i + 1)),
              child: HoverBuilder(
                builder: (context, isHovered) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPress: () => onDateLongPress?.call(
                      getSlotDateTime(i),
                    ),
                    onTap: () => onDateTap?.call(
                      getSlotDateTime(i),
                    ),
                    child: isHovered
                        ? SizedBox(
                            width: width,
                            height: heightPerSlot,
                            child: onHoverWidget)
                        : SizedBox(
                            width: width,
                            height: heightPerSlot,
                          ),
                  );
                },
                onHover: onHover,
                dateTime: getSlotDateTime(i),
                onExit: onExit,
              ),
            ),
        ],
      ),
    );
  }

  DateTime getSlotDateTime(int slot) => DateTime(
        date.year,
        date.month,
        date.day,
        0,
        (minuteSlotSize.minutes * slot) + (startHour * 60),
      );
}

/// This will be used in day and week view
class DefaultEventTile<T> extends StatelessWidget {
  const DefaultEventTile({
    required this.date,
    required this.events,
    required this.boundary,
    required this.startDuration,
    required this.endDuration,
  });

  final DateTime date;
  final List<CalendarEventData<T>> events;
  final Rect boundary;
  final DateTime startDuration;
  final DateTime endDuration;

  @override
  Widget build(BuildContext context) {
    if (events.isNotEmpty) {
      final event = events[0];
      return RoundedEventTile(
        borderRadius: BorderRadius.circular(10.0),
        title: event.title,
        totalEvents: events.length - 1,
        description: event.description,
        padding: EdgeInsets.all(10.0),
        backgroundColor: event.color,
        margin: EdgeInsets.all(2.0),
        titleStyle: event.titleStyle,
        descriptionStyle: event.descriptionStyle,
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

class HoverBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;
  final void Function(DateTime dateTime, Offset position) onHover;
  final void Function() onExit;
  final DateTime dateTime;

  HoverBuilder({
    required this.builder,
    required this.onHover,
    required this.dateTime,
    required this.onExit,
  });

  @override
  _HoverBuilderState createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _isHovered = false;
  Offset _hoverPosition = Offset.zero;

  void _onEnter(PointerEvent details) {
    setState(() {
      _isHovered = true;

      _hoverPosition = (context.findRenderObject() as RenderBox)
          .globalToLocal(details.position);

      widget.onHover(widget.dateTime, _hoverPosition);
    });
  }

  void _onExit(PointerEvent details) {
    setState(() {
      _isHovered = false;
    });

    widget.onExit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: widget.builder(context, _isHovered),
    );
  }
}
