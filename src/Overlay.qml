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

        // Normal read-only text display
        Text {
            id: content
            visible: !copyMode
            anchors.centerIn: parent
            renderType: Text.NativeRendering

            text: (cfg.text && cfg.text.length > 0)
                ? cfg.text
                : "⌨ Keybindings:\n• Super+Enter — Terminal\n• Ctrl+Alt+H — Toggle Overlay"

            font.pixelSize: (cfg.fontSize > 0 ? cfg.fontSize : 28)
            font.family: (cfg.fontFamily && cfg.fontFamily.length > 0
                ? cfg.fontFamily
                : Qt.application.font.family)
            color: (cfg.textColor && cfg.textColor.length > 0 ? cfg.textColor : "white")
            font.bold: cfg.bold
        }

        // Interactive text edit for copy mode
        TextEdit {
            id: copyContent
            visible: copyMode
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

            // Enable focus to receive keyboard events when visible
            onVisibleChanged: {
                if (visible) {
                    forceActiveFocus();
                }
            }

            // Function to clear selection, callable from C++
            function clearSelection() {
                deselect();
            }

            // Store reference in overlayView
            Component.onCompleted: {
                if (overlayView) {
                    overlayView.setTextEdit(copyContent);
                }
            }
        }
    }
}
