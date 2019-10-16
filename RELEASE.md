# Release Workflow

Specify the release version.

```
VERSION=3.0.0
```

## Issues

Check issues at https://github.com/dnsmichi/dashing-icinga2

## Changelog

Write it manually.

## Release Commit

## Git Tag

```
git tag -s -m "Version $VERSION" v$VERSION
```

Push the tag.

```
git push --tags
```

## GitHub Release

Create a new release for the newly created Git tag.
https://github.com/dnsmichi/dashing-icinga2/releases

## Announcement

* Blogpost
* Twitter
* LinkedIn
