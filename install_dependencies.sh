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
cpanm DBICx::TestDatabase JSON File::Slurp YAML::XS LWP::UserAgent XML::TreePP URI::Escape

set +eu
set +x
