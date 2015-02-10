var store = require("./ext/store+json2-1.3.17.min.js");

module.exports.setToken = function(token) {
    store.set('token-token', token);
};

module.exports.getToken = function() {
    return store.get('token-token');
};

module.exports.removeToken = function() {
    store.remove('token-token');
};

module.exports.setUser = function(token) {
    store.set('token-user', token);
};

module.exports.getUser = function() {
    store.get('token-user');
};

module.exports.removeUser = function() {
    store.remove('token-user');
};

module.exports.remove = function() {
    this.removeToken();
    this.removeUser();
};