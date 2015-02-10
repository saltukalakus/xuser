$('document').ready(function() {
    $('#login').on("click", function(e) {
        var email = $('.email').val();
        var password = $('.password').val();
        $.ajax({
            type: "POST",
            cache: false,
            dataType: "json",
            url: "/token/",
            data: {email:email, password:password},
            success: function(data){
                Store.setUser({email: email, token: data.token});
                console.log("Finished setting user: " + email + ", Token: " + data.token);
                alert("You're now logged in. Try clicking the 'Test Token' button next.");
            },
            error: function(data) {
                alert(data.statusText);
            }
        });
    });
};