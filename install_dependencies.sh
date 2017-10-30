#!/bin/bash

set -x
set -e

cpanm Dist::Zilla
dzil authordeps --missing | cpanm
dzil listdeps --missing | cpanm
#cpanm DBICx::TestDatabase File::Slurp YAML::XS XML::TreePP

set +eu
set +x
