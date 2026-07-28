<?php

class Meow_Lightbox_Core {

	public function __construct() {
		add_action( 'init', array( $this, 'init' ) );
		if ( !is_admin() ) {
			add_action( 'init', array( $this, 'init_client' ) );
			add_filter( 'wp_get_attachment_image_attributes', array( $this, 'add_attachment_id_on_images' ), 10, 2 );
		}

	}

	function init() {
		load_plugin_textdomain( 'meow-lightbox', false, dirname( plugin_basename( __FILE__ ) ) . '/languages/' );
	}

	function init_client() {
    global $mwl_version;
		$home_url = function_exists( 'pll_home_url' ) ? pll_home_url() : get_home_url();
    wp_enqueue_script( 'jquery' );
		wp_enqueue_script( 'imagesLoaded', plugins_url( '/js/imagesloaded.min.js', __FILE__ ),
			array( 'jquery' ), $mwl_version, false);
		wp_enqueue_script( 'touchSwipe', plugins_url( '/js/touchswipe.js', __FILE__ ),
			array( 'jquery' ), $mwl_version, false);
		wp_enqueue_script( 'mwl-core-js', plugins_url( '/js/mwl-core.js', __FILE__ ),
			array( 'jquery', 'imagesLoaded', 'touchSwipe' ), $mwl_version, false );
		wp_enqueue_script( 'mwl-run-js', plugins_url( '/js/mwl-run.js', __FILE__ ),
			array( 'jquery', 'mwl-core-js'), $mwl_version, false );
		wp_localize_script('mwl-run-js', 'mwl',
			array(
				'plugin_url' => plugin_dir_url(__FILE__),
				'url_api' => $home_url . '/wp-json/mwl/v1/',
				'settings' => array(
					'layout' => get_option( 'mwl_layout', 'photography' ),
					'theme' => get_option( 'mwl_theme', 'dark' ),
					'selector' => get_option( 'mwl_selector', '.entry-content, .gallery' ),
					'preloading' => get_option( 'mwl_preloading', false ),
					'display_missing_images' => get_option( 'mwl_display_missing_images', true ),
					'exif' => array(
						'title' => get_option( 'mwl_exif_title', true ),
						'caption' => get_option( 'mwl_exif_caption', true ),
						'camera' => get_option( 'mwl_exif_camera', true ),
						'lens' => get_option( 'mwl_exif_lens', true ),
						'shutter_speed' => get_option( 'mwl_exif_shutter_speed', true ),
						'aperture' => get_option( 'mwl_exif_aperture', true ),
						'focal_length' => get_option( 'mwl_exif_focal_length', true ),
						'iso' => get_option( 'mwl_exif_iso', true )
					),
					'map' => array(
						'enabled' => get_option( 'mwl_map', false ),
						'api_key' => get_option( 'mwl_map_api_key', "" ),
						'style' => json_decode( get_option( 'mwl_map_style', null ) )
						// 'position' => get_option( 'mwl_map_position', 'bottom-right' ),
						// 'margin' => (int)get_option( 'mwl_map_margin', 10 ),
						// 'size' => (int)get_option( 'mwl_map_size', 70 )
					)
				)
			)
		);

    wp_enqueue_style( 'mwl-css', plugin_dir_url( __FILE__ ) . 'css/mwl.css', null, $mwl_version, 'screen' );
    wp_enqueue_style( 'ionicons', '//code.ionicframework.com/ionicons/2.0.1/css/ionicons.min.css' );
		add_action( 'rest_api_init', array( $this, 'init_rest' ) );
		add_filter( 'wp_get_attachment_image_attributes', array( $this, 'wp_get_attachment_image_attributes' ), 10, 2 );

		// Remove PrettyPhoto (Visual Composer's Lightbox)
		wp_enqueue_script( 'prettyphoto' );
		wp_deregister_script( 'prettyphoto' );
	}

	function add_attachment_id_on_images( $attr, $attachment ) {
		if( !strpos( $attr['class'], 'wp-image-' . $attachment->ID ) )
			$attr['class'] .= ' wp-image-' . $attachment->ID;
		return $attr;
	}

	/*******************************************************************************
	 * RUNNING OPERATIONS
	 ******************************************************************************/

	function wp_get_attachment_image_attributes( $attr, $attachment ) {
    if ( empty( $attr['mwl-img-id'] ) ) {
			$attr['mwl-img-id'] = $attachment->ID;
		}
    return $attr;
	}

	function init_rest() {
		register_rest_route( 'mwl/v1', '/info/(?P<id>[0-9-]+)', array(
			'methods' => 'GET',
			'callback' => array( $this, 'exif_from_id' ),
			'args' => array(
				'in' => array(
				)
			)
		) );
		register_rest_route( 'mwl/v1', '/info/ids', array(
			'methods' => 'POST',
			'callback' => array( $this, 'exif_from_ids' ),
			'args' => array(
				'in' => array(
				)
			)
		) );
		register_rest_route( 'mwl/v1', '/info/urls', array(
			'methods' => 'POST',
			'callback' => array( $this, 'exif_from_urls' ),
			'args' => array(
				'in' => array(
				)
			)
		) );
  }

	function nice_shutter_speed( $shutter_speed ) {
		$str = "";
		if ( ( 1 / $shutter_speed ) > 1) {
			$str .= "1/";
			if ( number_format( ( 1 / $shutter_speed ), 1) ==  number_format( ( 1 / $shutter_speed ), 0 ) )
				$str .= number_format( ( 1 / $shutter_speed ), 0, '.', '' ) . '';
			else
				$str .= number_format( ( 1 / $shutter_speed ), 0, '.', '' ) . '';
		}
		else
			$str .= $shutter_speed . ' sec';
		return $str;
	}

	function gps2Num( $coordPart ) {
    $parts = explode( '/', $coordPart );
    if ( count( $parts ) <= 0 )
        return 0;
    if ( count( $parts ) == 1 )
        return $parts[0];
    return floatval( $parts[0] ) / floatval( $parts[1] );
}

	function convert_gps( $exifCoord, $hemi ) {
    $degrees = count( $exifCoord ) > 0 ? $this->gps2Num( $exifCoord[0] ) : 0;
    $minutes = count( $exifCoord ) > 1 ? $this->gps2Num( $exifCoord[1] ) : 0;
    $seconds = count( $exifCoord ) > 2 ? $this->gps2Num( $exifCoord[2] ) : 0;
    $flip = ( $hemi == 'W' or $hemi == 'S' ) ? -1 : 1;
    return $flip * ( $degrees + $minutes / 60 + $seconds / 3600 );
	}

	function get_gps_data( $id, $meta ) {
		$file = get_attached_file( $id );
		$pp = pathinfo( $file );
		if ( !in_array( strtolower( $pp['extension'] ), array( 'jpg', 'jpeg', 'tiff' ) ) )
			return;
		$exif = @exif_read_data( $file );
		if ( !$exif || !isset( $exif["GPSLongitude"] ) || !isset( $exif['GPSLongitudeRef'] )
			|| !isset( $exif["GPSLatitude"] ) || !isset( $exif['GPSLatitudeRef'] ) ) {
			$meta['image_meta']['geo_coordinates'] = "";
			wp_update_attachment_metadata( $id, $meta );
			return;
		}
		$meta['image_meta']['geo_latitude'] = $this->convert_gps($exif["GPSLatitude"], $exif['GPSLatitudeRef']);
		$meta['image_meta']['geo_longitude'] = $this->convert_gps($exif["GPSLongitude"], $exif['GPSLongitudeRef']);
		$meta['image_meta']['geo_coordinates'] = $meta['image_meta']['geo_latitude']
			. ',' . $meta['image_meta']['geo_longitude'];
		wp_update_attachment_metadata( $id, $meta );
	}

	function get_exif_info( $id ) {
		$meta = wp_get_attachment_metadata( $id );
		$p = get_post( $id );

		if ( empty( $meta ) || empty( $p ) ) {
			$message = "No meta was found for this ID.";
			if ( !wp_attachment_is_image( $id ) )
				$message = "This attachment does not exist or is not an image.";
			return array(
				'success' => false,
				'message' => $message
			);
		}
		else {
			if ( !isset( $meta['image_meta']['geo_gps_coordinates'] ) ) {
				$this->get_gps_data( $id, $meta );
			}
			if ( !isset( $meta['image_meta']['lens'] ) ) {
				$file = get_attached_file( $id );
				$pp = pathinfo( $file );
				$meta['image_meta']['lens'] = "";
				if ( in_array( strtolower( $pp['extension'] ), array( 'jpg', 'jpeg', 'tiff' ) ) ) {
					$exif = @exif_read_data( $file );
					if ( $exif && isset( $exif['UndefinedTag:0xA434'] ) )
						$meta['image_meta']['lens'] = empty( $exif['UndefinedTag:0xA434'] ) ? "" : $exif['UndefinedTag:0xA434'];
				}
				wp_update_attachment_metadata( $id, $meta );
			}
			$title = $p->post_title;
			$caption =  $p->post_excerpt;
			$description = $p->post_content;
			//$alt_text = get_post_meta( $id, '_wp_attachment_image_alt', true );

			$origin = get_option( 'mwl_caption_origin', 'caption' );
			if ( $origin == 'description' )
				$lightbox_caption = $description;
			else if ( $origin == 'none' )
				$lightbox_caption = "";
			else
				$lightbox_caption = $caption;

			return array(
				'success' => true,
				'file' => wp_get_attachment_url( $id ),
				'file_srcset' => wp_get_attachment_image_srcset( $id, 'full' ),
				'file_sizes' => wp_get_attachment_image_sizes( $id ),
				'dimension' => array( 'width' => $meta['width'], 'height' => $meta['height'] ),
				'data' => array(
					'id' => (int)$id,
					// 'title' => empty( $meta['image_meta']['title'] ) ? "N/A" : $meta['image_meta']['title'],
					// 'caption' => empty( $meta['image_meta']['caption'] ) ? "N/A" : $meta['image_meta']['caption'],
					'title' => !empty( $p->post_title ) ? $p->post_title : "",
					'caption' => $lightbox_caption,
					//'description' => !empty( $description ) ? $description : "",
					'gps' => empty( $meta['image_meta']['geo_coordinates'] ) ? "N/A" : $meta['image_meta']['geo_coordinates'],
					'copyright' => empty( $meta['image_meta']['copyright'] ) ? "N/A" : $meta['image_meta']['copyright'],
					'camera' => $this->nice_camera( empty( $meta['image_meta']['camera'] ) ? "N/A" : $meta['image_meta']['camera'] ),
					'lens' => $this->nice_lens( empty( $meta['image_meta']['lens'] ) ? "N/A" : $meta['image_meta']['lens'] ),
					'aperture' => empty( $meta['image_meta']['aperture'] ) ? "N/A" : "f/" . $meta['image_meta']['aperture'],
					'focal_length' => empty( $meta['image_meta']['focal_length'] ) ? "N/A" :
						round( $meta['image_meta']['focal_length'], 0 ) . "mm",
					'iso' => empty( $meta['image_meta']['iso'] ) ? "N/A" : "ISO " . $meta['image_meta']['iso'],
					'shutter_speed' => empty( $meta['image_meta']['shutter_speed'] ) ? "N/A" : $this->nice_shutter_speed( $meta['image_meta']['shutter_speed'] )
				)
			);
		}
	}

	function clean_uploaded_filename( $fullpath ) {
		$upload_folder = wp_upload_dir();
		$basedir = $upload_folder['baseurl'];
		$file = str_replace( $basedir, '', $fullpath );
		$file = trim( $file,  "/" );
		return $file;
	}

	function find_attachment_id_from_file ( $file ) {
		global $wpdb;
		$postmeta_table_name = $wpdb->prefix . 'postmeta';
		$file = $this->clean_uploaded_filename( $file );
		$sql = $wpdb->prepare( "SELECT post_id
			FROM {$postmeta_table_name}
			WHERE meta_key = '_wp_attached_file'
			AND meta_value = %s", $file
		);
		$ret = $wpdb->get_var( $sql );
		return $ret;
	}

	function exif_from_urls( $data ) {
		$params = $data->get_params();
		if ( isset( $params['urls'] ) && is_array( $params['urls'] ) ) {
			$results = array();
			foreach ( $params['urls'] as $url ) {
				$id = $this->find_attachment_id_from_file( $url );
				$info = $this->get_exif_info( $id );
				$results[$url] = $info;
			}
			echo json_encode( array(
				'success' => true,
				'results' => $results,
				'message' => "Done."
			) );
		}
		else {
			echo json_encode( array(
				'success' => false,
				'message' => "There is no 'urls' in the body of the request."
			) );
		}
		die();
	}

	function exif_from_ids( $data ) {
		$params = $data->get_params();
		if ( isset( $params['ids'] ) && is_array( $params['ids'] ) ) {
			$results = array();
			foreach ( $params['ids'] as $id ) {
				$info = $this->get_exif_info( $id );
				$results[$id] = $info;
			}
			echo json_encode( array(
				'success' => true,
				'results' => $results,
				'message' => "Done."
			) );
		}
		else {
			echo json_encode( array(
				'success' => false,
				'message' => "There is no 'ids' in the body of the request."
			) );
		}
		die();
	}

	function exif_from_id( $data ) {
		$id = (int)$data['id'];
		$info = $this->get_exif_info( $id );
		echo json_encode( $info );
		die;
	}

	function exif_from_url( $data ) {
	}

	// This function will be improved over time
	function nice_lens( $lens ) {
		if ( empty( $lens ) )
			return $lens;
		$lenses = array(
			"70.0-200.0 mm f/2.8" => "70-200mm f/2.8",
			"24.0-70.0 mm f/2.8" => "24-70mm f/2.8",
			"14.0-24.0 mm f/2.8" => "14-24mm f/2.8",
			"EF-S17-55mm f/2.8 IS USM" => "17-55mm f/2.8",
			"----" => ""
		);
		if ( isset( $lenses[$lens] ) )
			return $lenses[$lens];
		else
			return $lens;
	}

	// This function will be improved over time
	function nice_camera( $camera ) {
		if ( empty( $camera ) )
			return $camera;
		$cameras = array(
			"ILCE-7RM2" => "SONY α7R II"
		);
		if ( isset( $cameras[$camera] ) )
			return $cameras[$camera];
		else
			return $camera;
	}

	static function installed() {
		return true;
	}

}

?>
