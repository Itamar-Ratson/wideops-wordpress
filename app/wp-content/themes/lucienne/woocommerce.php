<?php
/**
 * Template Name: WooCommerce
 *
 * @package Lucienne
 */

get_header(); ?>


<div id="primary" class="content-area">
 <?php woocommerce_breadcrumb(); ?>
   <?php woocommerce_content(); ?>

  <!-- #main --> 
  
</div>
<!-- #primary -->


<?php get_footer(); ?>