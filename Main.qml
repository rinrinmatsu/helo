import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import SddmComponents 2.0

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    z: 0
    color: "#000000"
    property real uiScale: Math.max(0.75, Math.min(width / 1920, height / 1080))
    property int selectedUserIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property string selectedUserName: {
        var name = userModel.data(userModel.index(selectedUserIndex, 0), 0)
        return name ? name : userModel.lastUser
    }
    property string selectedUserAvatar: {
        var avatar = userModel.data(userModel.index(selectedUserIndex, 0), 0x0107)
        if (avatar && avatar !== "") {
            return avatar
        }
        if (selectedUserName && selectedUserName !== "") {
            return "file:///var/lib/AccountsService/icons/" + selectedUserName
        }
        return ""
    }

    function userCount() {
        return userModel && userModel.hasOwnProperty("count") ? userModel.count : 0
    }

    function selectPrevUser() {
        var count = userCount()
        if (count > 0) {
            selectedUserIndex = (selectedUserIndex - 1 + count) % count
        }
    }

    function selectNextUser() {
        var count = userCount()
        if (count > 0) {
            selectedUserIndex = (selectedUserIndex + 1) % count
        }
    }
    
    FontLoader {
        id: loveLetterTW
        source: "fonts/Lovelt__.ttf"
    }
    property string appFontFamily: loveLetterTW.status === FontLoader.Ready ? loveLetterTW.name : "Monospace"

    FontLoader {
        id: clockFont
        source: "fonts/Beyond Wonderland.ttf"
    }
    property string clockFontFamily: clockFont.status === FontLoader.Ready ? clockFont.name : "Monospace"

    FontLoader {
        id: athensFont
        source: "fonts/athens_free.ttf"
    }
    property string athensFontFamily: athensFont.status === FontLoader.Ready ? athensFont.name : "Monospace"

    // FontLoader {
    //     id: heroinFont
    //     source: "fonts/Got_Heroin.ttf"
    // }
    // property string heroinFontFamily: heroinFont.status === FontLoader.Ready ? heroinFont.name : "Monospace"

    property string configuredBackgroundPath: {
        var path = config.Background || ""
        return path ? ("" + path) : ""
    }
    property string configuredProfilePath: {
                var path = config.ProfileBlank || ""
        return path ? ("" + path) : "" 
    }
    property bool backgroundScrollingEnabled: {
        var value = config.Scrolling
        if (value === undefined || value === null) {
            value = config.scrolling
        }
        if (typeof value === "boolean") {
            return value
        }
        var normalized = ("" + value).toLowerCase()
        return normalized === "true" || normalized === "1" || normalized === "yes" || normalized === "on"
    }
    property int backgroundScrollDurationMs: {
        var value = config.ScrollDuration || config.scroll_duration || 60
        var seconds = Number(value)
        if (isNaN(seconds) || seconds <= 0) {
            return 60000
        }
        return Math.round(seconds * 1000)
    }

    // Background
    Item {
        id: bgViewport
        anchors.fill: parent
        clip: true
        z: 0

        Image {
            z : 1
            id: bg
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            property real tileWidth: Math.max(1, implicitWidth)
            width: root.backgroundScrollingEnabled ? parent.width + tileWidth : parent.width
            x: root.backgroundScrollingEnabled ? bgScrollOffset.offset : 0
            source: root.configuredBackgroundPath !== "" ? root.configuredBackgroundPath : "images/default_white.png"
            fillMode: root.backgroundScrollingEnabled ? Image.Tile : Image.PreserveAspectCrop
            // asynchronous: true
            // cache: true
            visible: false
        }

        MultiEffect {
            source: bg
            anchors.fill: bg
            // blurEnabled: true
            // blur:0.7
            // blurMax: 32

            colorizationColor: Qt.rgba(0 ,0 ,0 , 1.0)
            colorization: 0
        }

        QtObject {
            id: bgScrollOffset
            property real offset: 0
            NumberAnimation on offset {
                running: root.backgroundScrollingEnabled && bg.status === Image.Ready && bg.tileWidth > 1
                from: 0
                to: -bg.tileWidth
                duration: root.backgroundScrollDurationMs
                loops: Animation.Infinite
            }
        }

        Image {
            z: 2
            id: bgOverlay1
            // anchors.fill: parent
            // anchors.centerIn: parent 
            anchors.bottom: parent.bottom
            source: "images/Texturelabs_Grunge_219L.png"
            // fillMode: Image.PreserveAspectFit
            width: parent.width
            height: 3000 * uiScale
            visible: false
            opacity: 1
        }

        MultiEffect {
            source: bgOverlay1
            anchors.fill: bgOverlay1
            // blurEnabled: true
            // blur: 1

            colorizationColor: Qt.rgba(0 ,0 ,0 , 1.0)
            colorization: 1
        }

        Image {
            z: 3
            id: bgOverlay2
            source: "images/flayer1.png"
            height: 700 * uiScale
            width: parent.height * 1.4
            // fillMode: Image.Pad
            anchors {
                bottom: bgViewport.bottom
                left: bgViewport.left
            }
            visible: false
            opacity: 1
        }

        MultiEffect {
            z: 4
            source: bgOverlay2
            anchors.fill: bgOverlay2
            // blurEnabled: true
            // blur: 0.7

            colorizationColor: Qt.rgba(0 ,0 ,0 , 1.0)
            colorization: 0.9
        }


    }

    // //overlays stuff
    // Item {
    //     id: overlaysViewport
    //     anchors.fill : parent
    //     clip: true
    //     z: 1


    // }

    // --- Clock (bottom-left) ---
    Column {
        id: clockColumn
        z: 10
        anchors {
            left: parent.left
            bottom: parent.bottom
            leftMargin: 64 * root.uiScale
            bottomMargin: 64 * root.uiScale
        }
        spacing: 4 * root.uiScale

        Text {
            id: clockText
            z: 11
            font.family: root.clockFontFamily
            font.pixelSize: 222 * root.uiScale
            font.weight: Font.Light
            color: Qt.rgba(0.67, 0.04, 0.44, 0.88)
            text: Qt.formatTime(new Date(), "hh:mm")
            visible: false
        }

        Text {
            id: dateTime
            z: 11
            font.family: root.appFontFamily
            font.pixelSize: 35 * root.uiScale
            color: Qt.rgba(0, 1, 0.95, 0.68)
            text: Qt.formatDate(new Date(), "MMMM d, yyyy")
            visible: false
        }

        Text {
            id: dateWeek
            z: 11
            font.family: root.appFontFamily
            font.pixelSize: 25 * root.uiScale
            color: Qt.rgba(0, 0.95, 1, 0.5)
            text: Qt.formatDate(new Date(), "dddd")
            visible: false
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                clockText.text = Qt.formatTime(new Date(), "hh:mm")
            }
        }

        MultiEffect {
            source: clockText
            width: clockText.width
            height: clockText.height
            // anchors.fill: clockText
            
            shadowEnabled: true
            shadowColor: "#aa096f"
            shadowBlur: 1
            shadowOpacity: 1
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 0

            blurEnabled: true
            blur: 0.1
            
            brightness: 0.5
        }

        MultiEffect {
            source: dateTime
            width: dateTime.width
            height: dateTime.height
            // anchors.fill: clockText
            
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0.95, 1)
            shadowBlur: 1
            shadowOpacity: 1
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 0

            blurEnabled: true
            blur: 0.1
            
            brightness: 0.2
        }

        MultiEffect {
            source: dateWeek
            width: dateWeek.width
            height: dateWeek.height
            // anchors.fill: clockText
            
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0.95, 1)
            shadowBlur: 1
            shadowOpacity: 1
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 0

            blurEnabled: true
            blur: 0.1
            
            brightness: 0.2
        }
    }

    // placeholder buttons
    Row{
        z: 15
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 64 * root.uiScale
        }
        spacing: 12 * root.uiScale

        Rectangle {
            z:16
            width: 50 * root.uiScale
            height: 50 * root.uiScale
            color: Qt.rgba(0, 0, 0, 0.35)
            border.color: Qt.rgba(1, 1, 1, hbmouse.containsMouse ? 1 : 0.12)
            border.width: 1

            MouseArea {
                id: hbmouse
                z: 18
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    sddm.hibernate()
                }

            Text {
                z:17
                text: "HB"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                font.family: root.appFontFamily
                font.pixelSize: 25 * root.uiScale
                font.letterSpacing: 1 * root.uiScale
                color: '#3a86d3'
                }
            }
        }

        Rectangle {
            z:16
            width: 50 * root.uiScale
            height: 50 * root.uiScale
            color: Qt.rgba(0, 0, 0, 0.35)
            border.color: Qt.rgba(1, 1, 1, slmouse.containsMouse ? 1 : 0.12)
            border.width: 1

            MouseArea {
                id: slmouse
                z: 18
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    sddm.hibernate()
                }

            Text {
                z:17
                text: "SL"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                font.family: root.appFontFamily
                font.pixelSize: 25 * root.uiScale
                font.letterSpacing: 1 * root.uiScale
                color: '#f8f8f8'
                }
            }
        }

        Rectangle {
            z:16
            width: 50 * root.uiScale
            height: 50 * root.uiScale
            color: Qt.rgba(0, 0, 0, 0.35)
            border.color: Qt.rgba(1, 1, 1, rsmouse.containsMouse ? 1 : 0.12)
            border.width: 1

            MouseArea {
                        id: rsmouse
                        z: 18
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            sddm.reboot()
                        }
            }

            Text {
                z:17
                text: "RS"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                font.family: root.appFontFamily
                font.pixelSize: 25 * root.uiScale
                font.letterSpacing: 1 * root.uiScale
                color: '#3ad372'

            }
        }

        Rectangle {
            z: 16
            width: 50 * root.uiScale
            height: 50 * root.uiScale
            color: Qt.rgba(0, 0, 0, 0.35)
            border.color: Qt.rgba(1, 1, 1, rbmouse.containsMouse ? 1 : 0.12)
            border.width: 1

            MouseArea {
                id: rbmouse
                z: 18
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    sddm.powerOff()
                }
            }

            Text {
                z:17
                text: "RB"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                font.family: root.appFontFamily
                font.pixelSize: 25 * root.uiScale
                font.letterSpacing: 1 * root.uiScale
                color: '#d33a3a'
            }
        }
    }

    // --- Login panel (right side) ---
    Row {
        z: 20
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: 64 * root.uiScale
            bottomMargin: 64 * root.uiScale
        }
        spacing: 0

        // Form panel
        Rectangle {
            z: 20
            width: 280 * root.uiScale
            height: loginColumn.implicitHeight + (56 * root.uiScale)
            color: Qt.rgba(0, 0, 0, 0.61)
            border.color: Qt.rgba(1, 1, 1, 0.12)
            border.width: 1

            Column {
                id: loginColumn
                z: 21
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 28 * root.uiScale
                    rightMargin: 28 * root.uiScale
                }
                spacing: 12 * root.uiScale

                // User field
                Column {
                    z: 22
                    width: parent.width
                    spacing: 5 * root.uiScale

                    Text {
                        z: 23
                        text: "USER"
                        font.family: root.appFontFamily
                        font.pixelSize: 10 * root.uiScale
                        font.letterSpacing: 1 * root.uiScale
                        color: "#8888aa"
                    }

                    Rectangle {
                        z: 24
                        width: parent.width
                        height: 38 * root.uiScale
                        color: Qt.rgba(1, 1, 1, 1)
                        border.color: Qt.rgba(255, 0, 174, 0.4)
                        border.width: 1

                        FocusScope {
                            id: userSelector
                            anchors.fill: parent
                            z: 30
                            activeFocusOnTab: true
                            KeyNavigation.tab: passwordInput
                            Keys.onLeftPressed: root.selectPrevUser()
                            Keys.onRightPressed: root.selectNextUser()

                            Rectangle {
                                id: prevUserButton
                                anchors.left: parent.left
                                width: parent.height
                                height: parent.height
                                color: "transparent"
                                border.width: 0

                                // Text {
                                //     anchors.centerIn: parent
                                //     text: "<"
                                //     font.family: root.appFontFamily
                                //     font.pixelSize: 14 * root.uiScale
                                //     color: "#da09be"
                                // }

                                Image {
                                    
                                    anchors.centerIn: parent
                                    source: "icons/arrow_right.svg"
                                    mirror: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        userSelector.forceActiveFocus()
                                        root.selectPrevUser()
                                    }
                                }
                            }

                            Rectangle {
                                id: nextUserButton
                                anchors.right: parent.right
                                width: parent.height
                                height: parent.height
                                color: "transparent"
                                border.width: 0

                                // Text {
                                //     anchors.centerIn: parent
                                //     text: ">"
                                //     font.family: root.appFontFamily
                                //     font.pixelSize: 14 * root.uiScale
                                //     color: "#da09be"
                                // }

                                Image {
                                    
                                    anchors.centerIn: parent
                                    source: "icons/arrow_right.svg"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        userSelector.forceActiveFocus()
                                        root.selectNextUser()
                                    }
                                }
                            }

                            Text {
                                anchors.left: prevUserButton.right
                                anchors.right: nextUserButton.left
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                text: root.selectedUserName
                                font.family: root.appFontFamily
                                font.pixelSize: 14 * root.uiScale
                                color: "#da09be"
                            }
                        }
                    }
                }

                // Password field
                Column {
                    z: 22
                    width: parent.width
                    spacing: 5 * root.uiScale

                    Text {
                        text: "PASSWORD"
                        font.family: root.appFontFamily
                        font.pixelSize: 10 * root.uiScale
                        font.letterSpacing: 1 * root.uiScale
                        color: "#8888aa"
                        z: 23
                    }

                    Rectangle {
                        z: 23
                        width: parent.width
                        height: 38 * root.uiScale
                        color: Qt.rgba(1, 1, 1, 1)
                        border.color: Qt.rgba(1, 1, 1, passwordInput.activeFocus ? 0.4 : 0.15)
                        border.width: 1

                        TextInput {
                            id: passwordInput
                            z: 24
                            anchors {
                                fill: parent
                                leftMargin: 12 * root.uiScale
                                rightMargin: 12 * root.uiScale
                            }
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: root.appFontFamily
                            font.pixelSize: 14 * root.uiScale
                            color: "#0d9fc4"
                            echoMode: TextInput.Password
                            passwordCharacter: "•"
                            KeyNavigation.backtab: userSelector
                            Keys.onReturnPressed: loginButton.doLogin()
                        }
                    }
                }

                // Login button
                Rectangle {
                    id: loginButton
                    z: 22
                    width: parent.width
                    height: 38 * root.uiScale
                    color: mouseArea.pressed
                        ? Qt.rgba(0, 0, 0, 0.7)
                        : Qt.rgba(0, 0, 0)
                    // border.color: Qt.rgba(0.6, 0.5, 1.0, mouseArea.containsMouse ? 0.7 : 0.4)
                    // border.width: 1

                    function doLogin() {
                        sddm.login(root.selectedUserName, passwordInput.text, sessionCombo.index)
                    }

                    Text {
                        id:loginText
                        z: 23
                        anchors.centerIn: parent
                        text: "Epiphaeia" //Epipháeia
                        font.family: root.clockFontFamily
                        font.pixelSize: 30 * root.uiScale
                        color: mouseArea.containsMouse ? '#d268e2' : '#ffffff'
                        font.letterSpacing: 0.5 * root.uiScale
                        visible: false
                    }

                    MultiEffect {
                        z: 23
                        visible: true
                        source: loginText
                        width: loginText.width
                        height: loginText.height
                        anchors.centerIn: parent                    
                        shadowEnabled: true
                        shadowColor: mouseArea.containsMouse ? '#d268e2' : '#ffffff'
                        shadowBlur: 1
                        shadowOpacity: 1
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 0

                        blurEnabled: true
                        blur: 0.1
                        
                        brightness: 0.2
                    }

                    MouseArea {
                        id: mouseArea
                        z: 24
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: loginButton.doLogin()
                    }
                }

                // Session selector
                Row {
                    z: 22
                    anchors.right : parent.right
                    spacing: 6 * root.uiScale
                    width: parent.width

                    ComboBox {
                        id: sessionCombo
                        z: 23
                        width : parent.width - sessionLabel.implicitWidth - parent.spacing
                        model: sessionModel
                        index: sessionModel.lastIndex
                        font.family: root.appFontFamily
                        font.pixelSize: 11 * root.uiScale
                    }

                    Text {
                        id: sessionLabel
                        z: 23
                        width : implicitWidth
                        text: "Session"
                        font.family: root.appFontFamily
                        font.pixelSize: 11 * root.uiScale
                        color: "#606080"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // Divider
        Rectangle {
            z: 19
            width: 1
            height: 120 * root.uiScale
            color: Qt.rgba(1, 1, 1, 0.1)
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 0
        }

        // User avatar + name
        Column {
            z: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10 * root.uiScale
            leftPadding: 28 * root.uiScale
            rightPadding: 0

            // Avatar
            Rectangle {
                z: 21
                width: loginColumn.implicitHeight + (56 * root.uiScale)
                height: loginColumn.implicitHeight + (56 * root.uiScale)
                color: '#00ffffff'
                border.color: Qt.rgba(0, 0, 0, 0.5)
                border.width: 2
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: userAvatar
                    z: 22
                    anchors.fill: parent
                    anchors.margins: 2 * root.uiScale
                    source: root.selectedUserAvatar !== "" ? root.selectedUserAvatar : root.configuredProfilePath
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready && root.selectedUserAvatar !== ""
                    // visible: false
                    opacity: root.selectedUserAvatar !== "" ? 1 : 0.5
                }

                // Fallback stuff if no avatar
                Text {
                    id:avatarFallbackText
                    z: 23
                    anchors.centerIn: parent
                    // visible: root.selectedUserAvatar === ""
                    visible: false
                    text: "Aprosopon" + root.selectedUserName.charAt(0).toUpperCase()
                    font.family: root.athensFontFamily
                    font.pixelSize: 50 * root.uiScale
                    font.weight: Font.Light
                    color: '#000000'
                }

                MultiEffect {
                    z: 23
                    visible: root.selectedUserAvatar === ""
                    source: avatarFallbackText
                    width: avatarFallbackText.width
                    height: avatarFallbackText.height
                    anchors.fill: avatarFallbackText
                    
                    shadowEnabled: true
                    shadowColor: Qt.rgba(0, 0, 0)
                    shadowBlur: 1
                    shadowOpacity: 1
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 0

                    blurEnabled: true
                    blur: 0.1
                    
                    brightness: 0
                }

                MultiEffect {
                    z:22
                    source: userAvatar
                    anchors.fill: userAvatar

                    // contrast: root.selectedUserAvatar === "" ? 1.0 : 0
                    // colorization: root.selectedUserAvatar === "" ? 1.0 : 0
                    // colorizationColor: Qt.rgba(1 ,1 ,1 , 1.0)
                    // brightness:  root.selectedUserAvatar === "" ? -1.0 : 0 // Inverts colors  
                }

                // Image {
                //     z: 23
                //     width: parent.width
                //     height: parent.height
                //     source: root.configuredProfilePath 
                //     fillMode: Image.PreserveAspectFit
                //     anchors.centerIn: parent
                //     visible: userAvatar.status !== Image.Ready
                // }
            }

            Text {
                z: 22
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.selectedUserName
                font.family: root.appFontFamily
                font.pixelSize: 13 * root.uiScale
                color: "#c0c0d8"
            }


            // Online indicator
            // Rectangle {
            //     z: 22
            //     width: 8 * root.uiScale
            //     height: 8 * root.uiScale
            //     color: "#4caf7a"
            //     anchors.horizontalCenter: parent.horizontalCenter
            // }
        }
    }

    // Handle login failures
    Connections {
        target: sddm
        function onLoginFailed() {
            passwordInput.clear()
            passwordInput.forceActiveFocus()
        }
    }

    Component.onCompleted: {
        passwordInput.forceActiveFocus()
    }
}
