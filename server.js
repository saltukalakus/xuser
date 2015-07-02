// server.js

// set up ======================================================================
var express  = require('express');
var app      = express();
var swig     = require('swig');
var port     = process.env.PORT || 8081;
var mongoose = require('mongoose');
var passport = require('passport');
var flash    = require('connect-flash');

var morgan       = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser   = require('body-parser');
var session      = require('express-session');
var RedisStore   = require('connect-redis')(session);
var Redis        = require('ioredis');

var dbConf       = require('./config/database.js');
var sessionConf  = require('./config/session.js');
var inetConf     = require('./config/inet.js')

// configuration ===============================================================
mongoose.connect(dbConf.url); // connect to our database

require('./app/mwconf/passport')(passport); // pass passport for configuration

// set up our express application
app.use(morgan('dev')); // log every request to the console
app.use(cookieParser()); // read cookies (needed for auth)
app.use(bodyParser.json()); // get information from html forms
app.use(bodyParser.urlencoded({ extended: true }));

// set .swg as the default extension
app.engine('html', swig.renderFile);
app.set('view engine', 'html');
app.set('views', __dirname + '/app/fe/views');

// redis options
var options = {sentinels: [{ host: sessionConf.sentinel.host1,
                             port: sessionConf.sentinel.port1 },
                           { host: sessionConf.sentinel.host2,
                             port: sessionConf.sentinel.port2 },
                           { host: sessionConf.sentinel.host3,
                             port: sessionConf.sentinel.port3 }],
    name: sessionConf.cluster.name};

// required for passport sessions
app.use(session({
    store: new RedisStore({ client: new Redis(options) }),
    secret: sessionConf.secret
}));

app.use(passport.initialize());
app.use(passport.session()); // persistent login sessions
app.use(flash()); // use connect-flash for flash messages stored in session

// CORS settings
var allowCrossDomain = function(req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET,POST');
    res.header('Access-Control-Expose-Headers', 'token, status, user');
    next();
};

app.use(allowCrossDomain);

// routes ======================================================================
require('./app/routes/routes.js')(app, passport); // load our routes and pass in our app and fully configured passport

// launch ======================================================================
app.listen(port, inetConf.addr);
console.log('The magic happens on port ' + port + ' at' + inetConf.addr);
