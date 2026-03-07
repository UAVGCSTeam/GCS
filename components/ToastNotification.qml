import QtQuick 2.15

Rectangle {
    id: toastNotification
    width: toastText.implicitWidth + 32
    height: 40
    radius: 8
    color: toastSuccess ? "#2e7d32" : "#c62828"
    opacity: 0
    z: 999

    property bool toastSuccess: true

    function show(message, success) {
        toastText.text = message
        toastSuccess = success
        opacity = 1
        toastTimer.restart()
    }

    Behavior on opacity {
        NumberAnimation { duration: 300 }
    }

    Timer {
        id: toastTimer
        interval: 3000
        onTriggered: toastNotification.opacity = 0
    }

    Text {
        id: toastText
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: 13
        font.bold: true
    }
}
