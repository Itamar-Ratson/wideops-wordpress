<?php
/**
 * Template part for displaying posts.
 *
 * @package Lucienne
 */

?>

<article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>

<div class="featured-image">
				<a href="<?php the_permalink(); ?>" title="<?php the_title_attribute(); ?>"><?php the_post_thumbnail( 'Lucienne-home' ); ?></a>    
			</div>

	<header class="entry-header">
		<?php the_title( sprintf( '<h1 class="entry-title"><a href="%s" rel="bookmark">', esc_url( get_permalink() ) ), '</a></h1>' ); ?>
        <hr class="entry-border">
        <div class="entry-cat">
			<?php the_category( ', ' ) ?>
		</div><!-- .entry-cat -->
	
			

		<?php if ( has_post_thumbnail() ) : ?>
			
		<?php endif; ?>
	</header><!-- .entry-header -->

	<div class="entry-summary">
		<?php the_excerpt(); ?>
	</div><!-- .entry-summary -->
    <div class="entry-bottom">
     <a href="<?php the_permalink(); ?>" title="<?php the_title_attribute(); ?>"><?php echo get_the_date( get_option('date_format') ); ?></a>  
       
</div><!-- .entry-footer -->
</article><!-- #post-## -->
