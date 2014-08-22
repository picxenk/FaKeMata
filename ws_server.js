/** CONFIG **/
var debug = true;
var log_level = 1; // 1: No, 3: verbose
var encoding = 'utf-8';
var public_html_path = 'public_html';
var http_port = 8000;
var host_ip = '127.0.0.1';

if (process.argv.length > 2) {
    host_ip = process.argv[2];
}
if (process.argv.length > 3) {
    http_port = process.argv[3];
}

/** IMPORT MODULES **/
var http = require('http');
var fs = require('fs');
var static = require('node-static');

/** DATA **/
var blank = {
    count : 0,
    poll : [0, 0, 0, 0, 0],
};

/** INIT SERVICES **/
var file = new(static.Server)(public_html_path);
var http_server = http.createServer(function(req, res) {
    req.addListener('end', function() {
        file.serve(req, res);
    });
});

/** LOGGERS & ETC **/
var do_nothing = function() {};

var ngv_error_logger = function() {
    console.log(Array.prototype.join.call(arguments, ", "));
};

var ngv_disconn_logger = function(con) {
    if (debug) {
        console.log('[Message]: '+con.id+' disconnected');
    }
};

var ngv_client_logger = function(con, data) {
    if (debug) {
        console.log("[Client:"+con.id+"]");
        console.log(data);
    }
};

/** MAIN **/

/** START SERVER **/
// io = io.listen(http_server);
// io.set('log level', log_level);
http_server.listen(http_port, host_ip);
console.log('[Message]: HTTP file server is running at http://'+host_ip+':'+http_port);
