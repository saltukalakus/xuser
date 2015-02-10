tokenStore = require("./token-store.js");

$('document').ready(function() {
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