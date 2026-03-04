import QtQuick 2.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

/*
 * StyledComboBox - Reusable styled dropdown component
 * Use for settings/form inputs where user selects one value from a list.
 * Automatically styled to match GcsStyle theme.
 *
 * Usage:
 *   StyledComboBox {
 *       model: myListModel
 *       textRole: "label"
 *       onActivated: myProperty = model.get(currentIndex).value
 *   }
 */

ComboBox {
    id: control

    background: Rectangle {
        color: GcsStyle.PanelStyle.secondaryColor
        border.color: GcsStyle.PanelStyle.defaultBorderColor
        border.width: 1
        radius: GcsStyle.PanelStyle.buttonRadius
    }

    contentItem: Text {
        text: control.displayText
        color: GcsStyle.PanelStyle.textPrimaryColor
        font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
        font.family: GcsStyle.PanelStyle.fontFamily
        verticalAlignment: Text.AlignVCenter
        leftPadding: 10
    }

    indicator: Text {
        text: "▼"
        color: GcsStyle.PanelStyle.textPrimaryColor
        font.pixelSize: 8
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    popup: Popup {
        y: control.height
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            color: GcsStyle.PanelStyle.secondaryColor
            border.color: GcsStyle.PanelStyle.defaultBorderColor
            radius: GcsStyle.PanelStyle.buttonRadius
        }
    }

    delegate: ItemDelegate {
        width: control.width
        height: 32

        contentItem: Text {
            text: model[control.textRole]
            color: GcsStyle.PanelStyle.textPrimaryColor
            font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
            font.family: GcsStyle.PanelStyle.fontFamily
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: highlighted
                ? GcsStyle.PanelStyle.listItemHoverColor
                : GcsStyle.PanelStyle.secondaryColor
        }

        highlighted: control.highlightedIndex === index
    }
}
