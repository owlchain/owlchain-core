// Keep socket variable at global level

var socket = {};
 
function connect(name) {
    try {
 
        // Test if websocket doesn't exist, and if not, create a new connection
        if (! ('readyState' in socket)) {
            socket = new WebSocket(getBaseURL() + '/ws');
        }
 
        socket.onopen = function() {
            try {
                socket.send(name); // Tell the server who you are, handle validation server side!
 
                // Swap the chat and login divs around
                document.getElementById('name').value = '';
                document.getElementById('login').style.display = 'none';
                document.getElementById('chat').style.display = 'block';
                document.getElementById('text').focus();
            } catch (exception) {
                alert(exception);
            }
        }
        socket.onmessage = function(msg) {
            var msgVal = JSON.parse(msg.data); // We're anticipating messages formatted as "{'name':'Csmith1991', 'text':'example'}"
            var chatLog = document.getElementById('chatLog');
            chatLog.innerHTML += '<p>' + msgVal.name + ': ' + msgVal.text + '</p>'; // Add to the chatLog
            chatLog.scrollTop = chatLog.scrollHeight; // Scroll chatLog to bottom
 
        }
        socket.onclose = function() {
            socket = {}; // Remove socket connection
 
            // Swap the chat and login divs around. Note we don't do this until the connection has closed.
            document.getElementById('chat').style.display = 'none';
            document.getElementById('login').style.display = 'block';
            document.getElementById('name').focus();
        }
    } catch (exception) {
        alert(exception);
    }
}
 
function startConnection(event) {
    // 13 = enter button
    if (event.which === 13 || event.keyCode === 13 ) {
        // Connect to WebSocket server
        connect(document.getElementById('name').value);
    }
}
 
function chat(event) {
    if (event.which === 13 || event.keyCode === 13 ) {
        var myObj = document.getElementById('text');
        socket.send(myObj.value);
        myObj.value = '';
        myObj.focus();
    }
}
 
function endConnection() {
    // We want to close the connection on the server, so we create a message that the server listens for to close on
    socket.send('/close');
}
 
function getBaseURL() {
    // Get the WebSocket server address e.g. ws://127.0.0.1:8080
 
    var href = window.location.href.substring(7); // strip "http://"
    var idx = href.indexOf('/');
    return 'ws://' + href.substring(0, idx);
}