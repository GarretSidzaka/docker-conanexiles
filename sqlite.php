
<?php
require("plugins/login-password-less.php");
// TODO: inline the result of password_hash() so that the password is not visible in source codes
return new AdminerLoginPasswordLess(password_hash("admin", PASSWORD_DEFAULT));
