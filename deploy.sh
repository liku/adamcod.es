#!/usr/bin/env bash

# executables prefix
_prefix="/usr/bin"
# git executable
_git="$_prefix/git"

# site generation executable
_generate="jekyll"
# options for the generator
_opts=(--no-safe --no-server --no-auto --kramdown)

# branch from which to generate site
_origbranch="master"
# branch holding the generated site
_destbranch="gh-pages"

# directory holding the generated site -- should be outside this repo
_site="$("mktemp" -d /tmp/_site.XXXXXXXXX)"

# the current branch
_currbranch="$(grep "^*" < <("$_git" branch) | $_prefix/cut -d' ' -f2)"

if [[ $_currbranch == $_origbranch ]]; then # we should generate the site
    # go to root dir of the repo
    cd "$("$_git" rev-parse --show-toplevel)"

    # generate the site
    "$_generate" ${_opts[@]} . "$_site"

    # add any new files
    "$_git" add .

    # commit all changes with a default message
    "$_git" commit -a -m "updated cache @ $(date +"%F %T")"

    # switch to branch the site will be stored
    "$_git" checkout "$_destbranch"

    # overwrite existing files
    builtin shopt -s dotglob
    cp -rf "$_site"/* .
    builtin shopt -u dotglob

    # add any new files
    "$_git" status

    # add any new files
    "$_git" add .

    # commit all changes with a default message
    "$_git" commit -a -m "updated site @ $(date +"%F %T")"

    # push changes to github
    "$_git" push origin "$_destbranch"

    # cleanup
    rm -rfv "$_site"

    # return
    "$_git" checkout "$_origbranch"
fi