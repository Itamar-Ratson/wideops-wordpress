<?php
/**
 * Template part for displaying single posts.
 *
 * @package Lucienne
 */

?>

<article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>  
<?php if ( is_single() || is_page() && has_post_thumbnail() ) : ?>
		<div class="featured-header-image">
				<?php the_post_thumbnail( 'Lucienne-home' ); ?>
		</div><!-- .featured-header-image -->
	<?php endif; ?>

	<header class="entry-header">
		<?php the_title( '<h1 class="entry-title">', '</h1>' ); ?>
         <hr class="entry-border"/>
        <div class="entry-cat">
		<?php the_category( ', ' ) ?> / <?php the_time('l, F jS, Y') ?>
		</div><!-- .entry-cat -->
                <?php get_template_part( 'sharing' );  ?>
	</header><!-- .entry-header -->
    
  

	<div class="entry-content">
		<?php the_content(); ?>
		<?php
			wp_link_pages( array(
				'before' => '<div class="page-links">' . esc_html__( 'Pages:',  'lucienne' ),
				'after'  => '</div>',
			) );
		?>
	</div><!-- .entry-content -->

	<footer class="entry-footer clear">
		<?php Lucienne_entry_footer(); ?>
	</footer><!-- .entry-footer -->
</article><!-- #post-## -->

