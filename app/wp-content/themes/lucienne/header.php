<?php
/**
 * The header for our theme.
 *
 * Displays all of the <head> section and everything up till <div id="content">
 *
 * @package Lucienne
 */

?><!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
<meta charset="<?php bloginfo( 'charset' ); ?>">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="profile" href="http://gmpg.org/xfn/11">
<link rel="pingback" href="<?php bloginfo( 'pingback_url' ); ?>">
<?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>
 <nav class="clear socialmenu" role="navigation">
 <?php if ( has_nav_menu( 'social' ) ) : ?>
				<?php wp_nav_menu( array(
									'theme_location'  => 'social',
									'depth'           => 1,
									'link_before'     => '<span class="screen-reader-text">',
									'link_after'      => '</span>',
									'container_class' => 'social-links', ) ); ?>
<?php endif; ?></nav>

<div id="page" class="hfeed site">
	<a class="skip-link screen-reader-text" href="#content"><?php esc_html_e( 'Skip to content',  'lucienne' ); ?></a>

	<header id="masthead" class="site-header" role="banner">
		<div class="site-branding">
		<?php the_custom_logo(); ?>
			<?php if ( function_exists( 'jetpack_the_site_logo' ) && has_site_logo() ) : ?>
				<?php jetpack_the_site_logo(); ?>
			<?php endif; ?>
			<h1 class="site-title"><a href="<?php echo esc_url( home_url( '/' ) ); ?>" rel="home"><?php bloginfo( 'name' ); ?></a></h1>
			<h2 class="site-description"><?php bloginfo( 'description' ); ?></h2>
		</div><!-- .site-branding -->
        
        <nav id="site-navigation" class="main-navigation clear" role="navigation">
			<button class="menu-toggle" aria-controls="primary-menu" aria-expanded="false"><?php esc_html_e( 'Menu',  'lucienne' ); ?></button>
			<?php wp_nav_menu( array( 'theme_location' => 'primary', 'menu_id' => 'primary-menu' ) ); ?>

			
		</nav><!-- #site-navigation -->
	</header><!-- #masthead -->

	<div id="content" class="site-content">
	<div class="wrap clear">
