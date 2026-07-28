<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('FS_METHOD','direct');
define('DB_NAME', 'wordpress');

/** MySQL database username */
define('DB_USER', 'wordpress');

/** MySQL database password */
define('DB_PASSWORD', 'Foxtrot01');

/** MySQL hostname */
define('DB_HOST', 'localhost');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8mb4');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'M{qF(EaD;RnC/tK%:7X|TKJe0sX *MQY_uA,uhrUtxX0pf+KKg1ol{39ct#a]Gkt');
define('SECURE_AUTH_KEY',  'K-z8;j)TJl%H1:]-m1b25<?E3,B@!T`>R =Dw1gG3d,r6hc^Nz:x+AMm |FVO5K?');
define('LOGGED_IN_KEY',    '`gh1-@`i`[M3FB9~T8ue>lOF;S*&Tx^gR? YM8sf>Hpq?o+UauNv<jR4rd$Q#y!Z');
define('NONCE_KEY',        '-M)EnDd9g,/[~8SA5<v5%H. Ej+[Bb~_J`pmE7h5?7+[snH0qcIgD=bW&/(o$TZX');
define('AUTH_SALT',        'R5 T~=e5kF2d2 b&4TW>LW!B|7]S|XQKwAH9AeDb#Ed=>SDjioT_dV>C&Bw%f8ml');
define('SECURE_AUTH_SALT', 'N(+Kvo@tFq,Qf+3oCRds~Oni}Zq^t&2[v/Ec.<H;[VJwS;]Tc=:~H@&}8-4r)`WR');
define('LOGGED_IN_SALT',   'tOs-`:k+_xfhM?M6Aeh1/Ym7>f;{TQ(_mQHu->1;$Z% m7McDrFU7^x:dc}Yu;Aq');
define('NONCE_SALT',       'iI49z5%45S+^_AKEP+k[w1RTc;A9+Crx Dn.h<N;ix@@[JueC$acyw!|iz^VwG0W');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
