#!/usr/bin/env sh

if [ -z $DC ]; then
	export DC=dmd
fi

echo "compiler is ${DC}."
dub clean
dub -v --build=unittest --compiler=$DC
