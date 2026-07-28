/*
	This file contains all the Javascript logic
*/

jQuery(document).ready(function($) {

    var MwlImage = function(datas) {
        this.id = datas.id;
        this.index = datas.index;
        this.exists = datas.exists;
        this.img_src = datas.img_src;
        this.img_gps = datas.img_gps;
        this.img_srcset = datas.img_srcset;
        this.img_sizes = datas.img_sizes;
        this.img_dimensions = datas.img_dimensions;
        this.img_orientation = datas.img_orientation;
        this.img_exifs = datas.img_exifs;
        this.preloaded = false;
    };

    window.MwlController = function(settings) {
        var $mwl_imgs,
            mwl_imgs_number,
            current_image_index,
            display_missing_images,
            is_fullscreen = false,
            mwl_imgs_array = [],
            images_called = [];

        display_missing_images = settings.display_missing_images;

        function addClassToImgs() {
            $(settings.selector).find('img').addClass('mwl-img');
            mwl_imgs_number = $('.mwl-img').length;
        }

        function addIndexToImgs() {
            $('.mwl-img').each(function(index) {
                var $image = $(this);
                $image.attr('mwl-index', index);
            });
        }

        function createMwlTargetDiv(template) {
            var lightbox_container = "<div id='mwl-target'></div>";
            $('#mwl-target').remove();
            $('body').append(lightbox_container);
        }

        function createMwlImgsArray() {
            // NEW WAY OF CREATING THE ARRAY
            // First we retrieve the array of indexes
            var image_ids = [];
            var image_ids_list = [];
            var image_indexes = [];
            $('.mwl-img').each(function(index) {
                var $image = $(this),
                    image_id = $image.attr('mwl-img-id'),
                    image_classes,
                    datas,
                    temp_mwl_img;
                // If we don't have an id from mwl-img-id, we try to get it from the class wp-image-id
                if (!image_id) {
                    image_classes = $image.attr('class').split(" ");
                    image_classes.forEach(function(the_class) {
                        if (the_class.indexOf("wp-image") >= 0) {
                            image_id = the_class.substring(9);
                        }
                    });
                }
                if(image_id !== undefined) {
                    image_ids.push(parseInt(image_id));
                    image_ids_list.push(parseInt(image_id));
                }
                else {
                    image_ids_list.push(-1);
                    datas = {
                        exists: true,
                        index: index,
                        img_src: $image.attr('src'),
                        img_srcset: false,
                        img_sizes: false,
                        img_dimensions: false,
                        img_orientation: 'landscape',
                        img_exifs: false
                    };
                    temp_mwl_img = new MwlImage(datas);
                    mwl_imgs_array[index] = temp_mwl_img;
                }
            });

            // Let's call the API for all the indexes we have
            jQuery.ajax({
                url: mwl.url_api + 'info/ids/',
                type: 'POST',
                data: {
                    ids: image_ids
                },
                success: function(response) {
                    var count = 0;

                    for (var result in response.results) {
                        if( response.results.hasOwnProperty( result ) ) {
                            var image_data = response.results[result];
                            if(image_data.success) {
                                // gps
                                if(image_data.data.gps.split(",").length > 1) {
                                    var image_gps_lat = parseFloat(image_data.data.gps.split(",")[0]);
                                    var image_gps_lng = parseFloat(image_data.data.gps.split(",")[1]);
                                } else {
                                    var image_gps_lat = "N/A";
                                    var image_gps_lng = "N/A";
                                }
                                var datas = {
                                    id: image_data.data.id,
                                    index: $.inArray(image_data.data.id, image_ids_list),
                                    exists: true,
                                    img_src: encodeURI( image_data.file ),
                                    img_srcset: image_data.file_srcset,
                                    img_sizes: image_data.file_sizes,
                                    img_dimensions: image_data.dimension,
                                    img_orientation: image_data.dimension.width > image_data.dimension.height ? "landscape" : "portrait",
                                    img_exifs: image_data.data,
                                    img_gps: {
                                        lat: image_gps_lat,
                                        lng: image_gps_lng
                                    }
                                };
                                temp_mwl_img = new MwlImage(datas);
                                mwl_imgs_array[count] = temp_mwl_img;
                                count++;
                            }
                        }
                    }
                }
            });

        }

        function resizeImg(callback) {
            var $mwl_img_container = $('.mwl-img-container'),
                $img = $('.mwl-img-in-lightbox'),

                container_width = $mwl_img_container.outerWidth(),
                container_height = $mwl_img_container.outerHeight(),

                mwl_image = getMwlImageByIndex(current_image_index),
                img_width = mwl_image.img_dimensions.width,
                img_height = mwl_image.img_dimensions.height,

                img_ratio = img_width / img_height,
                container_ratio = container_width / container_height;

            if (img_ratio > container_ratio) {
                $img.css('width', '100%');
                $img.css('height', 'auto');
            } else {
                $img.css('width', 'auto');
                $img.css('height', '100%');
            }

            setTimeout(function() {
                callback();
            },10);
        }

        function updateData(template, mwl_image) {

            // Orientation
            if (settings.orientation_responsive.enabled) {
                if (!$('.mwl-container').hasClass(mwl_image.img_orientation)) {
                    $('.mwl-container').removeClass('landscape portrait');
                    $('.mwl-container').addClass(mwl_image.img_orientation);
                }
            } else {
                $('.mwl-container').removeClass('landscape portrait');
                $('.mwl-container').addClass(settings.orientation_responsive.orientation);
            }

            // Image
            $('.mwl-img-container img').attr('src', mwl_image.img_src);
            if(mwl_image.img_srcset) {
                $('.mwl-img-container img').attr('srcset', mwl_image.img_srcset);
            }
            // Hiding Image until it's loaded
            $('.mwl-img-container img').css({
                'opacity': 0
            });
            // Showing it when it's loaded
            $('.mwl-img-container').imagesLoaded(function() {
                $('.mwl-img-container img').animate({
                    'opacity': 1
                }, 300);
            });

            // INFOS
            $('.mwl-content .exif-data-item').each(function() {
                var item = $(this).attr('mwl-data-item'),
                    item_value;
                if (item) {
                    item_value = mwl_image.img_exifs[item];
                    if (!item_value || item_value === "N/A" || !settings.infos_to_display[item]) {
                        $(this).parent().hide();
                    } else {
                        $(this).html(item_value);
                        $(this).parent().show();
                    }
                }
            });
        }

        function applyPostTemplateScript(theme, mwl_image) {
            // Check if there is only one image, if so, hide nav.
            if(mwl_imgs_array.length == 1) {
                $('.control-nav').hide();
            }
        }

        function getTemplate(mwl_image, mwl_layout, mwl_theme, animations)  {
            if (mwl_image && mwl_image.exists) {

                $("#mwl-target").load(mwl.plugin_url + "templates/" + mwl_layout + ".html", function(template) {

                    updateData(template, mwl_image);

                    // controls options
                    if (!settings.allow_expand && $('.control-expand').length > 0) {
                        $('.control-expand').hide();
                    }
                    if (!settings.allow_fullscreen && $('.control-fullscreen').length > 0) {
                        $('.control-fullscreen').hide();
                    }

                    if (animations === 0) {
                        $('.mwl-container').removeClass('invisible');
                        $('.mwl-content').addClass('visible');
                    }
                    if (animations === 1) {
                        $('.mwl-container').removeClass('invisible');
                        setTimeout(function() {
                            $('.mwl-content').addClass('visible');
                        }, 1);
                    }
                    if (animations === 2) {
                        setTimeout(function() {
                            $('.mwl-container').removeClass('invisible');
                            $('.mwl-content').addClass('visible');
                        }, 1);
                    }
                    $('.mwl-container').addClass(mwl_theme);
                    applyPostTemplateScript(mwl_layout, mwl_image);
                    if (typeof mwl_pro_display_map === "function" && mwl_image.img_gps.lat !== "N/A" && settings.map.enabled) {
                        $('.google-map-script').remove();
                        window.google = {};
                        mwl_pro_display_map(mwl_image.img_gps, settings.map);
                    }
                    /*resizeImg(function() {
                        if (typeof mwl_pro_display_map === "function" && mwl_image.img_gps.lat !== "N/A" && settings.map.enabled) {
                            $('.google-map-script').remove();
                            window.google = {};
                            mwl_pro_display_map(mwl_image.img_gps, settings.map);
                        }
                    });*/
                });
            } else if (display_missing_images) {
                $('#mwl-target').load(mwl.plugin_url + "/templates/undefined.html", function(template) {
                    //var rendered = Mustache.render(template, mwl_image);
                    updateData(template, mwl_image);
                    $('.mwl-container').removeClass('invisible');
                    setTimeout(function() {
                        $('.mwl-content').addClass('visible');
                    }, 1);
                    $('.mwl-container').addClass(mwl_theme);
                });
            }
        }

        /**
         * Initialize lightbox
         */
        this.init = function() {
            createMwlTargetDiv();
            addClassToImgs();
            addIndexToImgs();
            createMwlImgsArray();
        };

        /**
         * Resize images in lightbox to fill the screen
         */
        this.resizeImg = function(callback) {
            if (mwl_imgs_array[current_image_index]) {
                if (mwl_imgs_array[current_image_index].exists) {
                    var $mwl_img_container = $('.mwl-img-container'),
                        $img = $('.mwl-img-in-lightbox'),

                        container_width = $mwl_img_container.outerWidth(),
                        container_height = $mwl_img_container.outerHeight(),

                        img_width = mwl_imgs_array[current_image_index].img_dimensions.width,
                        img_height = mwl_imgs_array[current_image_index].img_dimensions.height,

                        width_dif = container_width - img_width,
                        height_dif = container_height - img_height,

                        img_ratio = img_width / img_height,
                        container_ratio = container_width / container_height;


                    if (img_ratio > container_ratio) {
                        $img.css('width', '100%');
                        $img.css('height', 'auto');
                    } else {
                        $img.css('width', 'auto');
                        $img.css('height', '100%');
                    }

                    callback();
                }
            }
        };

        /**
         * Get the next image index
         * @returns {[[int]]} index [[next image index]]
         */
        this.getNextIndex = function() {
            var next_index = current_image_index + 1,
				found_an_image = false,
				iterations = 0;
			// While we haven't found a valid image ( for example if last images are not loaded yet )
			while(!found_an_image) {
	            if (next_index > mwl_imgs_number) {
	                next_index = 0;
	            } else {
	                next_index = current_image_index + 1 + iterations;
	            }
				iterations++;
				// Checking if image found really exists, if not, we try the previous one, etc..
				this.getMwlImageByIndex(next_index) !== undefined ? found_an_image = true : found_an_image = false;
			}
            return next_index;
        };

        /**
         * Get the previous image index
         * @returns {[[int]]} index [[previous image index]]
         */
        this.getPrevIndex = function() {
			var found_an_image = false,
				prev_index = current_image_index - 1,
				iterations = 0;
			// While we haven't found a valid image ( for example if last images are not loaded yet )
			while(!found_an_image) {
	            if (prev_index < 0) {
	                prev_index = mwl_imgs_number - 1 - iterations;
	            } else {
	                prev_index = current_image_index - 1 - iterations;
	            }
				iterations++;
				// Checking if image found really exists, if not, we try the previous one, etc..
				this.getMwlImageByIndex(prev_index) !== undefined ? found_an_image = true : found_an_image = false;
			}
			// When we've finally found a valid image, we return its index
            return prev_index;
        };

        function getMwlImageByIndex(index) {
            var result;
            mwl_imgs_array.forEach(function(item) {
                if(item.index == index) {
                    result = item;
                }
            });
            return result;
        }

        /**
         * Get an image with its index
         * @param   {[[int]]} index [[image index]]
         * @returns {[[MwlImage]]} [[image]]
         */
        this.getMwlImageByIndex = function(index) {
            var result;
            mwl_imgs_array.forEach(function(item) {
                if(item.index == index) {
                    result = item;
                }
            });
            return result;
        };

        /**
         * Expand the current image
         */
        this.expandImage = function() {
            // Switching to expend template
            getTemplate(this.getMwlImageByIndex(current_image_index), 'expanded', settings.theme, 0);
            // Setting expanded_image setting to true
            settings.expanded_image = true;
        };

        /**
         * Shrink an expanded image back to its original layout
         */
        this.shrinkImage = function() {
            // Switching to shrink mode
            getTemplate(this.getMwlImageByIndex(current_image_index), settings.layout, settings.theme, 0);
            // Setting expanded_image setting to false
            settings.expanded_image = false;
        };

        /**
         * Tell if the lightbox is currently in fullscreen mode or not
         * @returns {[[Boolean]]} [[Fullscreen or not]]
         */
        this.isFullscreen = function() {
            return is_fullscreen;
        };

        /**
         * Toggle Fullscreen mode
         * @param {object} elem [[Element to be fullscreened]]
         */
        this.toggleFullScreen = function(elem) {
            if ((document.fullScreenElement !== undefined && document.fullScreenElement === null) ||
                (document.msFullscreenElement !== undefined && document.msFullscreenElement === null) ||
                (document.mozFullScreen !== undefined && !document.mozFullScreen) ||
                (document.webkitIsFullScreen !== undefined && !document.webkitIsFullScreen)) {
                if (elem.requestFullScreen) {
                    elem.requestFullScreen();
                    is_fullscreen = true;
                } else if (elem.mozRequestFullScreen) {
                    elem.mozRequestFullScreen();
                    is_fullscreen = true;
                } else if (elem.webkitRequestFullScreen) {
                    elem.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT);
                    is_fullscreen = true;
                } else if (elem.msRequestFullscreen) {
                    elem.msRequestFullscreen();
                    is_fullscreen = true;
                }
            } else {
                if (document.cancelFullScreen) {
                    document.cancelFullScreen();
                    is_fullscreen = false;
                } else if (document.mozCancelFullScreen) {
                    document.mozCancelFullScreen();
                    is_fullscreen = false;
                } else if (document.webkitCancelFullScreen) {
                    document.webkitCancelFullScreen();
                    is_fullscreen = false;
                } else if (document.msExitFullscreen) {
                    document.msExitFullscreen();
                    is_fullscreen = false;
                }
            }
        };

        /**
         * Change the image in the lightbox ( opened )
         * @param {[[MwlImage]]} mwl_image    [[image to display]]
         * @param {[[string]]} mwl_layout [[lightbox template]]
         */
        this.changeLightboxImage = function(mwl_image, mwl_layout, mwl_theme, navigating) {
            // If current_image_index is in expanded mode, next one stays in expanded mode.
			if (settings.expanded_image) { mwl_layout = "expanded" };

            current_image_index = mwl_image.index;
            var next_image_index, next_image, next_index, prev_index, temp_mwl_img;
            if (mwl_image && mwl_image.exists) {
                getTemplate(mwl_image, mwl_layout, mwl_theme, 1);
                next_image_index = this.getNextIndex();
                next_image = this.getMwlImageByIndex(next_image_index);
                if (typeof mwl_pro_preload_image === "function") {
                    if (settings.preloading && next_image.exists && !next_image.preloaded) {
                        mwl_pro_preload_image(next_image.img_src, next_image.img_srcset, next_image.img_sizes);
                        next_image.preloaded = true;
                    }
                }
            } else {
                if (navigating === "next") {
                    next_index = this.getNextIndex();
                    temp_mwl_img = this.getMwlImageByIndex(next_index);
                    this.changeLightboxImage(temp_mwl_img, mwl_layout, mwl_theme, navigating);
                }
                if (navigating === "previous") {
                    prev_index = this.getPrevIndex();
                    temp_mwl_img = this.getMwlImageByIndex(prev_index);
                    this.changeLightboxImage(temp_mwl_img, mwl_layout, mwl_theme, navigating);
                }
            }
        };

        /**
         * Open the lightbox
         * @param {[[MwlImage]]} mwl_image    [[image to display]]
         * @param {[[string]]} mwl_layout [[lightbox template]]
         */
        this.showLightbox = function(mwl_image, mwl_layout, mwl_theme) {
            if (mwl_image) {
                getTemplate(mwl_image, mwl_layout, mwl_theme, 2);
                current_image_index = mwl_image.index;
                var next_image_index = this.getNextIndex(),
                    next_image = this.getMwlImageByIndex(next_image_index);
                    if (typeof mwl_pro_preload_image === "function") {
                        if (settings.preloading && next_image.exists && !next_image.preloaded) {
                            mwl_pro_preload_image(next_image.img_src, next_image.img_srcset, next_image.img_sizes);
                            next_image.preloaded = true;
                        }
                    }
            }
        };

        /**
         * Close the lightbox
         */
        this.closeLightbox = function() {
            // close the lightbox
            $('.mwl-container').addClass('invisible');
            $('#mwl-map-full').css({
                'visibility': 'hidden',
                'opacity': 0
            });

            $('.mwl-container').html('');

            // exit expanding mode
            settings.expanded_image = false;
        };

    };

});
