$(document).ready(function () {
    if (!("WebSocket" in window)) {
        $('#chatLog, input, button, #examples').fadeOut("fast");
        $('<p>Oh no, you need a browser that supports WebSockets. How about <a href="http://www.google.com/chrome">Google Chrome</a>?</p>').appendTo('#container');
    } else {
        //The user has WebSockets
        connect();
        function connect() {
            try {
                var socket;
                var host = "ws://localhost:8080/ws";
                var socket = new WebSocket(host);
                message('<p class="event">Socket Status: ' + socket.readyState);
                socket.onopen = function () {
                    message('<p class="event">Socket Status: ' + socket.readyState + ' (open)');
                    socket.send("Receive Data");
                }
                socket.onmessage = function (msg) {
                    //  message('<p class="message">Received: ' + msg.data);
                    // common.js -> receiveBos();
                    $.COM.receiveBos(msg);
                }
                socket.onclose = function () {
                    message('<p class="event">Socket Status: ' + socket.readyState + ' (Closed)');
                }
            } catch (exception) {
                message('<p>Error' + exception);
            }
        }
        function message(msg) {
            console.log(msg);
        }
    }
});
