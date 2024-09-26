import QtQuick 2.15
import QtLocation
import QtPositioning

Item
{
    id:mapwindow

    property double latitude: 34.059174611493965
    property double longitude: -117.82051240067321

    Plugin
    {
        // Define as googlemapview
        id:googlemapview
        name:"osm"
    }
    Map
    {
        // Create actual Map Component
        id:mapview
        anchors.fill: parent
        plugin: googlemapview
        center: QtPositioning.coordinate(latitude,longitude)
        zoomLevel: 18
        // Handles clicking and dragging and zoom
        PinchHandler
        {
            target: null
            grabPermissions: PointerHandler.TakeOverForbidden
            property geoCoordinate startCenteroid
            onActiveChanged:
            {
                if (active)
                    startCenteroid = mapview.toCoordinate(centroid.position, false)
            }
            onScaleChanged: (delta) =>
                            {
                mapview.zoomLevel += Math.log(delta)
                mapview.alignCoordinateToPoint(startCenteroid, centroid.position)
            }
        }

        WheelHandler
        {
            onWheel: function(event)
            {
                const loc = mapview.toCoordinate(point.position)
                mapview.zoomLevel += event.angleDelta.y / 120;
                mapview.alignCoordinateToPoint(loc, point.position)
            }
        }

        DragHandler
        {
            target: null
            grabPermissions: PointerHandler.TakeOverForbidden
            onTranslationChanged: (delta) => { mapview.pan(-delta.x, -delta.y); }
        }
        MapItemView
        {
            // Create list for all pins (Will be used to track drones later with some optimization)
            model: ListModel { id: markersModel }
            delegate: MapQuickItem
            {
                coordinate: QtPositioning.coordinate(latitude, longitude)
                anchorPoint.x: markerImage.width / 2
                anchorPoint.y: markerImage.height
                sourceItem: Image {
                    id: markerImage
                    source: "qrc:/resources/mappin.svg"  // Make sure this path is correct, currently in the CMake as this path
                    width: 20
                    height: 40
                }
            }
        }
    }

    function setCenterPosition(lati, longi)
    {
        mapview.center = QtPositioning.coordinate(lati, longi)
        latitude = lati
        longitude = longi
    }

    function setLocationMarking(lati, longi)
    {
        // Adds pin to our pin list
        markersModel.append({"latitude": lati, "longitude": longi})
    }
}
