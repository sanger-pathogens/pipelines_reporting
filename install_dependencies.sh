#!/bin/bash

set -x
set -e

start_dir=$(pwd)

#Add self libs to PERL5LIB for tests to run
SELF_LIB=${start_dir}'/modules'

export PERL5LIB=${SELF_LIB}:$PERL5LIB

cd $start_dir

cpanm Dist::Zilla
dzil authordeps --missing | cpanm
cpanm DBICx::TestDatabase File::Slurp YAML::XS XML::TreePP

set +eu
set +x
