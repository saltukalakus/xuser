var mongoose = require('mongoose');
var jwt = require('jwt-simple');
var tokenConfig = require('../../config/token');
var tokenSchema = require('./tokenSchema');

var TokenModel = mongoose.model('Token', tokenSchema);

TokenModel.encode = function(data) {
    return jwt.encode(data, tokenConfig.tokenSecret);
};

TokenModel.decode = function(data) {
    return jwt.decode(data, tokenConfig.tokenSecret);
};

TokenModel.findUserByToken = function(token, cb) {
    this.findOne({'token': token}, function(err, usr) {
        if(err || !usr) {
            cb(err, null);
        } else if (local.token && local.token.token && token === local.token.token) {
            cb(false, {email: local.email, token: local.token});
        } else {
            cb(new Error('Token does not exist or does not match.'), null);
        }
    });
};

TokenModel.createToken = function(email, cb) {
    self = this;
    this.findOne({'email': email}, function(err, token) {
        if(err || email === "") {
            console.log('err');
            cb(true, null);
        }
        if (token){
            console.log("token found!");
            cb(false, token);//token object, in turn
        } else {
            //Create a token and add to user and save
            var tokenize = self.encode({'email': email});
            token = new TokenModel();
            token.token = tokenize;
            token.email = email;
            token.date = Date.now();
            token.save(function(err, usr) {
                if (err) {
                    cb(err, null);
                } else {
                    console.log("about to cb with token.token: " + token.token);
                    cb(false, token);//token object, in turn
                }
            });
        }
    });
};

TokenModel.invalidateUserToken = function(email, cb) {
    this.findOne({'email': email}, function(err, usr) {
        if(err || !usr) {
            console.log('err');
        }
        usr.token = null;
        usr.save(function(err, usr) {
            if (err) {
                cb(err, null);
            } else {
                cb(false, 'removed');
            }
        });
    });
};

// create the model for users and expose it to our app
module.exports = TokenModel;