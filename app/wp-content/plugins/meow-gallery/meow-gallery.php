<?php
/*
Plugin Name: Meow Gallery
Plugin URI: https://meowapps.com
Description: Gallery system built for photographers, by photographers.
Version: 1.0.7
Author: Jordy Meow, Thomas Kim
Author URI: https://meowapps.com
Text Domain: meow-gallery
Domain Path: /languages

Dual licensed under the MIT and GPL licenses:
http://www.opensource.org/licenses/mit-license.php
http://www.gnu.org/licenses/gpl.html

Originally developed for two of my websites:
- Jordy Meow (http://offbeatjapan.org)
- Haikyo (http://haikyo.org)
*/


if ( class_exists( 'Meow_Gallery_Core' ) ) {
  function mfrh_admin_notices() {
    echo '<div class="error"><p>Thanks for installing the Pro version of Meow Gallery :) However, the free version is still enabled. Please disable or uninstall it.</p></div>';
  }
  add_action( 'admin_notices', 'mfrh_admin_notices' );
  return;
}

if ( !get_transient( 'mgl_february_offer' ) ) {

  function mgl_february_offer_admin_notices() {
    echo '<div class="notice notice-success"><p>Happy New Year from the Meow Gallery Team :)<br />Until the end of March 2018, we offer you a <b>free license</b>. Just write a nice review for the Meow Gallery <a target="_blank" href="https://wordpress.org/support/plugin/meow-gallery/reviews/?rate=5#new-post">here</a>, then contact us <a target="_blank" href="https://meowapps.com/contact">here</a>.</p>';
    echo '<p>
      <form method="post" action="">
        <input type="hidden" name="mgl_never_remind_me_february_offer" value="true">
        <input type="submit" name="submit" id="submit" class="button" value="I did it or I am not interested, hide this.">
      </form>
    </p>
    ';
    echo '</div>';
  }

  if ( isset( $_POST['mgl_never_remind_me_february_offer'] ) )
    set_transient( 'mgl_february_offer', 'hide', 60 * 60 * 24 * 100 );
  else
    add_action( 'admin_notices', 'mgl_february_offer_admin_notices' );
}

global $mgl_version;
$mgl_version = '1.0.7';

// Admin
include "mgl_admin.php";
$mgl_admin = new Meow_MGL_Admin( 'mgl', __FILE__, 'meow-gallery' );

// Core
include "mgl_core.php";
$mgl_core = new Meow_Gallery_Core( $mgl_admin );

?>
