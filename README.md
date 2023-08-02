# ![KPA - The Knowledge Pods Approach](./images/kpa-github-header.png#gh-light-mode-only) ![KPA - The Knowledge Pods Approach](./images/kpa-github-header-dark.png#gh-dark-mode-only)

[![Docker Repository on Quay](https://quay.io/repository/mmul/kpa-marp-pandoc/status "Docker Repository on Quay")](https://quay.io/repository/mmul/kpa-marp-pandoc)

This repository defines the base container containing all the needed tools by
[Knowledge Pods Approach (KPA)](https://github.com/mmul-it/kpa).

It specifically creates an environment containing these tools:

- `ansible` & `ansible-lint` to execute and check the 
  [kpa_generator](https://github.com/mmul-it/kpa_generator) Ansible playbooks.
- `curl` & `git` to execute routine commands.
- `yamllint` & `mdl` to execute linter on both yaml and md files.
- `marp` to generate slide sets (check [marp.app](https://marp.app/)).
- `pandoc` to generate agenda & books (check [pandoc.org](https://pandoc.org/)).

## Where this container is used?

This container is the base for the KPA main container, available at
[quay.io/mmul/kpa](https://quay.io/repository/mmul/kpa).

## License

MIT

## Author Information

Raoul Scarazzini ([rascasoft](https://github.com/rascasoft))
