# Local pre-deployment check

Run `make local-check`, then open <http://localhost> and confirm the following.
Everything here is about the migration itself.

| # | Check | What a pass tells you |
|---|-------|-----------------------|
| 1 | The home page loads at all, with no PHP error and no "Error establishing a database connection" | The image builds on PHP 7.4, `mysqli` loaded, and the injected `DB_HOST` reached the database over TLS-encrypted TCP |
| 2 | The site title reads **Photography Guy** | The dump imported and its options are readable |
| 3 | The post **Romanian Autumn** shows its text | `wp_posts` content survived the import and rewrite |
| 4 | The post's photo displays rather than showing a broken image | The relative post URL and unchanged `wp_postmeta` attachment path both resolve through the external media mount |
| 5 | View source (`Ctrl+U`): image URLs in the post body start with `/wp-content/uploads/`, and searching the rendered source for `104.155.81.48` returns no matches. The address does still exist in the database — see check 6 — so this is a claim about rendered output only. | Post URLs are relative, so the site does not depend on the address it was seeded against |
| 6 | Run the command below; its final line reads `valid` | The serialized plugin option still parses after seeding |
| 7 | Thumbnails on the post render at their resized dimensions | `gd` loaded, so WordPress can work with images |

## The command for check 6

The rewrite deliberately leaves `wp_options` alone, because some options hold
PHP-serialized data whose embedded byte lengths would stop matching if a
`REPLACE` shortened a string inside them. Confirm one such option still parses:

```bash
docker compose --file local/compose.yaml exec app \
    php -r 'require "/var/www/html/wp-load.php";
            echo is_array(get_option("fs_accounts")) ? "valid\n" : "invalid\n";'
```

WordPress logs a PHP 7.4 warning above the result on every load, which is
expected; only the final line matters. The old address does still sit inside
that option, and is meant to — it is dormant plugin data that is never
rendered, which is what check 5 confirms.

If a check fails, look at the container logs before changing anything:

```bash
docker compose logs db
docker compose logs app
```

The dump import and URL rewrite run during MySQL's first-time initialisation,
so import errors appear in the `db` log rather than at the point of failure.

When you are done:

```bash
make local-clean
```
