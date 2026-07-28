<?php

include "common/admin.php";

class Meow_MWL_Admin extends MeowApps_Admin {

	public function __construct( $prefix, $mainfile, $domain ) {
		parent::__construct( $prefix, $mainfile, $domain );
		if ( is_admin() ) {
			add_action( 'admin_menu', array( $this, 'app_menu' ) );
			add_action( 'admin_notices', array( $this, 'admin_notices' ) );
		}
	}

	function admin_notices() {
		if ( !function_exists( "exif_read_data" ) ) {
			?>
	    <div class="notice notice-error is-dismissible">
	        <p><?php _e( 'The function "exif_read_data" is not accessible on your server. Please ask your hosting service to enable the "php_exif" module otherwise the Meow Lightbox will not work.', 'meow-lightbox' ); ?></p>
	    </div>
	    <?php
		}
	}

	function common_url( $file ) {
		return trailingslashit( plugin_dir_url( __FILE__ ) ) . 'common/' . $file;
	}

	function app_menu() {

		$value = get_option( 'mwl_selector', '.entry-content, .gallery' );
		if ( empty( $value ) ) {
			update_option( 'mwl_selector', '.entry-content, .gallery' );
		}

		// SUBMENU > Settings
		add_submenu_page( 'meowapps-main-menu', 'Lightbox', 'Lightbox', 'manage_options',
			'mwl_settings-menu', array( $this, 'admin_settings' ) );

			// SUBMENU > Settings > Display
			add_settings_section( 'mwl_settings', null, null, 'mwl_settings-menu' );
			add_settings_field( 'mwl_layout', __( "Layout", 'meow-lightbox' ),
				array( $this, 'admin_layout_callback' ),
				'mwl_settings-menu', 'mwl_settings' );
			//add_settings_section( 'mwl_settings', null, null, 'mwl_settings-menu' );
			add_settings_field( 'mwl_theme', __( "Theme", 'meow-lightbox' ),
				array( $this, 'admin_theme_callback' ),
				'mwl_settings-menu', 'mwl_settings' );
			add_settings_field( 'mwl_map', "Location Map<br />(Pro)",
				array( $this, 'admin_map_callback' ),
				'mwl_settings-menu', 'mwl_settings' );

			// SUBMENU > Settings > EXIF Info
			add_settings_section( 'mwl_exif_info', null, null, 'mwl_settings-menu-exif_info' );
			add_settings_field( 'mwl_title', __( "Display", 'meow-lightbox' ), array( $this, 'admin_title_callback' ),
				'mwl_settings-menu-exif_info', 'mwl_exif_info' );
			add_settings_field( 'mwl_caption_origin', "Caption<br /><small>(under title in lightbox)</small>",
				array( $this, 'admin_caption_origin_callback' ), 'mwl_settings-menu-exif_info', 'mwl_exif_info' );

				// SUBMENU > Settings > EXIF Info
				add_settings_section( 'mwl_photography_layout', null, null, 'mwl_settings-menu-photography_layout' );
				// add_settings_field( 'mwl_title', "Display", array( $this, 'admin_title_callback' ),
				// 	'mwl_settings-menu-photography_layout', 'mwl_photography_layout' );
				// add_settings_field( 'mwl_caption_origin', "Caption<br /><small>(under title in lightbox)</small>",
				// 	array( $this, 'admin_caption_origin_callback' ), 'mwl_settings-menu-photography_layout', 'mwl_exif_info' );

			// SUBMENU > Settings > Advanced
			add_settings_section( 'mwl_advanced', null, null, 'mwl_settings-menu-advanced' );
			add_settings_field( 'mwl_selector', __( "Selector", 'meow-lightbox' ),
				array( $this, 'admin_selector_callback' ),
				'mwl_settings-menu-advanced', 'mwl_advanced' );
			add_settings_field( 'mwl_preloading', "Preloading<br />(Pro)",
				array( $this, 'admin_preloading_callback' ),
				'mwl_settings-menu-advanced', 'mwl_advanced' );
			add_settings_field( 'mwl_display_missing_images', "Display Missing Images",
				array( $this, 'admin_display_missing_images_callback' ),
				'mwl_settings-menu-advanced', 'mwl_advanced' );

			// SUBMENU > Settings > Map
			add_settings_section( 'mwl_map', null, null, 'mwl_settings-menu-map' );
			// add_settings_field( 'mwl_map_position', "Position",
			// 	array( $this, 'admin_map_position_callback' ),
			// 	'mwl_settings-menu-map', 'mwl_map' );
			// add_settings_field( 'mwl_map_margin', "Margin",
			// 	array( $this, 'admin_map_margin_callback' ),
			// 	'mwl_settings-menu-map', 'mwl_map' );
			// add_settings_field( 'mwl_map_size', "Size",
			// 	array( $this, 'admin_map_size_callback' ),
			// 	'mwl_settings-menu-map', 'mwl_map' );
			add_settings_field( 'mwl_map_api_key', __( "API Key", 'meow-lightbox' ),
				array( $this, 'admin_map_api_key_callback' ),
				'mwl_settings-menu-map', 'mwl_map' );
			add_settings_field( 'mwl_map_style', __( "Style", 'meow-lightbox' ),
				array( $this, 'admin_map_style_callback' ),
				'mwl_settings-menu-map', 'mwl_map' );

		// SETTINGS
		register_setting( 'mwl_settings', 'mwl_layout' );
		register_setting( 'mwl_settings', 'mwl_theme' );
		register_setting( 'mwl_settings', 'mwl_map' );

		register_setting( 'mwl_settings-advanced', 'mwl_selector' );
		register_setting( 'mwl_settings-advanced', 'mwl_preloading' );
		register_setting( 'mwl_settings-advanced', 'mwl_display_missing_images' );

		//register_setting( 'mwl_settings-photography_layout', 'mwl_caption_origin' );

		register_setting( 'mwl_settings-exif_info', 'mwl_caption_origin' );
		register_setting( 'mwl_settings-exif_info', 'mwl_exif_title' );
		register_setting( 'mwl_settings-exif_info', 'mwl_exif_caption' );
		register_setting( 'mwl_settings-exif_info', 'mwl_exif_camera' );
		register_setting( 'mwl_settings-exif_info', 'mwl_exif_lens' );
		register_setting( 'mwl_settings-exif_info', 'mwl_exif_shutter_speed' );
		register_setting( 'mwl_settings-exif_info', 'mwl_exif_aperture' );
		register_setting( 'mwl_settings-exif_info', 'mwl_exif_focal_length' );
		register_setting( 'mwl_settings-exif_info', 'mwl_exif_iso' );

		// register_setting( 'mwl_settings-map', 'mwl_map_position' );
		// register_setting( 'mwl_settings-map', 'mwl_map_margin' );
		// register_setting( 'mwl_settings-map', 'mwl_map_size' );
		register_setting( 'mwl_settings-map', 'mwl_map_api_key' );
		register_setting( 'mwl_settings-map', 'mwl_map_style' );
	}

	function admin_settings() {
		?>
		<div class="wrap meow-admin">
		<?php echo $this->display_title( "Meow Lightbox" , "By Jordy Meow & Thomas Kim");  ?>
		<p>This lightbox will display your photography beautifully.</p>

		<div class="meow-row">

			<div class="meow-col meow-span_1_of_2">

				<div class="meow-box">
					<form method="post" action="options.php">
						<h3><span class="dashicons dashicons-admin-tools"></span> DISPLAY</h3>
						<div class="inside">
							<?php settings_fields( 'mwl_settings' ); ?>
							<?php do_settings_sections( 'mwl_settings-menu' ); ?>
							<?php submit_button(); ?>
						</div>
					</form>
				</div>

				<!-- <?php if ( get_option( 'mwl_layout', 'photography' ) == 'photography' ): ?>
				<div class="meow-box">
					<form method="post" action="options.php">
							<h3><span class="dashicons dashicons-admin-tools"></span> PHOTOGRAPHY LAYOUT</h3>
							<div class="inside">
								<?php settings_fields( 'mwl_settings-photography_layout' ); ?>
								<?php do_settings_sections( 'mwl_settings-menu-photography_layout' ); ?>
								<?php submit_button(); ?>
							</div>
					</form>
				</div>
				<?php endif; ?> -->

				<?php if ( get_option( 'mwl_layout', 'photography' ) == 'photography' ): ?>
				<div class="meow-box">
					<form method="post" action="options.php">
							<h3><span class="dashicons dashicons-admin-tools"></span> EXIF INFO</h3>
							<div class="inside">
								<?php settings_fields( 'mwl_settings-exif_info' ); ?>
								<?php do_settings_sections( 'mwl_settings-menu-exif_info' ); ?>
								<?php submit_button(); ?>
							</div>
					</form>
				</div>
				<?php endif; ?>

			</div>

			<div class="meow-col meow-span_1_of_2">

				<?php $this->display_serialkey_box( "https://meowapps.com/meow-lightbox/" ); ?>

				<?php if ( get_option( 'mwl_map', false ) ): ?>
				<div class="meow-box">
					<form method="post" action="options.php">
							<h3><span class="dashicons dashicons-admin-tools"></span> MAP</h3>
							<div class="inside">
								<?php settings_fields( 'mwl_settings-map' ); ?>
								<?php do_settings_sections( 'mwl_settings-menu-map' ); ?>
								<?php submit_button(); ?>
							</div>
					</form>
				</div>
				<?php endif; ?>

				<div class="meow-box">
					<form method="post" action="options.php">
						<h3><span class="dashicons dashicons-admin-tools"></span> ADVANCED</h3>
						<div class="inside">
							<?php settings_fields( 'mwl_settings-advanced' ); ?>
							<?php do_settings_sections( 'mwl_settings-menu-advanced' ); ?>
							<?php submit_button(); ?>
						</div>
					</form>
				</div>

			</div>

		</div>


		</div>
		<?php
	}

	/*
		OPTIONS CALLBACKS
	*/

	function admin_layout_callback( $args ) {
		$layouts = array(
			'photography' => array( 'name' => 'Photography',
				'desc' => "Display your photo and its data (default)." ),
			'standard' => array( 'name' => 'Standard',
				'desc' => "Full-screen, similar as most lightboxes." ),
		);
		$html = '';
		foreach ( $layouts as $key => $arg )
			$html .= '<img width="70" style="float: left; margin-right: 20px; margin-top: -10px;"
				src="' . plugin_dir_url(__FILE__) . 'img/layout-' . $key . '.png" />' .
				'<input type="radio" class="radio" id="mwl_layout" name="mwl_layout" value="' . $key . '"' .
				checked( $key, get_option( 'mwl_layout', 'photography' ), false ) . ' > '  .
				( empty( $arg ) ? 'None' : $arg['name'] ) .
				( empty( $arg ) ? '' : '<br/><small>' . $arg['desc'] . '</small>' ) .
				'<br /><br /><div style="clear: both;">';
		echo $html;
	}

	function admin_theme_callback( $args ) {
		$themes = array(
			'dark' => array( 'name' => 'Dark (default)', 'desc' => "" ),
			'light' => array( 'name' => 'Light', 'desc' => "" ),
		);
		$html = '';
		foreach ( $themes as $key => $arg )
			$html .= '<input type="radio" class="radio" id="mwl_theme" name="mwl_theme" value="' . $key . '"' .
				checked( $key, get_option( 'mwl_theme', 'dark' ), false ) . ' > '  .
				( empty( $arg ) ? 'None' : $arg['name'] ) .
				( empty( $arg ) ? '' : '<br/><small>' . $arg['desc'] . '</small>' );
		echo $html;
	}

	function admin_map_callback( $args ) {
		$html = '<input ' . disabled( $this->is_registered(), false, false ) .
			' type="checkbox" id="mwl_map" name="mwl_map" value="1" ' .
			checked( 1, get_option( 'mwl_map' ), false ) . '/>';
    $html .= '<label>Enabled</label><br /><small>The location of the photos will be displayed on a little map. On click, the map will be be enlarged to the entire lightbox.</small>';
    echo $html;
  }

	function admin_selector_callback( $args ) {
    $value = get_option( 'mwl_selector', '.entry-content, .gallery' );
    $html = '<input type="text" id="mwl_selector" name="mwl_selector" value="' . $value . '" />';
    $html .= '<br /><span class="description">This selector will be used to apply the lightbox to the images.</span>';
    echo $html;
  }

	function admin_preloading_callback( $args ) {
		$html = '<input ' . disabled( $this->is_registered(), false, false ) .
			' type="checkbox" id="mwl_preloading" name="mwl_preloading" value="1" ' .
			checked( 1, get_option( 'mwl_preloading' ), false ) . '/>';
    $html .= '<label>Enabled</label><br /><small>Once the lightbox is started, the next images will be preloaded to offer a better experience to the user.</small>';
    echo $html;
  }

	function admin_display_missing_images_callback( $args ) {
		$html = '<input type="checkbox" id="mwl_display_missing_images" name="mwl_display_missing_images" value="1" ' .
			checked( 1, get_option( 'mwl_display_missing_images', true ), false ) . '/>';
    $html .= '<label>Enabled</label><br /><small>Display warnings in case the Lightbox cannot find the image (useful for debugging).</small>';
    echo $html;
  }

	function admin_title_callback( $args ) {
		$html = '<input type="checkbox" id="mwl_exif_title" name="mwl_exif_title" value="1" ' .
			checked( 1, get_option( 'mwl_exif_title', true ), false ) . '/>';
    $html .= '<label>Title</label><br />';
		$html .= '<input type="checkbox" id="mwl_exif_caption" name="mwl_exif_caption" value="1" ' .
			checked( 1, get_option( 'mwl_exif_caption', true ), false ) . '/>';
    $html .= '<label>Caption</label><br />';
		$html .= '<input type="checkbox" id="mwl_exif_camera" name="mwl_exif_camera" value="1" ' .
			checked( 1, get_option( 'mwl_exif_camera', true ), false ) . '/>';
    $html .= '<label>Camera</label><br />';
		$html .= '<input type="checkbox" id="mwl_exif_lens" name="mwl_exif_lens" value="1" ' .
			checked( 1, get_option( 'mwl_exif_lens', true ), false ) . '/>';
    $html .= '<label>Lens</label><br />';
		$html .= '<input type="checkbox" id="mwl_exif_shutter_speed" name="mwl_exif_shutter_speed" value="1" ' .
			checked( 1, get_option( 'mwl_exif_shutter_speed', true ), false ) . '/>';
    $html .= '<label>Shutter Speed</label><br />';
		$html .= '<input type="checkbox" id="mwl_exif_aperture" name="mwl_exif_aperture" value="1" ' .
			checked( 1, get_option( 'mwl_exif_aperture', true ), false ) . '/>';
    $html .= '<label>Aperture</label><br />';
		$html .= '<input type="checkbox" id="mwl_exif_focal_length" name="mwl_exif_focal_length" value="1" ' .
			checked( 1, get_option( 'mwl_exif_focal_length', true ), false ) . '/>';
    $html .= '<label>Focal Length</label><br />';
		$html .= '<input type="checkbox" id="mwl_exif_iso" name="mwl_exif_iso" value="1" ' .
			checked( 1, get_option( 'mwl_exif_iso', true ), false ) . '/>';
    $html .= '<label>ISO</label><br />';
    echo $html;
  }

	function admin_caption_origin_callback( $args ) {
		$origins = array(
			'caption' => array( 'name' => 'Caption (default)' ),
			'description' => array( 'name' => 'Description' ),
			'none' => array( 'name' => 'None' ),
		);
		$html = '';
		foreach ( $origins as $key => $arg )
			$html .= '<input type="radio" class="radio" id="mwl_caption_origin" name="mwl_caption_origin" value="' . $key . '"' .
				checked( $key, get_option( 'mwl_caption_origin', 'caption' ), false ) . ' > '  .
				( empty( $arg ) ? 'None' : $arg['name'] ) . '<br />';
		echo $html;
	}

	// function admin_map_position_callback( $args ) {
	// 	$positions = array(
	// 		'top-left' => array( 'name' => 'Top Left' ),
	// 		'top-right' => array( 'name' => 'Top Right' ),
	// 		'bottom-left' => array( 'name' => 'Bottom Left' ),
	// 		'bottom-right' => array( 'name' => 'Bottom Right (Default)' )
	// 	);
	// 	$html = '';
	// 	foreach ( $positions as $key => $arg )
	// 		$html .= '<input type="radio" class="radio" id="mwl_map_position" name="mwl_map_position" value="' . $key . '"' .
	// 			checked( $key, get_option( 'mwl_map_position', 'bottom-right' ), false ) . ' > '  .
	// 			( empty( $arg ) ? 'None' : $arg['name'] ) . '<br /><div style="clear: both;">';
	// 	echo $html;
	// }

	// function admin_map_margin_callback( $args ) {
  //   $value = get_option( 'mwl_map_margin', 10 );
  //   $html = '<input type="number" id="mwl_map_margin" name="mwl_map_margin" value="' . $value . '" />';
  //   $html .= '<br /><span class="description">Margins <b>in pixels</b> around the map (default: 10).</span>';
  //   echo $html;
  // }
	//
	// function admin_map_size_callback( $args ) {
  //   $value = get_option( 'mwl_map_size', 70 );
  //   $html = '<input type="number" id="mwl_map_size" name="mwl_map_size" value="' . $value . '" />';
  //   $html .= '<br /><span class="description">Size <b>in pixels</b> of the little map (default: 70).</span>';
  //   echo $html;
  // }

	function admin_map_api_key_callback( $args ) {
    $value = get_option( 'mwl_map_api_key', "" );
    $html = '<input type="text" id="mwl_map_api_key" name="mwl_map_api_key" value="' . $value . '" />';
    $html .= '<br /><span class="description">' . __( 'Generate it for free here: <a target="_blank" href="https://developers.google.com/maps/documentation/javascript/get-api-key">Get a Google Maps API Key</a>.', 'meow-lightbox' ) . '</span>';
    echo $html;
  }

	function admin_map_style_callback( $args ) {
    $value = get_option( 'mwl_map_style', $this->create_default_style() );
		$value = json_encode( json_decode( $value ), JSON_PRETTY_PRINT );
		if ( empty( $value ) || $value == 'null' ) {
			echo '<p style="color: red; margin-bottom: 5px;">' . __( "The format of the style must be valid JSON. To avoid errors, it was reverted to the default style.", 'meow-lightbox' ) . "</p>";
			$value = $this->create_default_style( true );
			$value = json_encode( json_decode( $value ), JSON_PRETTY_PRINT );
		}
    $html = '<textarea rows="8" id="mwl_map_style" style="width: 100%;" name="mwl_map_style">' . $value . '</textarea>';
    $html .= '<br /><span class="description">' . __( 'Google Map Style JSON. You can find a lot of beautiful templates ready to use here: <a target="_blank" href="https://snazzymaps.com/">SnazzyMaps.com</a>. Remove it and it will reset to the default style.', 'meow-lightbox' ) . '</span>';
    echo $html;
  }

	function create_default_style( $force = false ) {
		$style = get_option( 'mwl_map_style', "" );
		if ( $force || empty( $style ) ) {
			$style = '[{"featureType":"landscape.man_made","elementType":"geometry","stylers":[{"color":"#f7f1df"}]},{"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#d0e3b4"}]},{"featureType":"landscape.natural.terrain","elementType":"geometry","stylers":[{"visibility":"simplified"}]},{"featureType":"poi","elementType":"labels","stylers":[{"visibility":"off"}]},{"featureType":"poi.business","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#bde6ab"},{"visibility":"simplified"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"visibility":"off"}]},{"featureType":"road","elementType":"labels","stylers":[{"visibility":"off"}]},{"featureType":"road.highway","elementType":"geometry.fill","stylers":[{"color":"#ffe15f"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#efd151"}]},{"featureType":"road.arterial","elementType":"geometry.fill","stylers":[{"color":"#ffffff"}]},{"featureType":"road.local","elementType":"geometry.fill","stylers":[{"color":"black"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#a2daf2"}]}]';
			update_option( 'mwl_map_style', $style );
		}
		return $style;
	}

}

?>
