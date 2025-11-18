import QtQuick 2.15

Rectangle {
    id: root
    width: panel.width
    height: panel.height
    color: "transparent"

    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 0
        radius: 12
        color: Qt.rgba(0, 0, 0, cfg.panelOpacity)

        width: content.implicitWidth + 32
        height: content.implicitHeight + 24

        TextEdit {
            id: content
            anchors.centerIn: parent
            renderType: Text.NativeRendering
            readOnly: true
            selectByMouse: true
            selectByKeyboard: true
            persistentSelection: true

            text: (cfg.text && cfg.text.length > 0)
                ? cfg.text
                : "⌨ Keybindings:\n• Super+Enter — Terminal\n• Ctrl+Alt+H — Toggle Overlay"

            font.pixelSize: (cfg.fontSize > 0 ? cfg.fontSize : 28)
            font.family: (cfg.fontFamily && cfg.fontFamily.length > 0
                ? cfg.fontFamily
                : Qt.application.font.family)
            color: (cfg.textColor && cfg.textColor.length > 0 ? cfg.textColor : "white")
            font.bold: cfg.bold

            // Handle selection changes
            onSelectedTextChanged: {
                if (overlayView && selectedText.length > 0) {
                    overlayView.updateSelection(selectedText);
                }
            }

            // Support Ctrl+A to select all
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_A && (event.modifiers & Qt.ControlModifier)) {
                    selectAll();
                    event.accepted = true;
                }
            }

            // Enable focus to receive keyboard events
            Component.onCompleted: {
                forceActiveFocus();
            }
        }

        // Visual indicator that we're in copy mode
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 8
            width: 12
            height: 12
            radius: 6
            color: "#4CAF50"
            opacity: 0.8

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.3; to: 0.9; duration: 800 }
                NumberAnimation { from: 0.9; to: 0.3; duration: 800 }
            }
        }
    }
}
