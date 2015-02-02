// load the things we need
var mongoose = require('mongoose');
var bcrypt   = require('bcrypt-nodejs');

var jwt = require('jwt-simple');
var tokenSecret = 'put-a-$Ecr3t-h3re';
var tokenConfig = require('../../config/token');

// define database schema for tokens
var tokenSchema = mongoose.Schema({
    token: {type: String},
    date_created: {type: Date, default: Date.now},
});
tokenSchema.statics.hasExpired= function(created) {
    var now = new Date();
    var diff = (now.getTime() - created);
    return diff > tokenConfig.ttl;
};

var TokenModel = mongoose.model('Token', tokenSchema);

// define the schema for our user model
var userSchema = mongoose.Schema({

    local            : {
        email        : String,
        password     : String,
        token        : {type: Object}
    },
    facebook         : {
        id           : String,
        token        : String,
        email        : String,
        name         : String
    },
    twitter          : {
        id           : String,
        token        : String,
        displayName  : String,
        username     : String
    },
    google           : {
        id           : String,
        token        : String,
        email        : String,
        name         : String
    }

});

// generating a hash
userSchema.methods.generateHash = function(password) {
    return bcrypt.hashSync(password, bcrypt.genSaltSync(8), null);
};

// checking if password is valid
userSchema.methods.validPassword = function(password) {
    return bcrypt.compareSync(password, this.local.password);
};

userSchema.methods.encode = function(data) {
    return jwt.encode(data, tokenSecret);
};
userSchema.methods.decode = function(data) {
    return jwt.decode(data, tokenSecret);
};

userSchema.methods.findUserByToken = function(user, token, cb) {
    user.findOne({'local.token': token}, function(err, usr) {
        if(err || !usr) {
            cb(err, null);
        } else if (local.token && local.token.token && token === local.token.token) {
            cb(false, {email: local.email, token: local.token});
        } else {
            cb(new Error('Token does not exist or does not match.'), null);
        }
    });
};

userSchema.methods.createUserToken = function(user, email, cb) {
    var self = this;
    user.findOne({'local.email': email}, function(err, usr) {
        if(err || !usr) {
            console.log('err');
        }
        //Create a token and add to user and save
        var token = self.encode({'local.email': email});
        usr.local.token = new TokenModel({token:token});
        usr.save(function(err, usr) {
            if (err) {
                cb(err, null);
            } else {
                console.log("about to cb with usr.token.token: " + usr.local.token.token);
                cb(false, usr.local.token.token);//token object, in turn, has a token property :)
            }
        });
    });
};

userSchema.methods.invalidateUserToken = function(user, email, cb) {
    user.findOne({'local.email': email}, function(err, usr) {
        if(err || !usr) {
            console.log('err');
        }
        usr.local.token = null;
        usr.save(function(err, usr) {
            if (err) {
                cb(err, null);
            } else {
                cb(false, 'removed');
            }
        });
    });
};

// create the model for token and expose it to our app
module.exports.Token = TokenModel;

// create the model for users and expose it to our app
module.exports = mongoose.model('User', userSchema);

