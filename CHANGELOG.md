## [Unreleased]

- Fix bug with aggregate filter where clause

## [0.6.0] - 2025-08-21

- Add preprocessors config that allows applying text transforms to the input before parsing
- Add preprocessor to remove `\restrict` and `\unrestrict` pragmas that appeared in newer versions of pg_dump

## [0.5.0] - 2025-08-04

- Upgrade pg_query to 6.1 to add support for latest mac OS version

## [0.4.0] - 2025-03-21

- Remove no-op `NOT VALID` setting when inlining constraints

## [0.3.0] - 2025-03-15

- Introduce StatementAppender for better spacing between statements

## [0.2.1] - 2025-02-15

- Add transform to remove SET commands with default values

## [0.2.0] - 2025-02-15

- Remove preprocessors (no longer relevant now that we don't reuse the source string in the output)

## [0.1.5] - 2025-02-08

- Sort table columns

## [0.1.4] - 2025-02-08

- Sort schema migrations inserts

## [0.1.3] - 2025-02-02

- Rework SQL formatting by only adding indentation to deparsed statements

## [0.1.2] - 2025-01-30

- Get rid of `anbt-sql-formatter` dependency since it breaks queries with type casting

## [0.1.1] - 2025-01-29

- Proper deparsing of all statements
- Formatting of select and insert sub-statements using `anbt-sql-formatter`

## [0.1.0] - 2025-01-24

- Initial release
