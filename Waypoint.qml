import QtQuick 2.15
import QtLocation

Item {
    id: waypointRoot

    // Map reference, injected from parent
    property var mapview
    property var activeDroneName: null

    // Shared storage for all drones
    property var droneWaypoints: ({})   // { droneName: [ {lat, lon}, ... ] }

    // Expose a signal so other UI parts can refresh
    signal waypointsUpdated(string droneName)

    // Add one waypoint for a drone
    function addWaypoint(droneName, droneLat, droneLon, clickLat, clickLon) {
        if (!droneWaypoints[droneName])
            droneWaypoints[droneName] = []

        // First waypoint: insert drone position
        if (droneWaypoints[droneName].length === 0) {
            droneWaypoints[droneName].push({
                lat: droneLat,
                lon: droneLon
            })
        }

        // Add clicked waypoint
        droneWaypoints[droneName].push({
            lat: clickLat,
            lon: clickLon
        })

        waypointsUpdated(droneName)
    }

    // Distance in meters between two coordinates
    function distanceMeters(lat1, lon1, lat2, lon2) {
        var R = 6371000; // earth radius in meters
        var radLat1 = lat1 * Math.PI / 180
        var radLat2 = lat2 * Math.PI / 180
        var deltaLat = (lat2 - lat1) * Math.PI / 180
        var deltaLon = (lon2 - lon1) * Math.PI / 180

        var a = Math.sin(deltaLat/2) * Math.sin(deltaLat/2) +
                Math.cos(radLat1) * Math.cos(radLat2) *
                Math.sin(deltaLon/2) * Math.sin(deltaLon/2)
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
        return R * c
    }

    // Remove first waypoint if drone is close enough
    function pruneFirstWaypoint(drone) {
        var wps = droneWaypoints[drone.name]
        if (!wps || wps.length < 2) return

        var firstWp = wps[1]
        var droneLat = drone.latitude
        var droneLon = drone.longitude

        if (distanceMeters(firstWp.lat, firstWp.lon, droneLat, droneLon) < 2.0) { // 2 meter threshold
            wps.shift()
            waypointsUpdated(drone.name)
        }
    }

    Canvas {
        id: waypointCanvas
        anchors.fill: parent
        z: 15

        onPaint: {
            if (!mapview) return

            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            function geoToPixel(lat, lon) {
                var mapWidth = 256 * Math.pow(2, mapview.zoomLevel);

                var x = (lon + 180) / 360 * mapWidth
                var sinLat = Math.sin(lat * Math.PI / 180)
                var y = (0.5 - Math.log((1 + sinLat) / (1 - sinLat)) / (4 * Math.PI)) * mapWidth

                var centerX = (mapview.center.longitude + 180) / 360 * mapWidth
                var sinCenterLat = Math.sin(mapview.center.latitude * Math.PI / 180)
                var centerY = (0.5 - Math.log((1 + sinCenterLat) / (1 - sinCenterLat)) / (4 * Math.PI)) * mapWidth

                return { x: width/2 + (x - centerX), y: height/2 + (y - centerY) }
            }

            for (var droneName in droneWaypoints) {
                var wps = droneWaypoints[droneName]
                if (!wps || wps.length < 2) continue

                var isSelected = (droneName === activeDroneName)
                ctx.strokeStyle = isSelected ? "red" : "#888"
                ctx.fillStyle   = isSelected ? "red" : "#888"

                ctx.lineWidth = 2
                ctx.setLineDash([4, 4])
                ctx.beginPath()

                var start = geoToPixel(wps[0].lat, wps[0].lon)
                ctx.moveTo(start.x, start.y)

                for (var i = 1; i < wps.length; i++) {
                    var p = geoToPixel(wps[i].lat, wps[i].lon)
                    ctx.lineTo(p.x, p.y)
                }

                ctx.stroke()
                ctx.setLineDash([])

                // Draw waypoint dots
                for (var t = 0; t < wps.length; t++) {
                    var s = geoToPixel(wps[t].lat, wps[t].lon)
                    ctx.beginPath()
                    ctx.arc(s.x, s.y, 6, 0, 2 * Math.PI)
                    ctx.fill()
                }
            }
        }

        Connections {
            target: mapview
            function onCenterChanged()      { waypointCanvas.requestPaint() }
            function onZoomLevelChanged()   { waypointCanvas.requestPaint() }
        }

        Connections {
            target: waypointRoot
            function onWaypointsUpdated() { waypointCanvas.requestPaint() }
        }
    }
    Connections {
        target: telemetryPanel
        function onActiveDroneChanged() {
            waypointRoot.activeDroneName = telemetryPanel.activeDrone ? telemetryPanel.activeDrone.name : null
            waypointCanvas.requestPaint()
        }
    }
    Connections {
        target: droneController
        function onDroneStateChanged(droneName) {
            var drone = droneController.getDrone(droneName)
            if (drone) {
                pruneFirstWaypoint(drone)
                waypointCanvas.requestPaint()
            }
        }
    }

    Connections {
        target: waypointRoot
        function onWaypointsUpdated(droneName) {
            var wps = waypointRoot.droneWaypoints[droneName];
            droneController.updateWaypoints(droneName, wps);
        }
    }
}
