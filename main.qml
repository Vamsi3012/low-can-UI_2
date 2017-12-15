import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtWebSockets 1.0

ApplicationWindow {
    visible: true
    width: 640
    height: 640
    title: qsTr("CAN Cloud demo application")

    property var msgid_enu: { "call":2, "retok":3, "reterr":4, "event":5 }
    property double engineSpeed: 0.0
    property bool headLight: false
    property bool hazaradLight: false
    property bool engineStatus: false
    property string restConnectionStatus: ""
    property string mqttConnectionStatus: ""
    property string restSendStatus: ""
    property string mqttPubStatus: ""
    property string status_str: ""
    property string request_str: ""
    property string api_verb_str: ""

    Label {
        x: 94
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
                console.log("EVENT: TRUE ", json_message[1]);
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
                    api_verb_str = "pahoc/pub";
                    websocket.active = true;
                    console.log("Websocket Status ; ", websocket.status);
                    //engineState_val = engineStatus ? 1 : 0;
                    request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str + '",{"topic":"engineState", "qos":0,"retained":0,"payload":"' + engineStatus +'"}]';
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
                    api_verb_str = "pahoc/pub";
                    websocket.active = true;
                    console.log("Websocket Status ; ", websocket.status);
                    request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str + '",{"topic":"hazardLight", "qos":0,"retained":0,"payload":"' + hazaradLight +'"}]';
                    websocket.sendTextMessage(request_str);
                    console.log(request_str);
                    console.log(json_message[2].data.timestamp);
                }
            }
            else {
                var request_json = json_message[2].request;
                console.log("request.status: ", request_json.status);
                console.log("request.info: ", request_json.info);
                if(api_verb_str === "pahoc/connect"){
                    mqttConnectionStatus = request_json.info;
                }
                else if(api_verb_str === "hono/connect"){
                    restConnectionStatus = request_json.info;
                }
                else if(api_verb_str === "hono/sendt"){
                    restSendStatus = request_json.info;
                }
                else if(api_verb_str === "pahoc/pub"){
                    mqttPubStatus = request_json.info;
                }
                else{
                    console.log("NONE of the ABOVE: ", request_json.info);
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
        x: 267
        text: "<b>URL:</b> " + websocket.url
        font.pointSize: 22
        y: 35
    }
    //low-can section
    Text {
        id: engine_state
        text: "<b>Engine state:</b> " + engineStatus
        anchors.horizontalCenterOffset: 1
        font.pointSize: 28
        anchors.horizontalCenter: parent.horizontalCenter
        y: 65
    }
    Text {
        id: engine_speed
        text: "<b>Engine speed: </b>" + engineSpeed + "<b> rpm</b>"
        anchors.horizontalCenterOffset: 0
        font.pointSize:28
        anchors.horizontalCenter: parent.horizontalCenter
        y: 97
    }

    Text {
        id: head_light
        text: "<b>Head Light: </b>" + headLight
        anchors.horizontalCenterOffset: 1
        font.pointSize: 28
        anchors.horizontalCenter: parent.horizontalCenter
        y: 132
    }

    Text {
        id: hazard_light
        text: "<b>Hazard Light: </b>" + hazaradLight
        anchors.horizontalCenterOffset: 1
        font.pointSize: 28
        anchors.horizontalCenter: parent.horizontalCenter
        y: 176
    }

    Button {
        id: subscribe
        text: qsTr("Subscribe")
        anchors.horizontalCenterOffset: 0
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
            request_str = '[' + msgid_enu.call + ',"99999","' + "pahoc" +'/'+ "subscribe" +'",{\"topic\": \"Commands\" , \"qos\":0} ]';
            websocket.sendTextMessage(request_str);
            console.log (request_str);
        }
        anchors.horizontalCenter: parent.horizontalCenter
        y: 219
    }

    Button {
        id: connectMQTT
        text: qsTr("connect to MQTT")
        anchors.horizontalCenterOffset: 0
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
            api_verb_str = "pahoc/initMQTT";
            request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str +'",{"serverURI":"tcp://172.18.0.110:1883", "client_id":"AGL-DEMO-APP"}]';
            websocket.sendTextMessage(request_str);
            api_verb_str = "pahoc/connect";
            request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str +'",{"keepAlive":1000, "connectTimeout":4000,"username":"sensor7@DEFAULT_TENANT", "password":"hono-secret"}]';
            websocket.sendTextMessage(request_str);
            console.log(request_str);
        }
        anchors.horizontalCenter: parent.horizontalCenter
        y: 535
    }
    // Hono section
    Text {
        id: restConnection_notifier
        text: "<b>REST Connection Status: </b>" + restConnectionStatus
        anchors.horizontalCenterOffset: 1
        font.pointSize: 28
        anchors.horizontalCenter: parent.horizontalCenter
        wrapMode: "WordWrap"
        y: 281
    }
    Text {
        id: send_notifier
        text: "<b>send Status: </b>" + restSendStatus
        anchors.horizontalCenterOffset: 1
        font.pointSize: 28
        anchors.horizontalCenter: parent.horizontalCenter
        y: 319
    }
    Text {
        id: mqttConnection_notifier
        text: "<b>MQTT Connection Status: </b>" + mqttConnectionStatus
        anchors.horizontalCenterOffset: 1
        font.pointSize: 28
        anchors.horizontalCenter: parent.horizontalCenter
        wrapMode: "WordWrap"
        y: 415
    }
    Text {
        id: publish_notifier
        text: "<b>Publish Status: </b>" + mqttPubStatus
        anchors.horizontalCenterOffset: 1
        font.pointSize: 28
        anchors.horizontalCenter: parent.horizontalCenter
        y: 453
    }
    Button {
        id: connectREST
        text: qsTr("Connect to REST")
        anchors.horizontalCenterOffset: 1
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
            request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str +'",{"host_name":"172.18.0.110", "device_id":"headLight","port":"28080", "tenant_name":"DEFAULT_TENANT"}]';
            websocket.sendTextMessage(request_str);
            console.log (request_str);
        }
        anchors.horizontalCenter: parent.horizontalCenter
        y: 359
        width: 166
        height: 37
    }
    Button {
        id: mqttSub
        text: qsTr("Subscribe to a cloud command")
        anchors.horizontalCenterOffset: 11
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
            api_verb_str = "pahoc/sub";
            websocket.active = true;
            request_str = '[' + msgid_enu.call + ',"99999","' + api_verb_str +'",{"topic":"Commands"}]';
            websocket.sendTextMessage(request_str);
            console.log (request_str);
        }
        anchors.horizontalCenter: parent.horizontalCenter
        y: 487
        width: 310
        height: 37
    }
}
