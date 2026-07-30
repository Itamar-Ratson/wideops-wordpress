# Local pre-deployment check

Run `make local-check`, then open <http://localhost> and confirm the following.
Everything here is about the migration itself.

| # | Check | What a pass tells you |
|---|-------|-----------------------|
| 1 | The home page loads at all, with no PHP error and no "Error establishing a database connection" | The image builds on PHP 7.4, `mysqli` loaded, and the hardcoded `DB_HOST` of `localhost` reached the database over the MySQL socket |
| 2 | The site title reads **Photography Guy** | The dump imported and `wp_options` was rewritten |
| 3 | The post **Romanian Autumn** shows its text | `wp_posts` content survived the import and rewrite |
| 4 | The post's photo displays rather than showing a broken image | The external media mount and `wp_postmeta` attachment paths both resolve |
| 5 | View source (`Ctrl+U`) and search for `104.155.81.48` — there should be no matches | The URL rewrite covered every table that referenced the old server |
| 6 | Thumbnails on the post render at their resized dimensions | `gd` loaded, so WordPress can work with images |

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
