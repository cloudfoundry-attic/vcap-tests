# vcap-tests

This repository contains tests for [vcap](https://github.com/cloudfoundry/vcap).

# What is vcap-tests ?

The tests repo contains the basic verification tests used to quickly validate
that a release is functional. It has a position in the overall vcap namespace
at vcap/tests and uses the git submodule mechanism to be mounted in that
location.

# Dependencies

Maven and the JDK are required to run these tests, in addition to the dependencies
which are installed via [vcap_dev_setup](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/bin/vcap_dev_setup).

On Ubuntu you can install these dependencies with

    sudo apt-get install maven2 default-jdk

# Running Tests

You can see the full list of different testing tasks with:

    rake -T

To run the main test suite:

    rake tests

# Submodules

This repo contains [vcap-test-assets](https://github.com/cloudfoundry/vcap-test-assets) as a submodule located at the ./assets directory.

# License

Cloud Foundry uses the Apache 2.0 license. See
[LICENSE](https://github.com/cloudfoundry/vcap-tests/blob/master/LICENSE) for details.

# Installation Notes

Complete installation notes are present in the vcap
[README.md](https://github.com/cloudfoundry/vcap/blob/master/README.md).

# Copyright

Copyright (c) 2009-2012 VMware, Inc.

# File a Bug

To file a bug against Cloud Foundry Open Source and its components, sign up and use our
bug tracking system: [http://cloudfoundry.atlassian.net](http://cloudfoundry.atlassian.net)
