import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Window {
    id: spritesConverter
    width: 500
    height: 500
    transientParent: null
    FileDialog {
        id: fDialogs
        fileMode: FileDialog.OpenFiles
        onAccepted: {
            console.log(currentFiles)
            repeat.model = currentFiles
        }
    }

    FileDialog {
        id: fsDialog
        fileMode: FileDialog.SaveFile
        onAccepted: {
            imageBox.grabToImage(function(im) {
                im.saveToFile(currentFile)
                console.log('success')
            })

        }
    }

    Item {
        anchors.fill: parent
        Row {
            spacing: 10
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                text: 'Open folder'
                onClicked: {
                    fDialogs.open()
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                text: 'Enregister'
                onClicked: {
                    fsDialog.open()
                }
            }
        }

        Rectangle {
            anchors.fill: fli
            anchors.leftMargin: -20
            anchors.rightMargin: 20
            color: 'pink'
            border.color: 'pink'
        }

        Flickable {
            id: fli
            x: 20
            width: parent.width
            height: 256
            contentWidth: imageBox.width
            anchors.verticalCenter: parent.verticalCenter
            clip: true
            Item {
                id: imageBox
                width: rw.width
                height: rw.height
                Row {
                    id: rw
                    Repeater {
                        id: repeat
                        Image {
                            source: modelData
                        }
                    }
                }
            }
        }
    }
}