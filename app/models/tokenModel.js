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

TokenModel.findUserByToken = function(token, done) {
    var decoded = this.decode(token);
    if (decoded && decoded.email) {
        this.findOne({'email': decoded.email}, function (err, usr) {
            if (err || !usr) {
                done(err, null);
            } else if (usr.email === decoded.email) {
                done(false, {email: usr.email});
            } else {
                done(new Error('Token does not exist or does not match.'), null);
            }
        });
    } else {
        done(new Error('Could not decode the token.'), null);
    }
};

TokenModel.createToken = function(email, done) {
    self = this;
    this.findOne({'email': email}, function(err, token) {
        if(err || email === "") {
            console.log('err');
            done(true, null);
        }
        if (token){
            console.log("token found!");
            done(false, token);//token object, in turn
        } else {
            token = new TokenModel();
            token.email = email;
            token.date_created = Date.now();
            token.token =  self.encode({'email': token.email, 'date_created': token.date_created });

            token.save(function(err, usr) {
                if (err) {
                    done(err, null);
                } else {
                    done(false, token);//token object, in turn
                }
            });
        }
    });
};

TokenModel.invalidateUserToken = function(email, done) {
    this.findOne({'email': email}, function(err, usr) {
        if(err || !usr) {
            console.log('err');
        }
        usr.token = null;
        usr.save(function(err, usr) {
            if (err) {
                done(err, null);
            } else {
                done(false, 'removed');
            }
        });
    });
};

// create the model for users and expose it to our app
module.exports = TokenModel;