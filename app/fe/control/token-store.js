var store = require("./../../../public/js/ext/store+json2-1.3.17.min.js");

module.exports.setToken = function(token) {
    store.set('token-token', token);
};

module.exports.getToken = function() {
    return store.get('token-token');
};

module.exports.removeToken = function() {
    store.remove('token-token');
};

module.exports.setUser = function(user) {
    store.set('token-user', user);
};

module.exports.getUser = function() {
    return store.get('token-user');
};

module.exports.removeUser = function() {
    store.remove('token-user');
};

module.exports.remove = function() {
    this.removeToken();
    this.removeUser();
};