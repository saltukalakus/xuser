var mongoose = require('mongoose');
var tokenConfig = require('../../config/token');

// define database schema for tokens
var tokenSchema = mongoose.Schema({
    email: {type: String},
    token: {type: String},
    date_created: {type: Date, default: Date.now}
});

tokenSchema.methods.hasExpired= function(created) {
    var now = new Date();
    var diff = (now.getTime() - created);
    return diff > tokenConfig.ttl;
};

module.exports = tokenSchema;