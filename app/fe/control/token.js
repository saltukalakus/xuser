tokenStore = require("./token-store.js");

$('document').ready(function() {

    // When page loads check for the token and update it at the web store
    var req = new XMLHttpRequest();
    req.open('GET', document.location, false);
    req.send(null);

    //var headers = req.getAllResponseHeaders().toLowerCase();
    var token = req.getResponseHeader('token');
    if (token) {
        console.log("Stored token in web store!");
        tokenStore.setToken(token);
    }
    var user = req.getResponseHeader('user');
    if (user) {
        console.log("Stored user in web store!");
        tokenStore.setUser(user);
    }

    var status = req.getResponseHeader('status')
    if  (status == 'logout') {
        console.log("Removed token and user in web store!");
        tokenStore.remove();
    }

    // for token.html
    $("#sessionUser").text(tokenStore.getUser());
    $("#sessionToken").text(tokenStore.getToken());

    /////////////////////////////////////////////////////////////////
    // SIMULATE API REQUEST /////////////////////////////////////////
    /////////////////////////////////////////////////////////////////
    $('.testToken').on("click", function(e) {
        var token = tokenStore.getToken();
        if (token) {
            $.ajax({
                type: "GET",
                cache: false,
                dataType: "json",
                url: "/api/test",
                headers: {
                    token: token
                },
                success: function(data) {
                    if (data.error) {
                        alert("Error: " + data.error);
                    } else {
                        console.log(JSON.stringify(data));
                        alert("Token callback worked! Check console");
                    }
                }
            });
        } else {
            alert("No token");
        }
    });

    $('.generateToken').on("click", function(e) {
        $.ajax({
            type: "GET",
            cache: false,
            dataType: "json",
            url: "/api/token/generate",
            success: function(data) {
                if (data.error) {
                    alert("Error: " + data.error);
                } else {
                    console.log(JSON.stringify(data));
                    tokenStore.setToken(data.token);
                    tokenStore.setUser(data.email);
                    console.log("This is the token: "  + tokenStore.getToken());
                    $("#sessionToken").text(data.token);
                    $("#sessionUser").text(data.email);
                }
            }
        });
    });

    $('.invalidateToken').on("click", function(e) {
        var token = tokenStore.getToken();
        tokenStore.removeToken();
        if (token) {
            $.ajax({
                type: "GET",
                cache: false,
                dataType: "json",
                url: "/api/token/invalidate",
                headers: {
                    token: token
                },
                success: function(data) {
                    console.log(data);
                    if (data.error) {
                        alert("Issue removing token.");
                    } else {
                        $("#sessionToken").text("");
                    }
                }
            });
        } else {
            alert("No token");
        }
    });
});