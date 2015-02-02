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


var User = mongoose.model('User', userSchema);

User.findUserByToken = function(token, cb) {
    this.findOne({'local.token': token}, function(err, usr) {
        if(err || !usr) {
            cb(err, null);
        } else if (local.token && local.token.token && token === local.token.token) {
            cb(false, {email: local.email, token: local.token});
        } else {
            cb(new Error('Token does not exist or does not match.'), null);
        }
    });
};

User.createUserToken = function(email, cb) {
    this.findOne({'local.email': email}, function(err, usr) {
        if(err || !usr) {
            console.log('err');
        }
        //Create a token and add to user and save
        var token = usr.encode({'local.email': email});
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

User.invalidateUserToken = function(email, cb) {
    this.findOne({'local.email': email}, function(err, usr) {
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


User.signUp = function(req, email, password, done) {
    var self = this;

    if (email)
        email = email.toLowerCase(); // Use lower-case e-mails to avoid case-sensitive e-mail matching

    // if the user is not already logged in:
    if (!req.user) {
        this.findOne({ 'local.email': email }, function (err, user) {
            // if there are any errors, return the error
            if (err)
                return done(err);

            // check to see if there is already a user with that email
            if (user) {
                return done(null, false, req.flash('signupMessage', 'That email is already taken.'));
            } else {

                // create the user
                var newUser = new User();

                newUser.local.email = email;
                newUser.local.password = newUser.generateHash(password);

                newUser.save(function (err) {
                    if (err)
                        return done(err);

                    self.createUserToken(email, function (err, user) {
                        if (err)
                            return done(err);
                        else
                            return done(null, newUser);
                    });
                });
            }
        });
        // if the user is logged in but has no local account...
    } else if (!req.user.local.email) {
        // ...presumably they're trying to connect a local account
        // BUT let's check if the email used to connect a local account is being used by another user
        User.findOne({ 'local.email': email }, function (err, user) {
            if (err)
                return done(err);

            if (user) {
                return done(null, false, req.flash('loginMessage', 'That email is already taken.'));
                // Using 'loginMessage instead of signupMessage because it's used by /connect/local'
            } else {
                var user = req.user;
                user.local.email = email;
                user.local.password = user.generateHash(password);
                user.save(function (err) {
                    if (err)
                        return done(err);

                    return done(null, user);
                });
            }
        });
    } else {
        // user is logged in and already has a local account. Ignore signup. (You should log out before trying to create a new account, user!)
        return done(null, req.user);
    }
};

User.login = function(req, email, password, done) {
    this.findOne({ 'local.email': email }, function (err, user) {
        // if there are any errors, return the error
        if (err)
            return done(err);

        // if no user is found, return the message
        if (!user)
            return done(null, false, req.flash('loginMessage', 'No user found.'));

        if (!user.validPassword(password))
            return done(null, false, req.flash('loginMessage', 'Oops! Wrong password.'));

        // all is well, return user
        else
            return done(null, user);
    });
};

// create the model for users and expose it to our app
module.exports = User;

