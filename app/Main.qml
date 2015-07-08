import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

import "data.js" as DataExt


MainView {
    objectName: "mainView"
    applicationName: "red-alert.avisoftware"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(100)
    height: units.gu(75)

    headerColor:UbuntuColors.coolGrey
    backgroundColor: Qt.lighter(headerColor)
    footerColor: Qt.lighter(backgroundColor)
    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true
    Component.onCompleted: pageStack.push(mainPage)
    PageStack {
        id: pageStack
    }
    Page {
        title: i18n.tr("Red Alert")
        id: mainPage
        objectName: "mainPage"
        flickable: null
        width:parent.width
        Action {
            id: settingsAction
            objectName:"settingsButton"
            iconName: "settings"
            text: i18n.tr("Settings")
            onTriggered: {
                pageStack.push(settingsPage)
            }
        }
        head {
            actions: [
                settingsAction
            ]
        }
        ActivityView{

        }
    }

    Page {
        title: i18n.tr("Settings")
        id: settingsPage
        visible: false
        objectName: "settingsPage"
        flickable: null
        width:parent.width
        head {

        }
        SettingsView{
            anchors.fill: parent
        }
    }

}

