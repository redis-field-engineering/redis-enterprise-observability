#!/bin/zsh

for test in $(find ./tests -type f); do
    res=`promtool test rules "$test"`
    echo "test $test $res"
done
