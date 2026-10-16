# Code Generation

AWS WAF statements nest up to three levels, but Terraform has no recursive blocks.
Each statement block must therefore be repeated in every position where it may
appear. `main.tf` is generated so that each statement is written once.

Do not edit `main.tf` or `tests/statement_positions.tftest.hcl` directly. Edit the
sources below and regenerate.

| Source | Purpose |
| --- | --- |
| `../statement-grammar.json` | Statements allowed at each nesting level, from the top level down, for each context: `rule` for the rule statement and `scope_down` for the scope-down statement of a managed rule group. |
| `main.tf.tmpl` | `main.tf` with a `{{rule_statement}}` placeholder for the rule statement. |
| `statements/<kind>.tf.tmpl` | The block of one leaf statement, reading its input from `{{src}}`. |
| `logical/<kind>.tf.tmpl` | The block of one logical statement (`and`, `or`, `not`), wrapping the next level as `{{body}}`. |
| `action.tf.tmpl` | The `allow`, `block`, `captcha`, `challenge`, and `count` action blocks, reading the action from `{{action}}` and custom handling from `{{handling}}`. |
| `request_inspection.tf.tmpl` | The `field_to_match` and text transformation blocks of a statement that inspects a request component, reading them from `{{match}}`. |
| `tests.tftest.hcl.tmpl` | Preamble of the generated position tests. |

Any template can place these shared blocks by name. Each is rendered only where a
template uses it.

| Placeholder | Block |
| --- | --- |
| `{{rule_action}}` | `action.tf.tmpl` for the rule `action`. |
| `{{override_action_to_use}}` | `action.tf.tmpl` for a rule action override of a managed rule group. |
| `{{scope_down}}` | The statements of the `scope_down` context. |
| `{{<kind>_request_inspection}}` | `request_inspection.tf.tmpl` for a statement in `REQUEST_INSPECTING_STATEMENTS` of `generate.py`. |

## Usage

Run from the module directory. The script requires Python 3.9+ and `terraform`,
which formats the output.

```sh
python3 codegen/generate.py          # rewrite the generated files
python3 codegen/generate.py --check  # exit 1 if a generated file is out of date
```

## Adding a Leaf Statement

1. Add `statements/<kind>.tf.tmpl`.
2. Add `<kind>` to the levels in `statement-grammar.json` where it is allowed, in
   each context.
3. Add a minimal input for `<kind>` to `LEAF_FIXTURES` in `generate.py`. The
   generated position tests use it in every context.
4. Run `python3 codegen/generate.py` and `terraform test`.
