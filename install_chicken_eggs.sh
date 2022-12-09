#!/bin/sh

# makes sure all the required chicken scheme eggs
# are installed
echo "Will run chicken-install for required eggs (libraries)"

eggs=(
ansi-escape-sequences \
filepath \
shell \
simple-loops \
srfi-13 \
srfi-141 \
srfi-69
)

for egg in ${eggs[@]}; do
	echo "  * $egg"
done

echo "------------------"
for egg in ${eggs[@]}; do
	chicken-install $egg
done




echo "DONE"
