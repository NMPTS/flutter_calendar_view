import 'dart:developer';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

import '../pages/event_details_page.dart';

class WeekViewWidget extends StatefulWidget {
  final GlobalKey<WeekViewState>? state;
  final double? width;

  const WeekViewWidget({super.key, this.state, this.width});

  @override
  State<WeekViewWidget> createState() => _WeekViewWidgetState();
}

class _WeekViewWidgetState extends State<WeekViewWidget> {
  OverlayEntry? _overlayEntry;

  void _showContextMenu(DateTime dateTime, Offset position) {
    _overlayEntry = _createOverlayEntry(dateTime, position);
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return WeekView(
      key: widget.state,
      width: widget.width,
      showWeekends: true,
      showLiveTimeLineInAllDays: true,
      eventArranger: SideEventArranger(maxWidth: 30),
      timeLineWidth: 65,
      scrollPhysics: const BouncingScrollPhysics(),
      liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
        color: Colors.redAccent,
        showTime: true,
      ),
      heightPerMinute: 2,
      onTimestampTap: (date) {
        SnackBar snackBar = SnackBar(
          content: Text("On tap: ${date.hour} Hr : ${date.minute} Min"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      onDateTap: (date) {
        SnackBar snackBar = SnackBar(
          content: Text("On tap: ${date.day} ${date.month} ${date.year}"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      onHover: (dateTime, position) {
        log("Hovering on ${dateTime.hour}:${dateTime.minute} at ${position.dx},${position.dy}");
        // create a custom hover widget here

        final RenderBox renderBox = context.findRenderObject() as RenderBox;

        final Offset local = renderBox.globalToLocal(position);

        log("Local position: ${local.dx},${local.dy}");
        _showContextMenu(dateTime, position);
      },
      onHoverWidget: Container(
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
      onEventTap: (events, date) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailsPage(
              event: events.first,
              date: date,
            ),
          ),
        );
      },
      onEventLongTap: (events, date) {
        SnackBar snackBar = SnackBar(content: Text("on LongTap"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
        return Expanded(
            child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              Text("Event at ${date.hour}:${date.minute}"),
              Text(
                  "Event duration: ${startDuration.hour}:${startDuration.minute} - ${endDuration.hour}:${endDuration.minute}"),
            ],
          ),
        ));
      },
    );
  }

  OverlayEntry _createOverlayEntry(DateTime dateTime, Offset position) {
    return OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy,
        child: Material(
          elevation: 4.0,
          child: Container(
            width: 200,
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Event at ${dateTime.hour}:${dateTime.minute}'),
                  onTap: () {
                    // Handle event tap
                    _overlayEntry?.remove();
                  },
                ),
                ListTile(
                  title: Text('Create new event'),
                  onTap: () {
                    // Handle create new event
                    _overlayEntry?.remove();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
