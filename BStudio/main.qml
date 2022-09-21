import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import BStudio

import SIUtils

ApplicationWindow {
    id: window
    width: 1280
    height: 750
    visible: true
    title: qsTr("Bama Studio")
    property string projectName: ""
    property bool projectFileExist: false
    property string projectPath: ""
    property string projectData: ""
    property bool projectUpdated: false
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

    function saveProject() {
        let data = []
        let projectData = {name: window.projectName}
        for(let i = 0; i < spriteModel.count; i++) {
            let elem = spriteModel.get(i)
            data.push(elem)
        }
        projectData['spriteSequences'] = data
        window.projectData = JSON.stringify(projectData)
        if(window.projectFileExist) {
            SIUtils.writeText(window.projectPath, window.projectData)
        } else {
            saveDialog.open()
        }
    }

    function saveAsProject() {
        let data = []
        let projectData = {name: window.projectName}
        for(let i = 0; i < spriteModel.count; i++) {
            let elem = spriteModel.get(i)
            data.push(elem)
        }
        projectData['spriteSequences'] = data
        window.projectData = JSON.stringify(projectData)
        saveDialog.open()
    }

    function openProject(currentFile) {
        let data = SIUtils.readText(currentFile.toString().replace("file://",""))
        let datas = JSON.parse(data)
        console.log(data)
        window.projectName = datas['name']
        spriteModel.clear()
        for(let i = 0; i < datas['spriteSequences'].length; i++) {
            spriteModel.append(datas['spriteSequences'][i])
        }
        stackView.push(sViewer)
        window.news()
        window.projectFileExist = true
        window.projectPath = currentFile.toString().replace("file://","")
    }

    FileDialog {
        id: saveDialog
        fileMode: FileDialog.SaveFile
        nameFilters: ["Project files (*.bsp)"]
        defaultSuffix: 'bsp'
        acceptLabel: "Enregistrer"
        onAccepted: {
            SIUtils.writeText(currentFile.toString().replace("file://",""), window.projectData)
            window.projectPath = currentFile.toString().replace("file://","")
            window.projectFileExist = true
            console.log("saved")
        }
    }

    FileDialog {
        id: openDialog
        fileMode: FileDialog.OpenFile
        nameFilters: ["Project files (*.bsp)"]
        defaultSuffix: 'bsp'
        acceptLabel: "Ouvrir"
        onAccepted: openProject(currentFile)
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
                onTriggered: openDialog.open()
            }
            Action {
                text: qsTr("&Enregistrer")
                onTriggered: window.saveProject()
            }
            Action {
                text: qsTr("Enregistrer sous...")
                onTriggered: window.saveAsProject()
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
                    window.projectName = p_name.text.replace(" ", "-")
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

                    delegate: Column {
                        width: spriterListView.width
                        ItemDelegate {
                            spacing: 1
                            text: name + (spriterListView.currentIndex === index ? " (selected)" : "")
                            width: spriterListView.width
                            onClicked: spriterListView.currentIndex = index
                            background: Rectangle {
                                color: "#ccc"
                            }
                        }
                        Repeater {
                            model: spriteModel.get(spriterListView.currentIndex).sprites
                            ItemDelegate {
                                text: name
                                x: 20
                                width: spriterListView.width - 20
                                onClicked: sprite.jumpTo(name)
                                background: Rectangle {
                                    color: hovered ? "#ccc" : "#dbdbdb"
                                }

                                HoverHandler {
                                    cursorShape: "PointingHandCursor"
                                }
                            }
                        }
                    }

                    footer: Item {
                        width: spriterListView.width
                        height: 40
                        Button {
                            text: 'Add'
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            onClicked: {
                                new_sprite_dialog.spriterListView = spriterListView
                                new_sprite_dialog.open()
                            }
                        }
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
