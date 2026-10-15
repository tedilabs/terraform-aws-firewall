# Code Generation

AWS WAF statements nest up to three levels, but Terraform has no recursive blocks.
Each statement block must therefore be repeated in every position where it may
appear. `main.tf` is generated so that each statement is written once.

Do not edit `main.tf` or `tests/statement_positions.tftest.hcl` directly. Edit the
sources below and regenerate.

| Source | Purpose |
| --- | --- |
| `../statement-grammar.json` | Statements allowed at each nesting level, from the top level down. |
| `main.tf.tmpl` | `main.tf` with a `{{rule_statement}}` placeholder for the rule statement. |
| `statements/<kind>.tf.tmpl` | The block of one leaf statement, reading its input from `{{src}}`. |
| `statements/<kind>.nested.tf.tmpl` | Optional. Replaces the template above below the top level. |
| `logical/<kind>.tf.tmpl` | The block of one logical statement (`and`, `or`, `not`), wrapping the next level as `{{body}}`. |
| `tests.tftest.hcl.tmpl` | Preamble of the generated position tests. |

## Usage

Run from the module directory. The script requires Python 3.9+ and `terraform`,
which formats the output.

```sh
python3 codegen/generate.py          # rewrite the generated files
python3 codegen/generate.py --check  # exit 1 if a generated file is out of date
```

## Adding a Leaf Statement

1. Add `statements/<kind>.tf.tmpl`.
2. Add `<kind>` to the levels in `statement-grammar.json` where it is allowed.
3. Add a minimal input for `<kind>` to `LEAF_FIXTURES` in `generate.py`. The
   generated position tests use it.
4. Run `python3 codegen/generate.py` and `terraform test`.
