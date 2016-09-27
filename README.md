s3repo
=========

[![Gem Version](https://img.shields.io/gem/v/s3repo.svg)](https://rubygems.org/gems/s3repo)
[![Dependency Status](https://img.shields.io/gemnasium/amylum/s3repo.svg)](https://gemnasium.com/amylum/s3repo)
[![Build Status](https://img.shields.io/circleci/project/amylum/s3repo/master.svg)](https://circleci.com/gh/amylum/s3repo)
[![Coverage Status](https://img.shields.io/codecov/c/github/amylum/s3repo.svg)](https://codecov.io/github/amylum/s3repo)
[![Code Quality](https://img.shields.io/codacy/eef971ff937642219c1d4094001c33e7.svg)](https://www.codacy.com/app/akerl/s3repo)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

Simple library for interacting with an Archlinux repo stored in S3

## Usage

### From the command line

This tool provides an `s3repo` script that can be used to manage an S3 bucket with packages. It is configured via environment variable:

* AWS_ACCESS_KEY_ID -- Used by the AWS API library to authenticate for the S3 bucket
* AWS_SECRET_ACCESS_KEY -- Used by the AWS API library to authenticate for the S3 bucket
* AWS_REGION -- Used by the AWS API library to know which region to use for the bucket
* S3_BUCKET -- Controls which S3 bucket is used for packages
* MAKEPKG_FLAGS -- Flags used for makepkg calls when building packages
* S3REPO_TMPDIR -- Sets the temp path for local cache of metadata files. Optional, otherwise looks up a path from the system
* S3REPO_SIGN_DB -- Set to sign the DB metadata
* S3REPO_SIGN_PACKAGES -- Set to sign the packages

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

### From Ruby code

I use this primarily for serving the packages using [amylum/server](https://github.com/amylum/server). Like the command line tool, it expects AWS API credentials via environment variables, but you can pass in the bucket using either environmnt or a parameter when creating your S3Repo object:

```
repo = S3Repo.new(bucket: 'my_bucket')
```

You can call build_packages, add_packages, remove_packages, and prune_files on this, which work almost exactly as their command line counterparts above.

The library also offers `.packages` and `.signatures`, which return arrays of packages and signatures in the bucket. You can use `.include? 'package_name'` to check for a package.

To get the contents of a file, call `.serve 'package_name'`.

## Installation

    gem install s3repo

## License

s3repo is released under the MIT License. See the bundled LICENSE file for details.

