-- Strip the source host from rendered post URLs while leaving wp_options alone.
-- Some options hold PHP-serialized data whose byte lengths must not change.
-- The host is repeated rather than held in a variable on purpose: a user
-- variable is session-scoped, so a client that ran these statements separately
-- would apply REPLACE(..., NULL, '') and null the columns outright.
UPDATE wp_posts
SET post_content = REPLACE(post_content, 'http://104.155.81.48', ''),
    guid = REPLACE(guid, 'http://104.155.81.48', '');
