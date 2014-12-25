#!/bin/bash
# generate html code document for source code
echo "Generating Documentation"

DocDirectory="Documentation"

echo "Doc Dir = $DocDirectory"

if [ ! -d "$DocDirectory" ]; then
	echo "No Documentation Directory, creating $DocDirectory"
	mkdir -p "$DocDirectory"
fi

if hash jazzy 2>/dev/null; then
	jazzy -o "$DocDirectory" -c
else
	echo "Documentation Script requires Jazzy, go install foo"
fi
