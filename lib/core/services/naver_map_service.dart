class NaverMapService {
  static String generateMapHtml({String clientId = '1u7j3pzwnv'}) {
    return '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Naver Map</title>
    <script src="https://oapi.map.naver.com/openapi/v3/maps.js?ncpClientId=$clientId"></script>
    <style>
      html, body, #map {
        width: 100%;
        height: 100%;
        margin: 0;
        padding: 0;
      }
    </style>
  </head>
  <body>
    <div id="map"></div>
    <script>
      var map = new naver.maps.Map('map', {
        center: new naver.maps.LatLng(37.5665, 126.9780),
        zoom: 13
      });
    </script>
  </body>
</html>
''';
  }
}
