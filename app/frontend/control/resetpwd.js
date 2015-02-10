$('#resetPassword').on("click", function(e) {
    var $form = $(this).closest('form');
    var email = $form.find("input[name='email']").val();
    var currPass = $form.find("input[name='current_password']").val();
    var newPass = $form.find("input[name='new_password']").val();
    var confirmPass = $form.find("input[name='confirm_new_password']").val();
    if (email) {
        $.ajax({
            type: "POST",
            cache: false,
            dataType: "json",
            url: '/reset/password',
            data: {email:email, current_password:currPass, new_password: newPass, confirm_new_password: confirmPass},
            success: function() {
                alert("Password updated ... Now go to http://localhost:1337/login to log in with new password.");
            },
            error: function(data) {
                alert(data.statusText);
            }
        });
    }
});