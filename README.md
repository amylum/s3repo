s3repo
=========

[![Gem Version](https://img.shields.io/gem/v/s3repo.svg)](https://rubygems.org/gems/s3repo)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/amylum/s3repo/build.yml?branch=main)](https://github.com/amylum/s3repo/actions)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

Simple library for interacting with an Archlinux repo stored in S3

## Usage

The canonical usage of this tool is by [my personal repo](https://github.com/amylum/repo/blob/master/Makefile), which uses s3repo.

### Config file

The config file is used to provide information about the repo:

```
repo_name: # this is used to name the metadata DB file for the repo
bucket: # where to upload the files
region: # what AWS region the bucket is in
makepkg_flags: # any flags to pass to makepkg
key: # GPG key ID to use for signing, assuming that signing is enabled
sign_db: # true/false to control signing
sign_packages: # true/false to control signing
template_dir: # where to find repo templates
template_params: # a key-value store of details to use in the templates
  example_key: example_value
```

### Managing the repo

#### Build a package

This assumes you're in the parent directory of your package's directory, which should contain its PKGBUILD and any other files it needs. It's essentially a wrapper around makepkg.

```
s3repo build bash
```

#### Upload a package

This takes an already built package and uploads its .pkg.tar.xz (and optionally .pkg.tar.xz.sig) to S3.

```
s3repo upload bash
```

#### Remove a package

This removes a named package from the repo metdata (it doesn't remove the actual package files, which you can do after this using prune).

```
s3repo remove bash-amylum-4.3p42_2-1-x86_64
```

#### Prune packages

This removes any files from S3 that aren't referenced in the metadata DB.

```
s3repo prune
```

## Installation

    gem install s3repo

## License

s3repo is released under the MIT License. See the bundled LICENSE file for details.

