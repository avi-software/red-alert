import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import QtMultimedia 5.0

import "data.js" as DataExt
Flickable {
    id: flick
    contentHeight: view.height
    contentWidth: parent.width
    anchors.fill: parent
    anchors.topMargin: units.gu(2)
    clip: true
    boundsBehavior:Flickable.StopAtBounds
    Column {
        id:view
        spacing: units.gu(2)
        anchors {
            margins: units.gu(2)
            left: parent.left;
            right: parent.right;
        }
        Settings{
            id : settings
        }

        OptionSelector {
            id: optionLocationsBy
            text: i18n.tr("Select alerts area:")
            model: [i18n.tr("Notify for all areas"),
                i18n.tr("Notify by city")]
            delegate:OptionSelectorDelegate {
                LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
            }
            onSelectedIndexChanged: {
                if(optionLocationsBy.selectedIndex===0){
                    settings.selectLocation = "";
                    settings.selectLocationArea=""
                    settings.selectLocationBy="all"
                    optionLocations.visible=false;
                }else if(optionLocationsBy.selectedIndex===1){
                    optionLocations.visible=true;
                    settings.selectLocationBy="city"
                }
            }
            Component.onCompleted: {
                if(settings.selectLocationBy=="all"){
                    optionLocationsBy.selectedIndex=0;
                }else if(settings.selectLocationBy=="city"){
                    optionLocationsBy.selectedIndex=1;
                }
            }
        }

        ListModel{
            id:listModelLocations
        }

        OptionSelector {
            id: optionLocations
            objectName: "optionselector"
            text: i18n.tr("Select city:")
            model: listModelLocations
            containerHeight: itemHeight * 8
            delegate:OptionSelectorDelegate { text: model.city;
                LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
            }
            onSelectedIndexChanged: {
                if(settings.selectLocationBy=="city"){
                    settings.selectLocation=model.get(selectedIndex).city;
                    settings.selectLocationArea=model.get(selectedIndex).area;
                }
            }
            Component.onCompleted: {
                view.setModel(function(){
                    if(settings.selectLocationBy=="city"){
                        optionLocations.selectedIndex =view.getIndexOf(settings.selectLocation.toString());
                        if(optionLocations.selectedIndex===0){
                            settings.selectLocation=listModelLocations.get(0).city;
                            settings.selectLocationArea=listModelLocations.get(0).area;
                        }
                    }else{
                        visible =false;
                    }
                });
            }
        }
        function setModel(callback){
            listModelLocations.clear();
            DataExt.locationDataRow.forEach(function(e,index){
                if(e[0] && e[2]){
                    listModelLocations.append({"city":e[0],"area":e[2]})
                }
            });
            callback();
        }
        function getIndexOf(str){
            for (var i=0; i<listModelLocations.count;i++){
                if (listModelLocations.get(i).city===str){
                    return i;
                }
            }
            return 0;
        }
        ListItem.ThinDivider {
        }
        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: units.gu(2)
            Label {
                id: label
                text:  i18n.tr("Sound activate")
            }
            Switch {
                id :s
                checked: settings.soundActivated
                onTriggered: settings.soundActivated = s.checked
            }
        }Audio {
            id: playMusic
            onError: {
             console.log("error: " + error + " - description: " + errorString);
            pathToAlarm.color ="red";
            }
     }
        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: units.gu(2)
            Button{
                id :buttonR
                width: units.gu(5)
                iconName: "reset"
                onClicked: pathToAlarm.text ="multimedia/alarm.mp3"
            }

            TextField {
                id:pathToAlarm
                width: parent.width - buttonR.width - buttonT.width-units.gu(4)
                onTextChanged:{ settings.alarmFilePath = pathToAlarm.text
                    color =Theme.palette.normal.overlayText
                }
                Component.onCompleted: text= settings.alarmFilePath
            }
            Button{
                id :buttonT
                anchors.rightMargin: units.gu(2)
                width: units.gu(5)
                iconName: "media-playback-start"
                onClicked: {
                    playMusic.source =pathToAlarm.text;
                    playMusic.play();
                }
            }
        }

    }
}
