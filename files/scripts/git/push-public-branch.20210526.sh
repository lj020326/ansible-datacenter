#!/usr/bin/env bash

## ref: https://gist.github.com/heiswayi/350e2afda8cece810c0f6116dadbe651
echo "Check out current public branch:"
git checkout public

echo "Check out to a temporary branch:"
git checkout --orphan TEMP_BRANCH

cp -p files/git/pub.gitignore .gitignore

rm -fr private/
rm -fr files/private/
rm -fr vars/secrets.yml

echo "Add all the files:"
git add -A

echo "Commit the changes:"
git commit -am "Initial commit"

echo "Merge master changes to public branch:"
git merge master

echo "Delete the old branch:"
git branch -D public

echo "Rename the temporary branch to public:"
git branch -m public

echo "Force public branch update to origin repository:"
git push -f origin public
#git push -f --set-upstream origin public

echo "Force public branch update to github repository:"
git push -f github public

echo "Finally, checkout master branch:"
git checkout master
