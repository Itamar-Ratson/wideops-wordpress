<?php
/*
Plugin Name: Meow Lightbox
Plugin URI: http://meowapps.com/meow-lightbox
Description: Lightbox designed by and for photographers.
Version: 1.0.9
Author: Jordy Meow, Thomas KIM
Author URI: http://meowapps.com
Text Domain: meow-lightbox
Domain Path: /languages
*/

if ( class_exists( 'Meow_Lightbox_Core' ) ) {
  function mwl_admin_notices() {
    echo '<div class="error"><p>Thanks for installing the Pro version of Meow Lightbox :) However, the free version is still enabled. Please disable or uninstall it.</p></div>';
  }
  add_action( 'admin_notices', 'mwl_admin_notices' );
  return;
}

if ( !get_transient( 'mwl_february_offer' ) ) {

  function mwl_february_offer_admin_notices() {
    echo '<div class="notice notice-success"><p>Happy New Year from the Meow Lightbox Team :)<br />Until the end of March 2018, we offer you a <b>free license</b>. Just write a nice review for the Meow Lightbox <a target="_blank" href="https://wordpress.org/support/plugin/meow-lightbox/reviews/?rate=5#new-post">here</a>, then contact us <a target="_blank" href="https://meowapps.com/contact">here</a>.</p>';
    echo '<p>
      <form method="post" action="">
        <input type="hidden" name="mwl_never_remind_me_february_offer" value="true">
        <input type="submit" name="submit" id="submit" class="button" value="I did it or I am not interested, hide this.">
      </form>
    </p>
    ';
    echo '</div>';
  }

  if ( isset( $_POST['mwl_never_remind_me_february_offer'] ) ) {
    set_transient( 'mwl_february_offer', 'hide', 60 * 60 * 24 * 100 );
  }
  else
    add_action( 'admin_notices', 'mwl_february_offer_admin_notices' );
}

global $mwl_version;
$mwl_version = '1.0.9';

// Core
include "mwl_core.php";
$mwl_core = new Meow_Lightbox_Core;

// Admin
require( 'mwl_admin.php' );
$mwl_admin = new Meow_MWL_Admin( 'mwl', __FILE__, 'meow-lightbox' );
