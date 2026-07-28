# Supplied asset integrity

Issue #2 relocated the supplied assets without editing them:

- `html/` became the container build context at `app/`.
- `wordpress.sql` became `data/wordpress.sql`.

Before the move, every file in the WordPress tree was SHA-256 hashed in sorted
relative-path order. The same manifest was generated after the move and the two
manifests were compared byte-for-byte with `cmp`. The database dump was hashed
directly before and after the move.

| Asset | Before | After | Result |
| --- | --- | --- | --- |
| WordPress manifest (2,634 files) | `779cefe459d2d76b79a6009ca4ba6f6e5fb352c8746b68e8350bb5a1b62b6fbf` | `779cefe459d2d76b79a6009ca4ba6f6e5fb352c8746b68e8350bb5a1b62b6fbf` | identical |
| Database dump | `e04fb6156391bf0f711674c365bb049b6979b072fbd1c2cca779acf2c4945d99` | `e04fb6156391bf0f711674c365bb049b6979b072fbd1c2cca779acf2c4945d99` | identical |

The manifest hash is the SHA-256 of the manifest itself; each manifest entry
contains a file's SHA-256 and its path relative to the tree root. This checks
both the contents and membership of the relocated tree while allowing its root
directory to change.
