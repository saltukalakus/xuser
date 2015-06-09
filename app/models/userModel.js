var mongoose = require('mongoose');
var userSchema = require('./userSchema');

var User = mongoose.model('User', userSchema);

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
                newUser.local.role = 'admin';

                newUser.save(function (err) {
                    if (err)
                        return done(err);

                    if (err)
                        return done(err);
                    else
                        return done(null, newUser);
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
    if (email)
        email = email.toLowerCase(); // Use lower-case e-mails to avoid case-sensitive e-mail matching

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

User.loginFacebook = function (req, token, refreshToken, profile, done) {
    // check if the user is already logged in
    if (!req.user) {

        User.findOne({ 'facebook.id' : profile.id }, function(err, user) {
            if (err)
                return done(err);

            if (user) {

                // if there is a user id already but no token (user was linked at one point and then removed)
                if (!user.facebook.token) {
                    user.facebook.token = token;
                    user.facebook.name  = profile.name.givenName + ' ' + profile.name.familyName;
                    user.facebook.email = (profile.emails[0].value || '').toLowerCase();

                    user.save(function(err) {
                        if (err)
                            return done(err);

                        return done(null, user);
                    });
                }

                return done(null, user); // user found, return that user
            } else {
                // if there is no user, create them
                var newUser            = new User();

                newUser.facebook.id    = profile.id;
                newUser.facebook.token = token;
                newUser.facebook.name  = profile.name.givenName + ' ' + profile.name.familyName;
                newUser.facebook.email = (profile.emails[0].value || '').toLowerCase();

                newUser.save(function(err) {
                    if (err)
                        return done(err);

                    return done(null, newUser);
                });
            }
        });

    } else {
        // user already exists and is logged in, we have to link accounts
        var user            = req.user; // pull the user out of the session

        user.facebook.id    = profile.id;
        user.facebook.token = token;
        user.facebook.name  = profile.name.givenName + ' ' + profile.name.familyName;
        user.facebook.email = (profile.emails[0].value || '').toLowerCase();

        user.save(function(err) {
            if (err)
                return done(err);

            return done(null, user);
        });

    }
};

User.loginTwitter = function(req, token, tokenSecret, profile, done) {
    // check if the user is already logged in
    if (!req.user) {

        User.findOne({ 'twitter.id' : profile.id }, function(err, user) {
            if (err)
                return done(err);

            if (user) {
                // if there is a user id already but no token (user was linked at one point and then removed)
                if (!user.twitter.token) {
                    user.twitter.token       = token;
                    user.twitter.username    = profile.username;
                    user.twitter.displayName = profile.displayName;

                    user.save(function(err) {
                        if (err)
                            return done(err);

                        return done(null, user);
                    });
                }

                return done(null, user); // user found, return that user
            } else {
                // if there is no user, create them
                var newUser                 = new User();

                newUser.twitter.id          = profile.id;
                newUser.twitter.token       = token;
                newUser.twitter.username    = profile.username;
                newUser.twitter.displayName = profile.displayName;

                newUser.save(function(err) {
                    if (err)
                        return done(err);

                    return done(null, newUser);
                });
            }
        });

    } else {
        // user already exists and is logged in, we have to link accounts
        var user                 = req.user; // pull the user out of the session

        user.twitter.id          = profile.id;
        user.twitter.token       = token;
        user.twitter.username    = profile.username;
        user.twitter.displayName = profile.displayName;

        user.save(function(err) {
            if (err)
                return done(err);

            return done(null, user);
        });
    }
};

User.loginGoogle =  function(req, token, refreshToken, profile, done) {
    // check if the user is already logged in
    if (!req.user) {

        User.findOne({ 'google.id' : profile.id }, function(err, user) {
            if (err)
                return done(err);

            if (user) {

                // if there is a user id already but no token (user was linked at one point and then removed)
                if (!user.google.token) {
                    user.google.token = token;
                    user.google.name  = profile.displayName;
                    user.google.email = (profile.emails[0].value || '').toLowerCase(); // pull the first email

                    user.save(function(err) {
                        if (err)
                            return done(err);

                        return done(null, user);
                    });
                }

                return done(null, user);
            } else {
                var newUser          = new User();

                newUser.google.id    = profile.id;
                newUser.google.token = token;
                newUser.google.name  = profile.displayName;
                newUser.google.email = (profile.emails[0].value || '').toLowerCase(); // pull the first email

                newUser.save(function(err) {
                    if (err)
                        return done(err);

                    return done(null, newUser);
                });
            }
        });

    } else {
        // user already exists and is logged in, we have to link accounts
        var user               = req.user; // pull the user out of the session

        user.google.id    = profile.id;
        user.google.token = token;
        user.google.name  = profile.displayName;
        user.google.email = (profile.emails[0].value || '').toLowerCase(); // pull the first email

        user.save(function(err) {
            if (err)
                return done(err);

            return done(null, user);
        });

    }
};
// create the model for users and expose it to our app
module.exports = User;