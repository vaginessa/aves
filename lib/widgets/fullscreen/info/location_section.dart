import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/utils/android_app_service.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSection extends AnimatedWidget {
  final ImageEntry entry;
  final showTitle;

  LocationSection({
    Key key,
    @required this.entry,
    @required this.showTitle,
  }) : super(key: key, listenable: Listenable.merge([entry.metadataChangeNotifier, entry.addressChangeNotifier]));

  @override
  Widget build(BuildContext context) {
    return !entry.hasGps
        ? SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTitle)
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: SectionRow('Location'),
                ),
              ImageMap(
                markerId: entry.path,
                latLng: LatLng(
                  entry.latLng.item1,
                  entry.latLng.item2,
                ),
                geoUri: entry.geoUri,
                initialZoom: settings.infoMapZoom,
              ),
              if (entry.isLocated)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: InfoRow('Address', entry.addressDetails.addressLine),
                ),
            ],
          );
  }
}

class ImageMap extends StatefulWidget {
  final String markerId;
  final LatLng latLng;
  final String geoUri;
  final double initialZoom;

  const ImageMap({
    Key key,
    this.markerId,
    this.latLng,
    this.geoUri,
    this.initialZoom,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ImageMapState();
}

class ImageMapState extends State<ImageMap> with AutomaticKeepAliveClientMixin {
  GoogleMapController controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final accentHue = HSVColor.fromColor(Theme.of(context).accentColor).hue;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.latLng,
                  zoom: widget.initialZoom,
                ),
                onMapCreated: (controller) => setState(() => this.controller = controller),
                rotateGesturesEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                tiltGesturesEnabled: false,
                myLocationButtonEnabled: false,
                markers: [
                  Marker(
                    markerId: MarkerId(widget.markerId),
                    icon: BitmapDescriptor.defaultMarkerWithHue(accentHue),
                    position: widget.latLng,
                  )
                ].toSet(),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        Column(children: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: controller == null ? null : () => zoomBy(1),
            tooltip: 'Zoom in',
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: controller == null ? null : () => zoomBy(-1),
            tooltip: 'Zoom out',
          ),
          IconButton(
            icon: Icon(Icons.open_in_new),
            onPressed: () => AndroidAppService.openMap(widget.geoUri),
            tooltip: 'Show on map...',
          ),
        ])
      ],
    );
  }

  zoomBy(double amount) {
    settings.infoMapZoom += amount;
    controller.animateCamera(CameraUpdate.zoomBy(amount));
  }

  @override
  bool get wantKeepAlive => true;
}