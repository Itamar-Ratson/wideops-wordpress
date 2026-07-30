-- The caller must set @destination before loading this file.
-- The source URL is fixed because it identifies the supplied database dump.
SET @source = 'http://104.155.81.48';

UPDATE wp_options
SET option_value = REPLACE(option_value, @source, @destination);

UPDATE wp_posts
SET post_content = REPLACE(post_content, @source, @destination),
    guid = REPLACE(guid, @source, @destination);

UPDATE wp_postmeta
SET meta_value = REPLACE(meta_value, @source, @destination);
