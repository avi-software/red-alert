import QtQuick 2.0
import Qt.labs.settings 1.0

Settings {
    property bool isActivated: true;
    property var selectLocation: "";
     property var selectLocationArea: "";
    property var selectLocationBy: "all";
    property var alarmFilePath: "multimedia/alarm.mp3";
    property bool soundActivated : true;
}
