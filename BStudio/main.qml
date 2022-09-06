import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import BStudio

ApplicationWindow {
    id: window
    width: 1280
    height: 500
    visible: true
    title: qsTr("Bama Studio")
    signal news()

    component TextInputField: TextField {
        text: ""
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        font.pixelSize: 18
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        selectByMouse: true
        background: Rectangle {
            color: "#ccc"
            border.color: 'white'
            radius: 8
        }
    }

    Component {
        id: spriteComponent
        Sprite {

        }
    }

    function createObject(component, parent,sub={}) {
        var sprite = component.createObject(parent,sub);
        return sprite;
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("&Fichier")
            Action {
                text: qsTr("&Nouveau...")
                onTriggered: newDialog.open()//stackView.push(sViewer)
            }
            Action {
                text: qsTr("&Ouvrir...")
            }
            Action {
                text: qsTr("&Enregistrer")
            }
            Action {
                text: qsTr("Enregistrer sous...")
            }
            MenuSeparator {}
            Action {
                text: qsTr("&Quitter")
            }
        }
        Menu {
            title: qsTr("&Outils")
            Action {
                text: qsTr("&SpriterConverter")
                onTriggered: spritesConverter.show()
            }
        }
        Menu {
            title: qsTr("&Help")
            Action {
                text: qsTr("&About")
            }
        }
    }
    background: Rectangle {
        color: "#ccc"
    }

    ListModel {
        id: spriteModel
    }

    property string currentSprite: ""

    SpriteGenerator {
        id: spritesConverter
    }

    Popup {
        id: newDialog
        anchors.centerIn: parent
        width: 450
        height: 480
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            Text { text: 'Nom du project' }
            TextInputField {
                id: p_name
                text: ""
                placeholderText: "Nom du project"
            }
            Text { text: 'Width' }
            TextInputField {
                id: p_width
                text: "0"
                placeholderText: "width"
            }
            Text { text: 'Height' }
            TextInputField {
                id: p_height
                text: "0"
                placeholderText: "height"
            }
            Text { text: 'FrameWidth' }
            TextInputField {
                id: p_frameWidth
                text: "0"
                placeholderText: "frameWidth"
            }
            Text { text: 'FrameHeight' }
            TextInputField {
                id: p_frameHeight
                text: "0"
                placeholderText: "frameHeight"
            }
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                text: 'Créer'
                onClicked: {
                    let data = {
                        name: p_name.text,
                        width: parseFloat(p_width.text),
                        height: parseFloat(p_height.text),
                        frameWidth: parseFloat(p_frameWidth.text),
                        frameHeight: parseFloat(p_frameHeight.text),
                        sprites: []
                    }
                    spriteModel.append(data)
                    newDialog.close()
                    stackView.push(sViewer)
                }
            }
        }
    }

    FileDialog {
        id: fDialog
        onAccepted: {
            window.currentSprite = currentFile
            stackView.pop()
            stackView.push(sViewer)
        }
    }

    Text {
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        text: 'Pas de project<br>ouvert'
        font.pixelSize: 21
        font.weight: Font.Medium
        opacity: .2
    }
    Popup {
        id: new_sprite_dialog
        property var spriterListView
        anchors.centerIn: parent
        width: 450
        height: 700
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            Text { text: 'Nom du sprite' }
            TextInputField {
                id: s_name
                text: ""
                placeholderText: "sprite"
            }
            Text { text: 'FrameWidth' }
            TextInputField {
                id: s_frameWidth
                text: "0"
                placeholderText: "frameWidth"
            }
            Text { text: 'FrameHeight' }
            TextInputField {
                id: s_frameHeight
                text: "0"
                placeholderText: "frameHeight"
            }
            Text { text: 'frameCount' }
            TextInputField {
                id: s_frameCount
                text: "10"
                placeholderText: "frameCount"
            }
            Text { text: 'FrameDuration' }
            TextInputField {
                id: s_frameDuration
                text: "60"
                placeholderText: "frameDuration"
            }
            Text { text: 'Source' }
            TextInputField {
                id: s_source
                text: ""
                readOnly: true
                padding: 10
                placeholderText: "source"

                FileDialog {
                    id: openFn
                    onAccepted: {
                        s_source.text = openFn.currentFile
                    }
                }

                Button {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    text: 'Parcourir'
                    onClicked:  {
                        openFn.open()
                    }
                }
            }
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                text: 'Créer'
                onClicked: {
                    let data = {
                        name: s_name.text,
                        duration: parseInt(s_frameDuration.text),
                        frameCount: parseInt(s_frameCount.text),
                        frameHeight: parseInt(s_frameHeight.text),
                        frameWidth: parseInt(s_frameWidth.text),
                        source: s_source.text
                    }
                    let cs = spriteModel.get(new_sprite_dialog.spriterListView.currentIndex)
                    let lt = cs.sprites
                    lt.append(data)
                    cs.sprites = lt
                    window.news()
                    new_sprite_dialog.close()
                }
            }
        }
    }
    Component {
        id: sViewer
        SplitView {
            Rectangle {
                SplitView.fillHeight: true
                SplitView.preferredWidth: 200
                ListView {
                    id: spriterListView
                    anchors.fill: parent
                    model: spriteModel
                    onCurrentIndexChanged: {
                        console.log(currentIndex)
                    }

                    delegate: ItemDelegate {
                        text: name + (spriterListView.currentIndex === index ? " (selected)" : "")
                        width: spriterListView.width
                        onClicked: spriterListView.currentIndex = index
                    }
                }
            }
            SplitView {
                orientation: Qt.Vertical
                SplitView.fillHeight: true
                SplitView.fillWidth: true
                Rectangle {
                    SplitView.fillHeight: true
                    SplitView.fillWidth: true
                    color: '#ccc'
                    SpriteSequence {
                        id: sprite
                        property var spriteSt: []
                        anchors.centerIn: parent
                        width: 256
                        height: 256
                        running: false


                    }
                    Connections {
                        target: window
                        function onNews() {
                            sprite.spriteSt = []
                            let sp = spriteModel.get(spriterListView.currentIndex).sprites
                            for(let i =0; i< sp.count; i++) {
                                let item = sp.get(i)
                                sprite.spriteSt.push(item.name)
                                let sc = window.createObject(spriteComponent, sprite, JSON.parse(JSON.stringify(item)))
                                sprite.sprites.push(sc)
                            }
                        }
                    }
                }

                Rectangle {
                    SplitView.preferredHeight: 60
                    SplitView.fillWidth: true

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 10
                        spacing: 10
                        Repeater {
                            model: spriteModel.get(spriterListView.currentIndex).sprites
                            Button {
                                text: name
                                onClicked: sprite.jumpTo(name)
                            }
                        }
                    }

                    Button {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        text: 'Add'
                        onClicked: {
                            new_sprite_dialog.spriterListView = spriterListView
                            new_sprite_dialog.open()
                        }
                    }
                }

            }


            Rectangle {
                SplitView.fillHeight: true
                SplitView.preferredWidth: 200
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 10


                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        text: sprite.running ? 'Pause' : 'Play'
                        onClicked: sprite.running = !sprite.running
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    StackLayout {
        id: stack
        anchors.fill: parent
        RowLayout {
            StackView {
                id: stackView
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }
}
