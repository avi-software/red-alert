import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import QtMultimedia 5.0

import "data.js" as DataExt


Column {
    id:view
    spacing: units.gu(1)
    anchors {
        topMargin: units.gu(2)
        margins: units.gu(0)
        fill: parent
    }
    Settings{
        id : settings
    }

    property var  lastWarningId :0;
    property var  locationData  : DataExt.locationData;
    property bool isEmpty: false;
    property bool hasAudioFile:true;

    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin:   units.gu(2)
        spacing: units.gu(2)
        Label {
            id: label
            text:  i18n.tr("Check for alarms")
            elide: Text.ElideRight
            font.weight: Font.Light
        }
        Switch {
            id: s
            objectName: "switch_checked"
            checked: settings.isActivated
            onTriggered: settings.isActivated = s.checked
        }
    }

    ListModel {
        id: alertsList
    }
    SortFilterModel {
        id: sortedAlerts
        model: alertsList
        sort.property: "id"
        sort.order: Qt.DescendingOrder

    }
    Audio {
        id: playMusic
        source: settings.alarmFilePath
        onError: {
            console.log("error: " + error + " - description: " + errorString);
            hasAudioFile =false;
        }
    }
    Loader {
        id:activityLoader
        anchors {left: parent.left;  right: parent.right }
        sourceComponent: isEmpty ? emptyComp :undefined;
    }
    Component{
        id : listComp
        UbuntuListView {
            id: ubuntuListView
            anchors {left: parent.left;  right: parent.right }
            height: view.height - label.height
            model: sortedAlerts
            clip: true

            delegate: ListItem.Expandable {
                id: expandingItem
                expandedHeight: contentColumn.height + units.gu(1)
                LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
                onClicked: {
                    ubuntuListView.expandedIndex = index;
                }

                Column {
                    id: contentColumn
                    anchors {left: parent.left;  right: parent.right }
                    Item {
                        id: firstLine
                        anchors {left: parent.left;  right: parent.right }
                        height: expandingItem.collapsedHeight

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors {left: parent.left;  right: parent.right }
                            spacing: units.gu(2)
                            Label {
                                id: label1
                                color:UbuntuColors.red
                                text: model.messageTime
                                Timer{
                                    interval :10000
                                    repeat:false
                                    running:true
                                    onTriggered:label.color = Theme.palette.selected.backgroundText
                                }
                            }
                            Rectangle{
                                id :rec
                                height: label1.height
                                width: units.gu(0.1)
                                color:UbuntuColors.red
                            }

                            Label {
                                id: label2
                                color:UbuntuColors.red
                                text: model.loc
                            }
                            Rectangle{
                                id :rec1
                                height: label1.height
                                width: units.gu(0.1)
                                color:UbuntuColors.red
                            }
                            Label {
                                id: label3
                                color:UbuntuColors.red
                                text:  i18n.tr("Safe Time:")+" " + model.time
                            }
                            Timer{
                                interval :10000
                                repeat:false
                                running:true
                                onTriggered:{
                                    label3.color = Theme.palette.selected.backgroundText
                                    label2.color = Theme.palette.selected.backgroundText
                                    label1.color = Theme.palette.selected.backgroundText
                                    rec.color = Theme.palette.selected.backgroundText
                                    rec1.color = Theme.palette.selected.backgroundText


                                }
                               }
                        }

                    }
                    Label {
                        anchors {left: parent.left;  right: parent.right }
                        text: model.name
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
    Component{
        id: emptyComp
        Label{
            id:noAlarmText
            anchors {centerIn: parent.Center; }
            fontSize: "x-large"
            text:  i18n.tr("No alerts right now!")
            horizontalAlignment:Text.AlignHCenter
        }
    }
    Timer{
        interval :2000
        repeat:true
        running:settings.isActivated
        triggeredOnStart:true
        onTriggered:setData();
    }

    function setData(){
        var xhr = new XMLHttpRequest();        
         xhr.open('GET', 'http://www.oref.org.il/WarningMessages/alerts.json', true);
        //xhr.open('GET', 'http://avisoftware.github.io/a.json', true);
        xhr.setRequestHeader("Access-Control-Allow-Origin","*");
        xhr.onreadystatechange = (function() {
            if(xhr.readyState == XMLHttpRequest.DONE&&xhr.status==200){
                //var tst ='{ "id" : "1405053379253","title" : "פיקוד העורף התרעה במרחב ","data" : ["באר שבע 292","באר שבע 291","יהודה 200"]}'
                var  data=JSON.parse(xhr.responseText);
                //var  data=JSON.parse(tst);

                if(!data.id || data.id === lastWarningId || !data.data || !data.data.length || settings.isActivated === false) {
                    if (!data.data.length){
                        isEmpty =true;
                    }
                    lastWarningId =data.id;
                    return;
                }
                lastWarningId = data.id;
                var selectLocationArea = settings.selectLocationArea;
                var timeMessage = new Date().toLocaleTimeString(Locale.ShortFormat);

                for(var i =0;i<data.data.length;i++){
                    var id = alertsList.count+1;
                    var loc = data.data[i];
                    var time =locationData[data.data[i]].time;
                    var citise = locationData[data.data[i]].name.join(', ');
                    if((selectLocationArea==loc&&settings.selectLocationBy=="city")||settings.selectLocationBy=="all"){
                        alertsList.append(  {"id":id,"loc":loc,"time":time,"name":citise ,"messageTime":timeMessage});
                        if(settings.soundActivated){
                            if(hasAudioFile){
                                playMusic.play();
                            }
                        }
                    }else{
                        isEmpty =true;
                        activityLoader.sourceComponent= emptyComp;
                        return;
                    }
                }
                isEmpty =false;
                activityLoader.sourceComponent= listComp;
            }
            if(xhr.status!==200){
                isEmpty =true;
                activityLoader.sourceComponent= emptyComp;
                console.log("Some error");
                return;
            }
        });
        xhr.send('');
    }
}

