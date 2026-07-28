<?php
/**
 * @package Lucienne
 */

/**
 * Set up the WordPress core custom header feature.
 *
 * @uses Lucienne_header_style()
 * @uses Lucienne_admin_header_style()
 * @uses Lucienne_admin_header_image()
 */
function Lucienne_custom_header_setup() {
	add_theme_support( 'custom-header', apply_filters( 'Lucienne_custom_header_args', array(
		'default-image'          => '',
		'default-text-color'     => '495762',
		'width'                  => 1600,
		'height'                 => 420,
		'flex-height'            => true,
		'wp-head-callback'       => 'Lucienne_header_style',
		'admin-head-callback'    => 'Lucienne_admin_header_style',
		'admin-preview-callback' => 'Lucienne_admin_header_image',
	) ) );
}
add_action( 'after_setup_theme', 'Lucienne_custom_header_setup' );

if ( ! function_exists( 'Lucienne_header_style' ) ) :
/**
 * Styles the header image and text displayed on the blog
 *
 * @see Lucienne_custom_header_setup().
 */
function Lucienne_header_style() {
	$header_text_color = get_header_textcolor();
	$header_image = get_header_image();

	if ( $header_image ) : ?>

		<style type="text/css" id="custom-header-image">
			.site-branding:before {
				background-image: url( <?php echo esc_url( $header_image ); ?>);
				background-position: center;
				background-repeat: no-repeat;
				background-size: cover;
				content: "";
				display: block;
				position: absolute;
				top: 0;
				left: 0;
				width: 100%;
				height: 100%;
				z-index:-1;
			}
		</style>
	<?php
	endif;

	// If no custom options for text are set, let's bail
	// get_header_textcolor() options: HEADER_TEXTCOLOR is default, hide text (returns 'blank') or any hex value.
	if ( get_theme_support( 'custom-header', 'default-text-color' ) === $header_text_color ) {
		return;
	}

	// If we get this far, we have custom styles. Let's do this.
	?>
	<style type="text/css">
	<?php
		// Has the text been hidden?
		if ( 'blank' == $header_text_color ) :
	?>
		.site-title,
		.site-description {
			position: absolute;
			clip: rect(1px, 1px, 1px, 1px);
		}
	<?php
		// If the user has set a custom color for the text use that.
		else :
	?>
		.site-title a,
		.site-description {
			color: #<?php echo esc_attr( $header_text_color ); ?>;
		}
	<?php endif; ?>
	</style>
	<?php
}
endif; // Lucienne_header_style

if ( ! function_exists( 'Lucienne_admin_header_style' ) ) :
/**
 * Styles the header image displayed on the Appearance > Header admin panel.
 *
 * @see Lucienne_custom_header_setup().
 */
function Lucienne_admin_header_style() {
?>
	<style type="text/css">
		.appearance_page_custom-header #headimg {
			border: none;
		}
		#headimg h1,
		#desc {
		}
		#headimg h1 {
		}
		#headimg h1 a {
		}
		#desc {
		}
		#headimg img {
		}
	</style>
<?php
}
endif; // Lucienne_admin_header_style

if ( ! function_exists( 'Lucienne_admin_header_image' ) ) :
/**
 * Custom header image markup displayed on the Appearance > Header admin panel.
 *
 * @see Lucienne_custom_header_setup().
 */
function Lucienne_admin_header_image() {
?>
	<div id="headimg">
		<h1 class="displaying-header-text">
			<a id="name" style="<?php echo esc_attr( 'color: #' . get_header_textcolor() ); ?>" onclick="return false;" href="<?php echo esc_url( home_url( '/' ) ); ?>"><?php bloginfo( 'name' ); ?></a>
		</h1>
		<div class="displaying-header-text" id="desc" style="<?php echo esc_attr( 'color: #' . get_header_textcolor() ); ?>"><?php bloginfo( 'description' ); ?></div>
		<?php if ( get_header_image() ) : ?>
		<img src="<?php header_image(); ?>" alt="">
		<?php endif; ?>
	</div>
<?php
}
endif; // Lucienne_admin_header_image
