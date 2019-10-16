# Change Log

## [2.0.0](https://github.com/Icinga/dashing-icinga2/tree/2.0.0) (2018-03-08)
[Full Changelog](https://github.com/Icinga/dashing-icinga2/compare/v1.3.0...2.0.0)

**Implemented enhancements:**

- Refine Dashing layout [\#57](https://github.com/Icinga/dashing-icinga2/pull/57) ([dnsmichi](https://github.com/dnsmichi))
- Allow to configure the Icinga Web 2 Iframe URL [\#54](https://github.com/Icinga/dashing-icinga2/pull/54) ([dnsmichi](https://github.com/dnsmichi))
- Add support for environment variables overriding local configuration settings [\#52](https://github.com/Icinga/dashing-icinga2/pull/52) ([dnsmichi](https://github.com/dnsmichi))
- Allow to use 'config/icinga2.local.json' for local configuration overrides [\#51](https://github.com/Icinga/dashing-icinga2/pull/51) ([dnsmichi](https://github.com/dnsmichi))
- Render Undhandled Problems green if count is zero [\#45](https://github.com/Icinga/dashing-icinga2/pull/45) ([dnsmichi](https://github.com/dnsmichi))
- colored and sorted problems by severity [\#41](https://github.com/Icinga/dashing-icinga2/pull/41) ([marconett](https://github.com/marconett))
- Allow Overriding of TLS Cert Names [\#40](https://github.com/Icinga/dashing-icinga2/pull/40) ([spjmurray](https://github.com/spjmurray))
- Move Logo [\#39](https://github.com/Icinga/dashing-icinga2/pull/39) ([spjmurray](https://github.com/spjmurray))
- Upgrade Presentation Layer [\#38](https://github.com/Icinga/dashing-icinga2/pull/38) ([spjmurray](https://github.com/spjmurray))
- Update documentation [\#37](https://github.com/Icinga/dashing-icinga2/pull/37) ([dnsmichi](https://github.com/dnsmichi))

**Fixed bugs:**

- Dashing issues with refreshing data  [\#29](https://github.com/Icinga/dashing-icinga2/issues/29)
- blank dashboard [\#15](https://github.com/Icinga/dashing-icinga2/issues/15)
- Handle SocketError [\#34](https://github.com/Icinga/dashing-icinga2/pull/34) ([glauco](https://github.com/glauco))

**Closed issues:**

- 2.8.0 Icinga Plugin shows Menu [\#50](https://github.com/Icinga/dashing-icinga2/issues/50)
- Verify dashboard, Javascript and browser versions  [\#19](https://github.com/Icinga/dashing-icinga2/issues/19)

**Merged pull requests:**

- Fix problem list ordering: Crit -\> Warn -\> Unknown [\#53](https://github.com/Icinga/dashing-icinga2/pull/53) ([dnsmichi](https://github.com/dnsmichi))
- Fix version dependencies in Gemfile for dashing and rack-test [\#49](https://github.com/Icinga/dashing-icinga2/pull/49) ([dnsmichi](https://github.com/dnsmichi))

## [v1.3.0](https://github.com/Icinga/dashing-icinga2/tree/v1.3.0) (2017-06-29)
[Full Changelog](https://github.com/Icinga/dashing-icinga2/compare/v1.2.0...v1.3.0)

**Implemented enhancements:**

- Update simplemon widget counts to only show unhandled problems \(!ack && !downtime\) [\#17](https://github.com/Icinga/dashing-icinga2/issues/17)
- Lower refresh interval to 10s [\#30](https://github.com/Icinga/dashing-icinga2/pull/30) ([dnsmichi](https://github.com/dnsmichi))
- Better layout: 5 cols, handled stats, problems 2 rows, refined titles and font size [\#27](https://github.com/Icinga/dashing-icinga2/pull/27) ([dnsmichi](https://github.com/dnsmichi))
- Better error handling and default values [\#25](https://github.com/Icinga/dashing-icinga2/pull/25) ([dnsmichi](https://github.com/dnsmichi))
- Problem dashboards should show unhandled counts \(and overall counts below\) [\#24](https://github.com/Icinga/dashing-icinga2/pull/24) ([dnsmichi](https://github.com/dnsmichi))
- Add WorkQueue metrics to library and dashboard [\#23](https://github.com/Icinga/dashing-icinga2/pull/23) ([dnsmichi](https://github.com/dnsmichi))
- Add GitHub issue template [\#20](https://github.com/Icinga/dashing-icinga2/pull/20) ([dnsmichi](https://github.com/dnsmichi))

**Closed issues:**

- host down widget does not see downtime [\#16](https://github.com/Icinga/dashing-icinga2/issues/16)

**Merged pull requests:**

- Prepare v1.3.0 and add a Changelog [\#31](https://github.com/Icinga/dashing-icinga2/pull/31) ([dnsmichi](https://github.com/dnsmichi))
- Update README [\#28](https://github.com/Icinga/dashing-icinga2/pull/28) ([dnsmichi](https://github.com/dnsmichi))
- Update Authors in README [\#26](https://github.com/Icinga/dashing-icinga2/pull/26) ([dnsmichi](https://github.com/dnsmichi))
- Fix logo [\#22](https://github.com/Icinga/dashing-icinga2/pull/22) ([dnsmichi](https://github.com/dnsmichi))

## [v1.2.0](https://github.com/Icinga/dashing-icinga2/tree/v1.2.0) (2017-04-13)
[Full Changelog](https://github.com/Icinga/dashing-icinga2/compare/v1.1.0...v1.2.0)

**Closed issues:**

- Don't fetch all object data by default [\#13](https://github.com/Icinga/dashing-icinga2/issues/13)
- dashing-icinga2 wont start [\#10](https://github.com/Icinga/dashing-icinga2/issues/10)

**Merged pull requests:**

- Silence the log level [\#14](https://github.com/Icinga/dashing-icinga2/pull/14) ([dnsmichi](https://github.com/dnsmichi))
- Update README.md [\#12](https://github.com/Icinga/dashing-icinga2/pull/12) ([Darkitty](https://github.com/Darkitty))
- Update README.md [\#11](https://github.com/Icinga/dashing-icinga2/pull/11) ([Darkitty](https://github.com/Darkitty))

## [v1.1.0](https://github.com/Icinga/dashing-icinga2/tree/v1.1.0) (2016-12-16)
[Full Changelog](https://github.com/Icinga/dashing-icinga2/compare/v1.0.1...v1.1.0)

## [v1.0.1](https://github.com/Icinga/dashing-icinga2/tree/v1.0.1) (2016-12-02)
[Full Changelog](https://github.com/Icinga/dashing-icinga2/compare/v1.0.0...v1.0.1)

## [v1.0.0](https://github.com/Icinga/dashing-icinga2/tree/v1.0.0) (2016-11-27)
[Full Changelog](https://github.com/Icinga/dashing-icinga2/compare/v0.9.0...v1.0.0)

## [v0.9.0](https://github.com/Icinga/dashing-icinga2/tree/v0.9.0) (2016-10-16)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
