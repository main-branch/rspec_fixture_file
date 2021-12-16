# How to release a new rspec_fixture_file gem

Releasing a new version of the `rspec_fixture_file` gem requires these steps:

- [How to release a new rspec_fixture_file gem](#how-to-release-a-new-rspec_fixture_file-gem)
  - [Prepare the release](#prepare-the-release)
  - [Create a GitHub release](#create-a-github-release)
  - [Build and release the gem](#build-and-release-the-gem)

These instructions use an example where the current release version is `1.0.0`
and the new release version to be created is `1.1.0.pre1`.

## Prepare the release

Starting in a working directory of the main branch of rspec_fixture_file, create a
PR containing changes to (1) bump the version number and (2) update the CHANGELOG.md,
and (3) tag the release.

- Bump the version number
  - Version number is in lib/rspec_fixture_file/version.rb
  - Follow [Semantic Versioning](https://semver.org) guidelines
  - `bundle exec bump --no-commit patch` # backwards compatible bug fixes
  - `bundle exec bump --no-commit minor` # backwards compatible new functionality
  - `bundle exec bump --no-commit major` # incompatible API changes

- Create the release branch (remember to bump the version number first)
  - ```git checkout -b "release_v`ruby -I lib -r rspec_fixture_file -e 'puts RSpecFixtureFile::VERSION'`"```
  - ```git push --set-upstream origin "`git symbolic-ref --short HEAD`"```

- Update CHANGELOG.md
  - `bundle exec rake changelog`

- Stage the changes to be committed
  - `git add lib/rspec_fixture_file/version.rb CHANGELOG.md`

- Commit, tag, and push changes to the repository
  - ```git release v`ruby -I lib -r rspec_fixture_file -e 'puts RSpecFixtureFile::VERSION'` ```

- Create a PR with these changes, have it reviewed and approved, and merged to main.

## Create a GitHub release

On [the rspec_fixture_file releases page](https://github.com/main-branch/rspec_fixture_file/releases),
select `Draft a new release`

- Select the tag corresponding to the version being released `v1.1.0.pre1`
- The Target should be `main`
- For the release description, copy the relevant section from the CHANGELOG.md
  - The release description can be edited later.
- Select the appropriate value for `This is a pre-release`
  - Since `v1.1.0.pre1` is a pre-release, check `This is a pre-release`

## Build and release the gem

Clone [main-branch/rspec_fixture_file](https://github.com/main-branch/rspec_fixture_file) directly (not a
fork) and ensure your local working tree is on the main branch

- Verify that you are not on a fork with the command `git remote -v`
- Verify that the version number is correct by running `rake -T` and inspecting
  the output for the `release[remote]` task

Build the git gem and push it to rubygems.org with the command `rake release`

- Ensure that your `gem sources list` includes `https://rubygems.org` (in my
  case, I usually have my work’s internal gem repository listed)
