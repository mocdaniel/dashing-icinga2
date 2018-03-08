# Release Workflow

Specify the release version.

```
VERSION=2.0.0
```

## Issues

Check issues at https://github.com/Icinga/dashing-icinga2

## Changelog

```
github_changelog_generator --future-release v$VERSION
```

## Git Tag
```
git tag -u D14A1F16 -m "Version $VERSION" v$VERSION
```

Push the tag.

```
git push --tags
```

## GitHub Release

Create a new release for the newly created Git tag.
https://github.com/Icinga/dashing-icinga2/releases

## Announcement

* Create a new blog post on www.icinga.com/blog
