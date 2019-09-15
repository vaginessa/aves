import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/fullscreen/info/basic_section.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:aves/widgets/fullscreen/info/metadata_section.dart';
import 'package:aves/widgets/fullscreen/info/xmp_section.dart';
import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  final ImageCollection collection;
  final ImageEntry entry;

  const InfoPage({
    Key key,
    @required this.collection,
    @required this.entry,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => InfoPageState();
}

class InfoPageState extends State<InfoPage> {
  bool _scrollStartFromTop = false;

  ImageEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    entry.locate();
  }

  @override
  Widget build(BuildContext context) {
    // use MediaQuery instead of unreliable OrientationBuilder
    final orientation = MediaQuery.of(context).orientation;
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_upward),
          onPressed: () => BackUpNotification().dispatch(context),
          tooltip: 'Back to image',
        ),
        title: Text('Info'),
      ),
      body: SafeArea(
        child: NotificationListener(
          onNotification: _handleTopScroll,
          child: ListView(
            padding: EdgeInsets.all(8.0) + EdgeInsets.only(bottom: bottomInsets),
            children: [
              if (orientation == Orientation.landscape && entry.hasGps)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: BasicSection(entry: entry)),
                    SizedBox(width: 8),
                    Expanded(child: LocationSection(entry: entry, showTitle: false)),
                  ],
                )
              else ...[
                BasicSection(entry: entry),
                LocationSection(entry: entry, showTitle: true),
              ],
              XmpTagSection(collection: widget.collection, entry: entry),
              MetadataSection(entry: entry),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  bool _handleTopScroll(Notification notification) {
    if (notification is ScrollNotification) {
      if (notification is ScrollStartNotification) {
        final metrics = notification.metrics;
        _scrollStartFromTop = metrics.pixels == metrics.minScrollExtent;
      }
      if (_scrollStartFromTop) {
        if (notification is ScrollEndNotification) {
          _scrollStartFromTop = false;
        } else if (notification is OverscrollNotification) {
          if (notification.overscroll < 0) {
            BackUpNotification().dispatch(context);
            _scrollStartFromTop = false;
          }
        }
      }
    }
    return false;
  }
}

class SectionRow extends StatelessWidget {
  final String title;

  const SectionRow(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white70)),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Concourse Caps',
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white70)),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label, value;

  const InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontFamily: 'Concourse'),
          children: [
            TextSpan(text: '$label    ', style: TextStyle(color: Colors.white70)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class BackUpNotification extends Notification {}