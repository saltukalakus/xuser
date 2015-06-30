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
                done(false, usr);
            } else {
                done(new Error('Token does not exist or does not match.'), null);
            }
        });
    } else {
        done(new Error('Could not decode the token.'), null);
    }
};

TokenModel.findTokenByUser = function(email, done) {
    this.findOne({'email': email}, function (err, usr) {
        if (err || !usr) {
            done(err, null);
        } else if (usr.email === email) {
            done(false, usr);
        } else {
            done(new Error('Token for this user does not exist.'), null);
        }
    });
};

TokenModel.createToken = function(email, done) {
    self = this;
    this.findOne({'email': email}, function(err, user) {
        if(err || email === "") {
            console.log('err');
            done(true, null);
        }
        if (!user) {
            user = new TokenModel();
            user.email = email;
        }
        user.date_created = Date.now();
        user.token =  self.encode({'email': user.email, 'date_created': user.date_created });

        user.save(function(err) {
            if (err) {
                done(err, null);
            } else {
                done(false, user);//token object, in turn
            }
        });
    });
};

TokenModel.invalidateToken = function(email, done) {
    this.findOne({'email': email}, function(err, usr) {
        if (err || !usr) {
            console.log(err);
        } else {
            usr.token = null;
            usr.save(function (err, usr) {
                if (err) {
                    done(err, null);
                } else {
                    done(false, 'removed');
                }
            });
        }
    });
};

// create the model for users and expose it to our app
module.exports = TokenModel;