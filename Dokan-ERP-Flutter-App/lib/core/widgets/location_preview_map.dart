import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationPreviewMap extends StatelessWidget {
  const LocationPreviewMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 180,
    this.zoom = 15,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  final double latitude;
  final double longitude;
  final double height;
  final int zoom;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned.fill(
              child: _OpenStreetMapTileGrid(
                latitude: latitude,
                longitude: longitude,
                zoom: zoom,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.04),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.08),
                    ],
                  ),
                ),
              ),
            ),
            const Center(
              child: IgnorePointer(
                child: Icon(
                  Icons.location_on_rounded,
                  size: 36,
                  color: Color(0xFFD93025),
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Material(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => _openExternalMap(latitude, longitude),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                          color: Color(0xFF16302E),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Open map',
                          style: TextStyle(
                            color: Color(0xFF16302E),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternalMap(double lat, double lng) async {
    final googleUri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
      return;
    }
    await launchUrl(googleUri, mode: LaunchMode.externalApplication);
  }
}

class _OpenStreetMapTileGrid extends StatelessWidget {
  const _OpenStreetMapTileGrid({
    required this.latitude,
    required this.longitude,
    required this.zoom,
  });

  final double latitude;
  final double longitude;
  final int zoom;

  @override
  Widget build(BuildContext context) {
    final safeLatitude = latitude.clamp(-85.05112878, 85.05112878);
    final scale = math.pow(2, zoom).toDouble();
    final x = (longitude + 180.0) / 360.0 * scale;
    final latRadians = safeLatitude * math.pi / 180.0;
    final y = (1.0 -
            math.log(math.tan(latRadians) + 1 / math.cos(latRadians)) /
                math.pi) /
        2.0 *
        scale;
    final baseX = x.floor();
    final baseY = y.floor();

    return LayoutBuilder(
      builder: (context, constraints) {
        final markerLeft = constraints.maxWidth * ((x - baseX + 1) / 3);
        final markerTop = constraints.maxHeight * ((y - baseY + 1) / 3);

        return Stack(
          children: [
            Column(
              children: List.generate(3, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(3, (column) {
                      final tileX =
                          _wrapTile(baseX + column - 1, scale.toInt());
                      final tileY = _clampTile(baseY + row - 1, scale.toInt());
                      final tileUrl =
                          'https://tile.openstreetmap.org/$zoom/$tileX/$tileY.png';
                      return Expanded(
                        child: Image.network(
                          tileUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const ColoredBox(color: Color(0xFFE9F1EE));
                          },
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              return child;
                            }
                            return const ColoredBox(color: Color(0xFFEFF5F3));
                          },
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
            Positioned(
              left: markerLeft - 14,
              top: markerTop - 28,
              child: const IgnorePointer(
                child: Icon(
                  Icons.location_pin,
                  size: 28,
                  color: Color(0xFFD93025),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int _wrapTile(int value, int scale) {
    final normalized = value % scale;
    return normalized < 0 ? normalized + scale : normalized;
  }

  int _clampTile(int value, int scale) {
    return value.clamp(0, scale - 1);
  }
}
