#!/bin/zsh

for test in $(find ./tests -type f); do
    promtool test rules "$test";
done