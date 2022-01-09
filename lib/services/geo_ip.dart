import 'dart:convert';
import 'package:http/http.dart';

// Copyright (c) 2019, Mad About Brighton. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This class is used to store the response when requesting geo IP information.
class GeoIP {
  String ip;
  String organization;
  String city;
  String region;
  String dma_code;
  String area_code;
  String timezone;
  int offset;
  double longitude;
  String country_code3;
  String postal_code;
  String continent_code;
  String country;
  String region_code;
  String country_code;
  double latitude;

  GeoIP({
    this.ip,
    this.organization,
    this.city,
    this.region,
    this.dma_code,
    this.area_code,
    this.timezone,
    this.offset,
    this.longitude,
    this.country_code3,
    this.postal_code,
    this.continent_code,
    this.country,
    this.region_code,
    this.country_code,
    this.latitude,
  });

  static GeoIP fromJson(Map<String, dynamic> map) {
    return GeoIP(
      ip: map['ip'],
      organization: map['organization'],
      city: map['city'],
      region: map['region'],
      dma_code: map['dma_code'],
      area_code: map['area_code'],
      timezone: map['timezone'],
      offset: _toInt(map['offset']),
      longitude: _toDouble(map['longitude']),
      country_code3: map['country_code3'],
      postal_code: map['postal_code'],
      continent_code: map['continent_code'],
      country: map['country'],
      region_code: map['region_code'],
      country_code: map['country_code'],
      latitude: _toDouble(map['latitude']),
    );
  }

  @override
  String toString() {
    return 'GeoIP {ip: $ip, organization: $organization, city: $city, region: $region, dma_code: $dma_code, area_code: $area_code, timezone: $timezone, offset: $offset, longitude: $longitude, country_code3: $country_code3, postal_code: $postal_code, continent_code: $continent_code, country: $country, region_code: $region_code, country_code: $country_code, latitude: $latitude}';
  }

  /// Convert [value] to an [int].
  static int _toInt(var value) {
    // Convert a [String], for example "123", to an int
    if (value is String) {
      value = int.tryParse(value) ?? 0;
    }

    // Convert an [double], for example 5.5, to an int
    if (value is double) {
      value = int.tryParse(value.toString()) ?? 0;
    }

    return value;
  }

  /// Convert [value] to a [double].
  static double _toDouble(var value) {
    // Convert a [String], for example "3.7", to a [double]
    if (value is String) {
      value = double.parse(value);
    }

    // Convert an [int], for example 5, to a [double]
    if (value is int) {
      // dividing 2 integers creates a [double]
      value = value / 1;
    }

    return value;
  }
}

/// This class is used to interact with the SeeIP.
class SeeipClient {
  final Client _client;

  /// Constructor that allows correct http client to be injected. This will
  /// allow us to provide a BrowserClient on the Web, and IOClient for Flutter,
  /// and a MockClient for testing.
  ///
  /// If no [client] is provided, one is created under the hood.
  SeeipClient({Client client}) : _client = client ?? Client();

  /// Obtains IP address plus additional details, such as location and organisation.
  ///
  /// The returned data will relate to [ip].
  /// If [ip] is ommitted, the data will relate to the requesting device's ip address.
  Future<GeoIP> getGeoIP([String ip]) async {
    var segments = ['geoip'];
    if (ip != null) segments.add(ip);

    final uri = _buildUri('ip', segments);

    var response = await _getWithResilience(uri);
    var map = json.decode(response.body);
    var geoip = GeoIP.fromJson(map);
    return geoip;
  }

  /// Constructs a well formatted URL.
  Uri _buildUri([String subdomain, List<String> segments]) {
    var uri = Uri(
        scheme: 'https', host: '$subdomain.seeip.org', pathSegments: segments);
    print(uri);
    return uri;
  }

  /// Get [reponse] for given [uri].
  ///
  /// Retires if server is busy, rather than crashing out.
  Future<Response> _getWithResilience(Uri uri) async {
    var response = await _client.get(uri);

    switch (response.statusCode) {
      // Too many requests
      case 429:
        var retryAfter = int.parse(response.headers['retry-after']);
        await Future.delayed(Duration(seconds: retryAfter));
        return await _getWithResilience(uri);

      // OK
      case 200:
        return response;

      default:
        throw Exception('Request status not successful for $uri');
    }
  }
}
