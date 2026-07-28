<?php if ( is_home()  ) : ?>
 <?php $show_main_slider = get_theme_mod( 'show_main_slider', 'yes' );
		if ( $show_main_slider === 'yes' ) :
	?>
	<div id="slider">
 
    <?php
    $carousel_cat = get_theme_mod('carousel_setting','1');
    $carousel_count = get_theme_mod('count_setting','4');
    $new_query = new WP_Query( array( 'cat' => $carousel_cat  , 'showposts' => $carousel_count ));
    while ( $new_query->have_posts() ) : $new_query->the_post(); ?>
 
 
	<?php $Lucienne_thumb = wp_get_attachment_image_src( get_post_thumbnail_id($post->ID), 'Lucienne-carousel-pic' );?>
 
    <div class="item" style="background-color:#f9f9f9;background: no-repeat; background-image: url('<?php echo esc_url( $Lucienne_thumb['0']);?>')">
     <div class="slider-info">
        <h3><a href="<?php the_permalink(); ?>"><?php the_title();?></a></h3>
        <div class="entry-cat">
			<?php the_category( ', ' ) ?>
		</div><!-- .entry-cat -->
        <div class="slider-excerpt"><?php the_excerpt(); ?></div>
        <div class="entry-datetop"><a href="<?php the_permalink(); ?>" title="<?php the_title_attribute(); ?>"><?php echo get_the_date( get_option('date_format') ); ?></a> </div> 
         <?php get_template_part( 'sharing' );  ?> 
    
    </div>
   <a href="<?php the_permalink(); ?>" class="continue-link"><?php esc_html_e( 'Continue Reading',  'lucienne' ); ?></a>
 </div><!-- .slider-info -->
  
    <?php 
        endwhile;
        wp_reset_postdata(); 
    ?>
 
	</div><!-- #slider -->
<?php endif; ?>
<?php endif; ?>