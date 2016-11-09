#!/bin/bash
set -e
rm -rf *.zip
./grailsw refresh-dependencies --non-interactive
./grailsw test-app --non-interactive
./grailsw package-plugin --non-interactive
./grailsw doc --pdf --non-interactive

filename=$(find . -name "grails-*.zip" | head -1)
filename=$(basename $filename)
plugin=${filename:7}
plugin=${plugin/.zip/}
plugin=${plugin/-SNAPSHOT/}
version="${plugin#*-}"; 
plugin=${plugin/"-$version"/}

echo "TRAVIS_BRANCH: $TRAVIS_BRANCH"
echo "TRAVIS_REPO_SLUG: $TRAVIS_REPO_SLUG"
echo "TRAVIS_PULL_REQUEST: $TRAVIS_PULL_REQUEST"

if [[ $TRAVIS_BRANCH == '8.x' && $TRAVIS_REPO_SLUG == "magnusbutlin/grails-tomcat-plugin" && $TRAVIS_PULL_REQUEST == 'false' ]]; then
  echo "pushing file $filename"

  #!/usr/bin/env bash
  GIT_DEPLOY_REPO=${GIT_DEPLOY_REPO:-$(node -e 'process.stdout.write(require("./package.json").repository)')}
  if [ "$TRAVIS" = "true" ]
  then
    # git need this, on Travis-CI nobody is defined
    git config --global user.name "magnusbutlin"
    git config --global user.email "magnusbutlin2@hotmail.com"
  fi

  git add --force $filename
  git commit -m "Deploy to GitHub Pages"
  git push --force "${GIT_DEPLOY_REPO}" master
else
  echo "Not on 8.x forked branch, so not pushing"
  echo "TRAVIS_BRANCH: $TRAVIS_BRANCH"
  echo "TRAVIS_REPO_SLUG: $TRAVIS_REPO_SLUG"
  echo "TRAVIS_PULL_REQUEST: $TRAVIS_PULL_REQUEST"
fi
