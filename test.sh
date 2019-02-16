#!/bin/bash

#shellcheck disable=SC2046
shellcheck --format=gcc $(find . -name '*.sh' -not -iwholename '*.git*')

#yamllint --config-data "{extends: default, rules: {line-length: {level: warning, max: 120}}}" ./nas_apps

#cd ansible
#ansible-lint playbooks/site.yml
