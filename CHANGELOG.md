# Changelog

## [v3.2.0](https://github.com/mocdaniel/dashing-icinga2/tree/3.2.0)

[Full Changelog](https://github.com/mocdaniel/dashing-icinga2/compare/v3.1.0...v3.2.0)

**Fixed bugs:**

- \[Bug\] DOWN Hosts are not displayed correctly and throw errors: "no implicit conversion of nil into string" [\#120](https://github.com/mocdaniel/dashing-icinga2/issues/120)
- \[Bug\] Receiving 401 errors after Installation [\#119](https://github.com/mocdaniel/dashing-icinga2/issues/119)

**Closed issues:**

- Pie-chart widgets render too big [\#123](https://github.com/mocdaniel/dashing-icinga2/issues/123)
- Invalid yield in layout.erb [\#121](https://github.com/mocdaniel/dashing-icinga2/issues/121)
- No data on icinga2-Dashboard [\#115](https://github.com/mocdaniel/dashing-icinga2/issues/115)

**Merged pull requests:**

- Updated ChartJS to v3.2.1 [\#118](https://github.com/mocdaniel/dashing-icinga2/pull/118) ([mocdaniel](https://github.com/mocdaniel))

## [v3.1.0](https://github.com/mocdaniel/dashing-icinga2/tree/v3.1.0) (2020-12-08)

[Full Changelog](https://github.com/mocdaniel/dashing-icinga2/compare/3.1.0...v3.1.0)

**Merged pull requests:**

- Chartjs appearance [\#124](https://github.com/mocdaniel/dashing-icinga2/pull/124) ([mocdaniel](https://github.com/mocdaniel))
- no-services-for-down-hosts-show-display-name-for-services-and-hosts [\#114](https://github.com/mocdaniel/dashing-icinga2/pull/114) ([betrZHAW](https://github.com/betrZHAW))

## [3.1.0](https://github.com/mocdaniel/dashing-icinga2/tree/3.1.0) (2020-11-07)

[Full Changelog](https://github.com/mocdaniel/dashing-icinga2/compare/v3.0.0...3.1.0)

**Implemented enhancements:**

- Changing timezone [\#92](https://github.com/mocdaniel/dashing-icinga2/issues/92)
- Scrolling of crammed widgets [\#99](https://github.com/mocdaniel/dashing-icinga2/pull/99) ([mocdaniel](https://github.com/mocdaniel))

**Fixed bugs:**

- Use Chartjs update\(\) and rebuild chart only when necessary [\#97](https://github.com/mocdaniel/dashing-icinga2/pull/97) ([coderobe](https://github.com/coderobe))

**Closed issues:**

- Host and Service Problems still 0 [\#105](https://github.com/mocdaniel/dashing-icinga2/issues/105)
- Object not found! Error in Last two panel [\#104](https://github.com/mocdaniel/dashing-icinga2/issues/104)
- Enhancement Request: numbers next to host/service dials [\#102](https://github.com/mocdaniel/dashing-icinga2/issues/102)
- Wrong data at "Service Problems", "Unhandled Services" and "Problems" at the to view. [\#96](https://github.com/mocdaniel/dashing-icinga2/issues/96)
- Wrong Data and Graphs Orientation on Mouse Over [\#93](https://github.com/mocdaniel/dashing-icinga2/issues/93)
- Dual login windows/iFrames w/Ruby using RHSCL [\#80](https://github.com/mocdaniel/dashing-icinga2/issues/80)
- Cannot install on CentOS 7 / RHEL 7 - /usr/bin/ruby too old [\#98](https://github.com/mocdaniel/dashing-icinga2/issues/98)

**Merged pull requests:**

- Add dashing icon [\#112](https://github.com/mocdaniel/dashing-icinga2/pull/112) ([theFeu](https://github.com/theFeu))
- Changes to README.md [\#110](https://github.com/mocdaniel/dashing-icinga2/pull/110) ([mocdaniel](https://github.com/mocdaniel))
- Update project for transfer ownership [\#109](https://github.com/mocdaniel/dashing-icinga2/pull/109) ([dnsmichi](https://github.com/dnsmichi))
- Added new Edge to supported browsers [\#100](https://github.com/mocdaniel/dashing-icinga2/pull/100) ([mocdaniel](https://github.com/mocdaniel))
- Add timezone config/ENV support for the clock widget [\#94](https://github.com/mocdaniel/dashing-icinga2/pull/94) ([dnsmichi](https://github.com/dnsmichi))

## [v3.0.0](https://github.com/mocdaniel/dashing-icinga2/tree/v3.0.0) (2019-10-16)

[Full Changelog](https://github.com/mocdaniel/dashing-icinga2/compare/v2.0.0...v3.0.0)

**Implemented enhancements:**

- iFrame Title [\#82](https://github.com/mocdaniel/dashing-icinga2/issues/82)
- Add title support for the iframe widget for Icinga Web [\#90](https://github.com/mocdaniel/dashing-icinga2/pull/90) ([dnsmichi](https://github.com/dnsmichi))
- Support both, Dashing and Smashing as Gems [\#88](https://github.com/mocdaniel/dashing-icinga2/pull/88) ([dnsmichi](https://github.com/dnsmichi))
- Add chartjs widgets to dashboard [\#86](https://github.com/mocdaniel/dashing-icinga2/pull/86) ([dnsmichi](https://github.com/dnsmichi))
- Docker: Introduce dnsmichi/dashing-icinga2 [\#85](https://github.com/mocdaniel/dashing-icinga2/pull/85) ([dnsmichi](https://github.com/dnsmichi))
- Add timezone to clock widget [\#74](https://github.com/mocdaniel/dashing-icinga2/pull/74) ([Dambakk](https://github.com/Dambakk))
- Add option to show only hard state problems [\#73](https://github.com/mocdaniel/dashing-icinga2/pull/73) ([Dambakk](https://github.com/Dambakk))

**Fixed bugs:**

- Update dashing-icinga2 [\#70](https://github.com/mocdaniel/dashing-icinga2/pull/70) ([jschanz](https://github.com/jschanz))

**Closed issues:**

- Not working \(stale information, information does not updated\) after icinga2 update to version 2.11  [\#83](https://github.com/mocdaniel/dashing-icinga2/issues/83)
- Service down number not matching [\#79](https://github.com/mocdaniel/dashing-icinga2/issues/79)
- CentOs 7 - Cannot Start Service /usr/bin/env: ruby: No such file or directory [\#78](https://github.com/mocdaniel/dashing-icinga2/issues/78)
- sample dashbaord blank [\#77](https://github.com/mocdaniel/dashing-icinga2/issues/77)
- Blank dashboard with console-log "EventSource's response has a MIME type \("text/html"\) that is not "text/event-stream" [\#76](https://github.com/mocdaniel/dashing-icinga2/issues/76)
- Two lower panels \(iframes\) not showing content [\#75](https://github.com/mocdaniel/dashing-icinga2/issues/75)
- Communication with Certificates [\#69](https://github.com/mocdaniel/dashing-icinga2/issues/69)
- Icinga2 crashes after a few seconds when starting dashing-icinga2 [\#68](https://github.com/mocdaniel/dashing-icinga2/issues/68)
- setting permissions to exclude network devices.  [\#66](https://github.com/mocdaniel/dashing-icinga2/issues/66)
- Add a better indicator for 0 unhandled problems for Simplelist [\#65](https://github.com/mocdaniel/dashing-icinga2/issues/65)
- How to add multiple Icinga2 instances [\#64](https://github.com/mocdaniel/dashing-icinga2/issues/64)
- Empty values in dashing-icinga2 [\#63](https://github.com/mocdaniel/dashing-icinga2/issues/63)

**Merged pull requests:**

- Add support details & sponsoring [\#89](https://github.com/mocdaniel/dashing-icinga2/pull/89) ([dnsmichi](https://github.com/dnsmichi))
- Change license to MIT to comply with Dashing and assets [\#87](https://github.com/mocdaniel/dashing-icinga2/pull/87) ([dnsmichi](https://github.com/dnsmichi))
- Refactor version parsing and drop the version\_revision attribute [\#84](https://github.com/mocdaniel/dashing-icinga2/pull/84) ([dnsmichi](https://github.com/dnsmichi))

## [v2.0.0](https://github.com/mocdaniel/dashing-icinga2/tree/v2.0.0) (2018-03-08)

[Full Changelog](https://github.com/mocdaniel/dashing-icinga2/compare/v1.3.0...v2.0.0)

**Implemented enhancements:**

- Refine Dashing layout [\#57](https://github.com/mocdaniel/dashing-icinga2/pull/57) ([dnsmichi](https://github.com/dnsmichi))
- Allow to configure the Icinga Web 2 Iframe URL [\#54](https://github.com/mocdaniel/dashing-icinga2/pull/54) ([dnsmichi](https://github.com/dnsmichi))
- Add support for environment variables overriding local configuration settings [\#52](https://github.com/mocdaniel/dashing-icinga2/pull/52) ([dnsmichi](https://github.com/dnsmichi))
- Allow to use 'config/icinga2.local.json' for local configuration overrides [\#51](https://github.com/mocdaniel/dashing-icinga2/pull/51) ([dnsmichi](https://github.com/dnsmichi))
- Render Undhandled Problems green if count is zero [\#45](https://github.com/mocdaniel/dashing-icinga2/pull/45) ([dnsmichi](https://github.com/dnsmichi))
- colored and sorted problems by severity [\#41](https://github.com/mocdaniel/dashing-icinga2/pull/41) ([marconett](https://github.com/marconett))
- Allow Overriding of TLS Cert Names [\#40](https://github.com/mocdaniel/dashing-icinga2/pull/40) ([spjmurray](https://github.com/spjmurray))
- Move Logo [\#39](https://github.com/mocdaniel/dashing-icinga2/pull/39) ([spjmurray](https://github.com/spjmurray))
- Upgrade Presentation Layer [\#38](https://github.com/mocdaniel/dashing-icinga2/pull/38) ([spjmurray](https://github.com/spjmurray))

**Fixed bugs:**

- Dashing issues with refreshing data  [\#29](https://github.com/mocdaniel/dashing-icinga2/issues/29)
- blank dashboard [\#15](https://github.com/mocdaniel/dashing-icinga2/issues/15)
- Handle SocketError [\#34](https://github.com/mocdaniel/dashing-icinga2/pull/34) ([glauco](https://github.com/glauco))

**Closed issues:**

- 2.8.0 Icinga Plugin shows Menu [\#50](https://github.com/mocdaniel/dashing-icinga2/issues/50)
- Verify dashboard, Javascript and browser versions  [\#19](https://github.com/mocdaniel/dashing-icinga2/issues/19)

**Merged pull requests:**

- Fix problem list ordering: Crit -\> Warn -\> Unknown [\#53](https://github.com/mocdaniel/dashing-icinga2/pull/53) ([dnsmichi](https://github.com/dnsmichi))
- Fix version dependencies in Gemfile for dashing and rack-test [\#49](https://github.com/mocdaniel/dashing-icinga2/pull/49) ([dnsmichi](https://github.com/dnsmichi))

## [v1.3.0](https://github.com/mocdaniel/dashing-icinga2/tree/v1.3.0) (2017-06-29)

[Full Changelog](https://github.com/mocdaniel/dashing-icinga2/compare/v1.2.0...v1.3.0)

**Implemented enhancements:**

- Update simplemon widget counts to only show unhandled problems \(!ack && !downtime\) [\#17](https://github.com/mocdaniel/dashing-icinga2/issues/17)
- Update documentation [\#37](https://github.com/mocdaniel/dashing-icinga2/pull/37) ([dnsmichi](https://github.com/dnsmichi))
- Lower refresh interval to 10s [\#30](https://github.com/mocdaniel/dashing-icinga2/pull/30) ([dnsmichi](https://github.com/dnsmichi))
- Better layout: 5 cols, handled stats, problems 2 rows, refined titles and font size [\#27](https://github.com/mocdaniel/dashing-icinga2/pull/27) ([dnsmichi](https://github.com/dnsmichi))
- Better error handling and default values [\#25](https://github.com/mocdaniel/dashing-icinga2/pull/25) ([dnsmichi](https://github.com/dnsmichi))
- Problem dashboards should show unhandled counts \(and overall counts below\) [\#24](https://github.com/mocdaniel/dashing-icinga2/pull/24) ([dnsmichi](https://github.com/dnsmichi))
- Add WorkQueue metrics to library and dashboard [\#23](https://github.com/mocdaniel/dashing-icinga2/pull/23) ([dnsmichi](https://github.com/dnsmichi))
- Add GitHub issue template [\#20](https://github.com/mocdaniel/dashing-icinga2/pull/20) ([dnsmichi](https://github.com/dnsmichi))

**Closed issues:**

- host down widget does not see downtime [\#16](https://github.com/mocdaniel/dashing-icinga2/issues/16)

**Merged pull requests:**

- Prepare v1.3.0 and add a Changelog [\#31](https://github.com/mocdaniel/dashing-icinga2/pull/31) ([dnsmichi](https://github.com/dnsmichi))
- Update README [\#28](https://github.com/mocdaniel/dashing-icinga2/pull/28) ([dnsmichi](https://github.com/dnsmichi))
- Update Authors in README [\#26](https://github.com/mocdaniel/dashing-icinga2/pull/26) ([dnsmichi](https://github.com/dnsmichi))
- Fix logo [\#22](https://github.com/mocdaniel/dashing-icinga2/pull/22) ([dnsmichi](https://github.com/dnsmichi))

## [v1.2.0](https://github.com/mocdaniel/dashing-icinga2/tree/v1.2.0) (2017-04-13)

[Full Changelog](https://github.com/mocdaniel/dashing-icinga2/compare/v1.1.0...v1.2.0)

**Closed issues:**

- Don't fetch all object data by default [\#13](https://github.com/mocdaniel/dashing-icinga2/issues/13)
- dashing-icinga2 wont start [\#10](https://github.com/mocdaniel/dashing-icinga2/issues/10)

**Merged pull requests:**

- Silence the log level [\#14](https://github.com/mocdaniel/dashing-icinga2/pull/14) ([dnsmichi](https://github.com/dnsmichi))
- Update README.md [\#12](https://github.com/mocdaniel/dashing-icinga2/pull/12) ([tete2soja](https://github.com/tete2soja))
- Update README.md [\#11](https://github.com/mocdaniel/dashing-icinga2/pull/11) ([tete2soja](https://github.com/tete2soja))

## [v1.1.0](https://github.com/mocdaniel/dashing-icinga2/tree/v1.1.0) (2016-12-16)

[Full Changelog](https://github.com/mocdaniel/dashing-icinga2/compare/v1.0.1...v1.1.0)

## [v1.0.1](https://github.com/mocdaniel/dashing-icinga2/tree/v1.0.1) (2016-12-02)

[Full Changelog](https://github.com/mocdaniel/dashing-icinga2/compare/v1.0.0...v1.0.1)

## [v1.0.0](https://github.com/mocdaniel/dashing-icinga2/tree/v1.0.0) (2016-11-27)

[Full Changelog](https://github.com/mocdaniel/dashing-icinga2/compare/v0.9.0...v1.0.0)

## [v0.9.0](https://github.com/mocdaniel/dashing-icinga2/tree/v0.9.0) (2016-10-16)

[Full Changelog](https://github.com/mocdaniel/dashing-icinga2/compare/fcedcb403295eaa05fbf5442cc35cfaeb6da9e96...v0.9.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
