$('.logout').on("click", function(e) {
    var token = Store.getToken();
    Store.removeUser();
    if (token) {
        $.ajax({
            type: "GET",
            cache: false,
            dataType: "json",
            url: "/logout",
            headers: {
                token: token
            },
            success: function(data) {
                console.log(data);
                if (data.error) {
                    alert("Issue logging out.");
                } else {
                    alert("You're now logged out.");
                }
            }
        });
    } else {
        alert("No token");
    }
});
