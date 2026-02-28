import QtQuick 2.15
import QtLocation

Item {
    id: waypointRoot

    property var mapview
    property var activeDrone: null

    // Signal to update the waypoint list in the UI
    signal waypointsUpdated(string droneName)

    // Delegates to MissionManager. drone position auto-inserted in C++ for new missions
    function addWaypoint(drone, clickLat, clickLon) {
        if (!drone) return
        missionManager.addWaypoint(drone, clickLat, clickLon)
    }

    // Haversine formula for distance between two geo coordinates
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
        var wps = missionManager.getWaypoints(drone.xbeeAddress)
        if (!wps || wps.length < 2) return

        var target = wps[1]

        if (distanceMeters(
                target.lat,
                target.lon,
                drone.latitude,
                drone.longitude
            ) < 2.0) {

            missionManager.pruneFirstWaypoint(drone.xbeeAddress)
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

            // Draw waypoint paths for every active mission, red for the selected drone
            var droneIDs = missionManager.getMissionDroneIDs()
            for (var i = 0; i < droneIDs.length; i++) {
                var droneID = droneIDs[i]
                var wps = missionManager.getWaypoints(droneID)
                if (!wps || wps.length < 2) continue

                var isSelected = (activeDrone ? droneID === activeDrone.xbeeAddress : false)
                ctx.strokeStyle = isSelected ? "red" : "#888"
                ctx.fillStyle   = isSelected ? "red" : "#888"

                ctx.lineWidth = 2
                ctx.setLineDash([4, 4])
                ctx.beginPath()

                var start = geoToPixel(wps[0].lat, wps[0].lon)
                ctx.moveTo(start.x, start.y)

                for (var j = 1; j < wps.length; j++) {
                    var p = geoToPixel(wps[j].lat, wps[j].lon)
                    ctx.lineTo(p.x, p.y)
                }

                ctx.stroke()
                ctx.setLineDash([])

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
            target: missionManager
            function onWaypointsChanged() { waypointCanvas.requestPaint() }
        }
    }

    Connections {
        target: droneController
        function onDroneStateChanged(drone) {
            if (!drone) return
            pruneFirstWaypoint(drone)
            waypointCanvas.requestPaint()
        }
    }

    // When MissionManager modifies waypoints, forward them to DroneController
    // (which needs the drone name, not xbeeAddress) and re-signal to QML listeners
    Connections {
        target: missionManager
        function onWaypointsChanged(uavID) {
            var droneName = missionManager.getDroneNameForMission(uavID)
            waypointsUpdated(droneName)
            var wps = missionManager.getWaypoints(uavID)
            droneController.updateWaypoints(droneName, wps)
        }
    }
}