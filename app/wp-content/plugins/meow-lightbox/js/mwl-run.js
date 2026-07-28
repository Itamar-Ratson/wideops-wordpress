/*
	This file is linking the front-end events with the JS logic in mwl-core.js
*/

jQuery(document).ready(function($) {

    var settings = {
            layout: mwl.settings.layout,
            expanded_image: false,
            selector: mwl.settings.selector,
            display_missing_images: mwl.settings.display_missing_images,
            theme: mwl.settings.theme,
            allow_expand: true, // TO LINK WITH PHP OPTION
            allow_fullscreen: false, // TO LINK WITH PHP OPTION, /!\STILL IN BETA/!\
            slideshow: { // Still in dev
                enable: false,
                slide_duration: 3000
            },
            preloading: mwl.settings.preloading,
            orientation_responsive: { // TO LINK WITH PHP OPTION / PRO OPTION ?
                enabled: true,
                orientation: 'landscape' // If disabled, which layout to use by default
            },
            map: mwl.settings.map,
            infos_to_display: {
                title: mwl.settings.exif.title,
                caption: mwl.settings.exif.caption,
                camera: mwl.settings.exif.camera,
                lens: mwl.settings.exif.lens,
                shutter_speed: mwl.settings.exif.shutter_speed,
                aperture: mwl.settings.exif.aperture,
                focal_length: mwl.settings.exif.focal_length,
                iso: mwl.settings.exif.iso
            }
        };

    var mwlController = new MwlController(settings);
    mwlController.init();

    $(document).on('click', '.mwl-img', function(e) {
        e.preventDefault();
        var image_index = $(this).attr('mwl-index'),
            mwl_img = mwlController.getMwlImageByIndex(image_index);
        mwlController.showLightbox(mwl_img, settings.layout, settings.theme);
    });

	/**
	 * Load the next image
	 * @return void
	 */
	function go_to_next_image() {
		next_index = mwlController.getNextIndex();
		next_image = mwlController.getMwlImageByIndex(next_index);
		mwlController.changeLightboxImage(next_image, settings.layout, settings.theme, "next");
	}

	/**
	 * Load the previous image
	 * @return void
	 */
	function go_to_prev_image() {
		prev_index = mwlController.getPrevIndex();
		prev_image = mwlController.getMwlImageByIndex(prev_index);
		mwlController.changeLightboxImage(prev_image, settings.layout, settings.theme, "previous");
	}

	/**
	 * Close the lightbox & cancel fullscreen mode
	 * @return void
	 */
	function close_lightbox() {
		if (mwlController.isFullscreen()) {
			mwlController.toggleFullScreen();
		}
		mwlController.closeLightbox();
	}

    $(document).on('click', '.mwl-container:not(invisible)', function(e) {
        var prev_index, prev_image, next_index, next_image;
        e.stopPropagation();
		// Closing Lightbox
        if ($(e.target).is($('.control-close')) || $(e.target).is($('.control-close i'))) {
            close_lightbox();
        }
        // Expanding Image
        if ($(e.target).is($('.control-expand')) || $(e.target).is($('.control-expand i'))) {
            mwlController.expandImage();
        }
        // Going / Exiting FullScreen
        if ($(e.target).is($('.control-fullscreen')) || $(e.target).is($('.control-fullscreen i'))) {
            mwlController.toggleFullScreen(document.body);
            //mwlController.resizeImg(function() {});
        }
        // Shrinking Image
        if ($(e.target).is($('.control-shrink')) || $(e.target).is($('.control-shrink i'))) {
            mwlController.shrinkImage();
        }
		// Previous Image
        if ($(e.target).is($('.control-previous')) || $(e.target).is($('.control-previous i'))) {
            go_to_prev_image();
        }
		// Next Image
        if ($(e.target).is($('.control-next')) || $(e.target).is($('.control-next i'))) {
            go_to_next_image();
        }
        if ($(e.target).is($('.mwl-img-container')) ||
            $(e.target).is($('.mwl-img-infos')) ||
            $(e.target).is($('.mwl-img-infos h1')) ) {
            close_lightbox();
        }
    });

    $(document).on('hover', '.mwl-img-container', function() {
        $(".mwl-img-container").swipe( {
            //Generic swipe handler for all directions
            swipe:function(event, direction, distance, duration, fingerCount, fingerData) {
                if(direction == 'left') {
                    go_to_next_image();
                }
                if(direction == 'right') {
                    go_to_prev_image();
                }
            },
            //Default is 75px, set to 0 for demo so any distance triggers swipe
            threshold:0
        } );
    });

	// Keyboard Controls
    $(document).keydown(function(e) {
		// If lightbox is visible
        if (!$('.mwl-container').hasClass('invisible')) {
            var prev_index, prev_image, next_index, next_image;
            switch (e.which) {
                case 37: // left : previous image
					go_to_prev_image();
                    break;

                case 39: // right : next image
					go_to_next_image();
                    break;

                case 27: // esc : close lightbox
					close_lightbox();
                    break;

                default:
                    return; // exit this handler for other keys
            }
            e.preventDefault(); // prevent the default action (scroll / move caret)
        }
    });

    $(window).on('resize', function() {

    });

});
