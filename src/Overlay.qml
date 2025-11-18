import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

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

        width: contentLoader.implicitWidth + 32
        height: contentLoader.implicitHeight + 24

        Loader {
            id: contentLoader
            anchors.centerIn: parent
            sourceComponent: cfg.copyMode ? textEditComponent : textComponent

            property string displayText: (cfg.text && cfg.text.length > 0)
                ? cfg.text
                : "⌨ Keybindings:\n• Super+Enter — Terminal\n• Ctrl+Alt+H — Toggle Overlay"
        }

        Component {
            id: textComponent
            Text {
                renderType: Text.NativeRendering
                text: contentLoader.displayText

                font.pixelSize: (cfg.fontSize > 0 ? cfg.fontSize : 28)
                font.family: (cfg.fontFamily && cfg.fontFamily.length > 0
                    ? cfg.fontFamily
                    : Qt.application.font.family)
                color: (cfg.textColor && cfg.textColor.length > 0 ? cfg.textColor : "white")
                font.bold: cfg.bold
            }
        }

        Component {
            id: textEditComponent
            TextEdit {
                id: textEdit
                readOnly: true
                selectByMouse: true
                selectByKeyboard: true
                persistentSelection: true
                renderType: TextEdit.NativeRendering
                text: contentLoader.displayText

                font.pixelSize: (cfg.fontSize > 0 ? cfg.fontSize : 28)
                font.family: (cfg.fontFamily && cfg.fontFamily.length > 0
                    ? cfg.fontFamily
                    : Qt.application.font.family)
                color: (cfg.textColor && cfg.textColor.length > 0 ? cfg.textColor : "white")
                font.bold: cfg.bold

                // Selection colors
                selectionColor: Qt.rgba(0.3, 0.6, 1.0, 0.5)
                selectedTextColor: "white"

                // Handle Ctrl+A for select all
                Keys.onPressed: function(event) {
                    if ((event.key === Qt.Key_A) && (event.modifiers & Qt.ControlModifier)) {
                        selectAll()
                        event.accepted = true
                    }
                }

                // Signal selection changes
                onSelectedTextChanged: {
                    // Store selection for later copying
                    if (selectedText.length > 0) {
                        root.Window.window.setSelectedText(selectedText)
                    }
                }

                // Listen for clear selection signal from C++
                Connections {
                    target: root.Window.window
                    function onClearSelection() {
                        textEdit.deselect()
                    }
                }
            }
        }
    }
}
