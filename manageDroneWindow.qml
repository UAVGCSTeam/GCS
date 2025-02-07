import QtQuick 2.15
import QtQuick.Window 2.15
import "coordinates.js" as Coordinates
import QtQuick.Controls
import Qt.labs.platform

// This is the ui/qml file that corresponds to the manage drone window popout.
// This will allow one to add and delete drones from the database and what the application will process

Window {
    width: 300
    height: 200
    title: qsTr("Manage Drones")
}
