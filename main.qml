import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtWebSockets 1.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("CAN Cloud demo application")

    property var msgid_enu: { "call":2, "retok":3, "reterr":4, "event":5 }
    property double engineSpeed: 0.0
    property bool headLight: false
    property bool hazaradLight: false
    property bool engineStatus: false
    property string connectionStatus: ""
    property string sendStatus: ""
    property string status_str: ""
    property string request_str: ""
    property string api_verb_str: ""

    Label {
        x: 106
        text: "QML Websocket low-can Application"
        font.pixelSize: 26
        font.bold: true
        anchors.topMargin: parent.horizontalCenter
        y: 0
    }

    WebSocket{
        id: websocket
        url: bindingAddressCAN
        onTextMessageReceived: {
            var json_message = JSON.parse(message);
            console.log("");
            console.log("Raw message : ", message);
            console.log("[0]", json_message[0]);
            console.log("[1]", json_message[1]);

            if(json_message[0] === msgid_enu.reterr){
                console.log("ERROR: ",json_message[2].info);
            }

            if(json_message[0] === msgid_enu.event){
                console.log("EVENT: TRUE ");
                if(json_message[1] === "low-can/messages.engine.speed"){
                    engineSpeed = json_message[2].data.value;
                    api_verb_str = "hono/sendt";
                    websocket.active = true;
                    console.log("Websocket Status ; ", websocket.status);
                    request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str + '",{"host_name":"172.18.0.110", "sensor_id":"sensor2","port":"8080","field":"engine.speed","value":"' + engineSpeed +'","tenant_name":"DEFAULT_TENANT"}]';
                    websocket.sendTextMessage(request_str);
                    console.log(request_str);
                }
                else if (json_message[1] === "low-can/messages.engine.state.switch"){
                    engineStatus = json_message[2].data.value;
                    api_verb_str = "hono/sendt";
                    websocket.active = true;
                    console.log("Websocket Status ; ", websocket.status);
                    //engineState_val = engineStatus ? 1 : 0;
                    request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str + '",{"host_name":"172.18.0.110", "sensor_id":"sensor3","port":"8080","field":"engine.state.switch","value":"' + engineStatus +'","tenant_name":"DEFAULT_TENANT"}]';
                    websocket.sendTextMessage(request_str);
                    console.log(request_str);
                }
                else if (json_message[1] === "low-can/messages.light.display"){
                    headLight = json_message[2].data.value;
                    api_verb_str = "hono/sendt";
                    websocket.active = true;
                    console.log("Websocket Status ; ", websocket.status);
                    //headLight_val = headLight ? 1 : 0;
                    request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str + '",{"host_name":"172.18.0.110", "sensor_id":"sensor4","port":"8080","field":"Head Light Status","value":"' + headLight +'","tenant_name":"DEFAULT_TENANT"}]';
                    websocket.sendTextMessage(request_str);
                    console.log(request_str);
                    console.log(json_message[2].data.timestamp);
                }
                else if (json_message[1] === "low-can/messages.hazard.light.switch"){
                    hazaradLight = json_message[2].data.value;
                    api_verb_str = "hono/sendt";
                    websocket.active = true;
                    console.log("Websocket Status ; ", websocket.status);
                    request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str + '",{"host_name":"172.18.0.110", "sensor_id":"sensor5","port":"8080","field":"Hazard Light Status","value":"' + hazaradLight +'","tenant_name":"DEFAULT_TENANT"}]';
                    websocket.sendTextMessage(request_str);
                    console.log(request_str);
                    console.log(json_message[2].data.timestamp);
                }
            }
            else {
                var request_json = json_message[2].request;
                console.log("request.status: ", request_json.status);
                console.log("request.info: ", request_json.info);
                if(api_verb_str === "hono/connect"){
                    connectionStatus = request_json.info;
                }
                else {
                    sendStatus = request_json.info;
                }
            }
        }
        onStatusChanged: {
            if(websocket.status === WebSocket.Error){
                status_str = "Error : " + websocket.errorString;
            }
            else if (websocket.status === WebSocket.Open) {
                api_verb_str = "low-can/subscribe";
                request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str +'",{ \"event\" : \"engine.speed\" } ]';
                websocket.sendTextMessage(request_str);
                console.log (request_str);
                request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str +'",{ \"event\" : \"engine.state.switch\" } ]';
                websocket.sendTextMessage(request_str);
                console.log (request_str);
                request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str +'",{ \"event\" : \"light.display\" } ]';
                websocket.sendTextMessage(request_str);
                console.log (request_str);
                request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str +'",{ \"event\" : \"hazard.light.switch\" } ]';
                websocket.sendTextMessage(request_str);
                console.log (request_str);
                request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str +'",{ \"event\" : \"hazard.light.state\" } ]';
                websocket.sendTextMessage(request_str);
                console.log (request_str);
                api_verb_str = "hono/connect";
                request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str +'",{"host_name":"172.18.0.110", "device_id":"engineSpeed","port":"28080", "tenant_name":"DEFAULT_TENANT"}]';
                websocket.sendTextMessage(request_str);
            }
            else if(websocket.status === WebSocket.Closed){
                status_str = "Socket Closed"
            }
            console.log("Socket status : ", status_str);
        }
        active: true
    }

    Text {
        id: url_notifier_CAN
        x: 254
        text: "<b>CAN URL:</b> " + websocket.url
        font.pointSize: 22
        y: 35
    }
    //low-can section
    Text {
        id: engine_state
        text: "<b>Engine state:</b> " + engineStatus
        anchors.horizontalCenterOffset: 13
        font.pointSize: 28
        anchors.horizontalCenter: parent.horizontalCenter
        y: 67
    }
    Text {
        id: engine_speed
        text: "<b>Engine speed: </b>" + engineSpeed + "<b> rpm</b>"
        anchors.horizontalCenterOffset: 12
        font.pointSize:28
        anchors.horizontalCenter: parent.horizontalCenter
        y: 100
    }

    Text {
        id: head_light
        text: "<b>Head Light: </b>" + headLight
        anchors.horizontalCenterOffset: 13
        font.pointSize: 28
        anchors.horizontalCenter: parent.horizontalCenter
        y: 147
    }

    Text {
        id: hazard_light
        text: "<b>Hazard Light: </b>" + hazaradLight
        anchors.horizontalCenterOffset: 13
        font.pointSize: 28
        anchors.horizontalCenter: parent.horizontalCenter
        y: 182
    }

    Button {
        id: subscribe
        text: qsTr("Subscribe")
        anchors.horizontalCenterOffset: 12
        style: ButtonStyle{
            label: Text{
                renderType: Text.NativeRendering
                font.family: "Helvetica"
                font.pointSize: 30
                color: "black"
                text: control.text
            }
        }
        onClicked: {
            websocket.active = true
            request_str = '[' + msgid_enu.call + ',"99999","' + "low-can" +'/'+ "subscribe" +'",{ \"event\" : \"engine.speed\" } ]';
            websocket.sendTextMessage(request_str);
            console.log (request_str);
            request_str = '[' + msgid_enu.call + ',"99999","' + "low-can" +'/'+ "subscribe" +'",{ \"event\" : \"engine.state.switch\" } ]';
            websocket.sendTextMessage(request_str);
            console.log (request_str);
            request_str = '[' + msgid_enu.call + ',"99999","' + "low-can" +'/'+ "subscribe" +'",{ \"event\" : \"light.display\" } ]';
            websocket.sendTextMessage(request_str);
            console.log (request_str);
            request_str = '[' + msgid_enu.call + ',"99999","' + "low-can" +'/'+ "subscribe" +'",{ \"event\" : \"hazard.light.switch\" } ]';
            websocket.sendTextMessage(request_str);
            console.log (request_str);
            request_str = '[' + msgid_enu.call + ',"99999","' + "low-can" +'/'+ "subscribe" +'",{ \"event\" : \"hazard.light\" } ]';
            websocket.sendTextMessage(request_str);
            console.log (request_str);
        }
        anchors.horizontalCenter: parent.horizontalCenter
        y: 222
    }

    // Hono section
    Text {
        id: connuction_notifier
        text: "<b>Connection Status: </b>" + connectionStatus
        anchors.horizontalCenterOffset: 13
        font.pointSize: 28
        anchors.horizontalCenter: parent.horizontalCenter
        wrapMode: "WordWrap"
        y: 291
    }
    Text {
        id: send_notifier
        text: "<b>send Status: </b>" + sendStatus
        anchors.horizontalCenterOffset: 13
        font.pointSize: 28
        anchors.horizontalCenter: parent.horizontalCenter
        y: 340
    }
    Button {
        id: connect
        text: qsTr("Connect")
        anchors.horizontalCenterOffset: 12
        style: ButtonStyle{
            label: Text{
                renderType: Text.NativeRendering
                font.family: "Helvetica"
                font.pointSize: 30
                color: "black"
                text: control.text
            }
        }
        onClicked: {
            api_verb_str = "hono/connect";
            websocket.active = true;
            request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str +'",{"host_name":"172.18.0.110", "device_id":"engineSpeed","port":"28080", "tenant_name":"DEFAULT_TENANT"}]';
            websocket.sendTextMessage(request_str);
            console.log (request_str);
            request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str +'",{"host_name":"172.18.0.110", "device_id":"engineState","port":"28080", "tenant_name":"DEFAULT_TENANT"}]';
            websocket.sendTextMessage(request_str);
            console.log (request_str);
            request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str +'",{"host_name":"172.18.0.110", "device_id":"headLight","port":"28080", "tenant_name":"DEFAULT_TENANT"}]';
            websocket.sendTextMessage(request_str);
            console.log (request_str);
            request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str +'",{"host_name":"172.18.0.110", "device_id":"hazardLight","port":"28080", "tenant_name":"DEFAULT_TENANT"}]';
            websocket.sendTextMessage(request_str);
            console.log (request_str);
        }
        anchors.horizontalCenter: parent.horizontalCenter
        y: 380
    }
}
