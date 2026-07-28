<?php
/**
 * The template for displaying the footer.
 *
 * Contains the closing of the #content div and all content after
 *
 * @package Lucienne
 */

?>
</div>
<!-- #content -->
</div>
<!-- .wrap  -->

<div id="footer">
  <footer id="colophon" class="site-footer" role="contentinfo">
    <?php if ( is_active_sidebar( 'footer-1' ) || is_active_sidebar( 'footer-2' ) || is_active_sidebar( 'footer-3' ) ) : ?>
    <div class="footer-widgets clear">
      <div class="widget-area">
        <?php if ( is_active_sidebar( 'footer-1' ) ) : ?>
        <?php dynamic_sidebar( 'footer-1' ); ?>
        <?php endif; ?>
      </div>
      <!-- .widget-area -->
      
      <div class="widget-area">
        <?php if ( is_active_sidebar( 'footer-2' ) ) : ?>
        <?php dynamic_sidebar( 'footer-2' ); ?>
        <?php endif; ?>
      </div>
      <!-- .widget-area -->
      
      <div class="widget-area">
        <?php if ( is_active_sidebar( 'footer-3' ) ) : ?>
        <?php dynamic_sidebar( 'footer-3' ); ?>
        <?php endif; ?>
      </div>
      <!-- .widget-area --> 
      
    </div>
    <!-- .footer-widgets -->
    
    <?php endif; ?>
  </footer>
  
  <div class="site-info"><a href="<?php echo esc_url( __( 'http://wordpress.org/',  'lucienne' ) ); ?>"><?php printf( esc_html__( 'Proudly powered by %s',  'Lucienne' ), 'WordPress' ); ?></a> <span class="sep"> | </span> <?php printf( esc_html__( 'Theme: %1$s by %2$s.',  'lucienne' ),  'lucienne', '<a href="https://themefurnace.com/">ThemeFurnace</a>' ); ?> </div>
  <!-- .site-info --> 
  
  <!-- #colophon --> 
</div>
<!-- #page -->
</div>
<!-- #footer -->

<?php wp_footer(); ?>
</body></html>