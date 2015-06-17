#!/bin/bash

set -x
set -e

start_dir=$(pwd)

cpanm Dist::Zilla
dzil authordeps --missing | cpanm
cpanm DBICx::TestDatabase File::Slurp YAML::XS XML::TreePP

set +eu
set +x
