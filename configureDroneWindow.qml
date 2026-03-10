import QtQuick 2.15
import QtQuick.Window 2.15
import "coordinates.js" as Coordinates
import QtQuick.Controls
import Qt.labs.platform
import com.gcs.filehandler
import "qrc:/gcsStyle" as GcsStyle
import QtQuick.Controls.Basic 2.15

// This is the ui/qml file that corresponds to the configure drone window popout.
// This will allow one to configure drones

Window {
    id: configureDroneWindow
    width: 1050
    height: 600
    title: qsTr("Manage Drones")
}
