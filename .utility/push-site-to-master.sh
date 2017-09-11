#!/bin/bash
if [ "$TRAVIS_REPO_SLUG" == "openmessaging/openmessaging.github.io" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == "source" ]; then

  echo -e "Publishing openmessaging site...\n"
  rm -rf $HOME/site-latest
  cp -R _site/ $HOME/site-latest

  cd $HOME
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "travis-ci"
  git clone --quiet --branch=master https://${GH_TOKEN}@github.com/openmessaging/openmessaging.github.io master > /dev/null

  cd master
  git rm -rf .
  cp -Rf $HOME/site-latest/. .
  git add -f .
  git commit -m "Latest site on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to master"
  git push -fq origin master > /dev/null

  echo -e "Published openmessaging site to master.\n"
  
fi
