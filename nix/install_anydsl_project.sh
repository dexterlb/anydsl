#!/bin/bash

set -euo pipefail
shopt -s nullglob

function fix_rpath {
    old_rpath="$(patchelf --print-rpath "${1}")"
    rpath="$(echo "${old_rpath}" | sed -r "s|${build_dir}|${out}|g")"
    echo "changing RPATH of $1 from ${old_rpath} to ${rpath}" >&2

    patchelf --set-rpath "${rpath}" "${1}"
}

out="${1}"
build_dir="$(pwd)"
source_dir="$(readlink -f $build_dir/..)"

mkdir -p "${out}"

# So, anydsl doesn't define a CMake "Install" target,
# and since the developers haven't bothered to create one,
# I'm guessing there's some roadblock to this.
# I will look into it in the future, but for now, I'm lazy.
# Thus, I'm "installing" the artefacts in the old-fashioned way:
if [[ -d "${build_dir}"/include ]]; then
    mkdir -p "${out}"/include
    cp -rvaf "${source_dir}"/src/* "${out}"/include

    chmod -R u+w ${out}/include
    find ${out}/include -type f -not -iname '*.h' -delete
    find ${out}/include -type d -empty -delete
    cp -rvaf "${build_dir}"/include "${out}"/
fi

if [[ -d "${source_dir}"/cmake/modules ]]; then
    mkdir -p "${out}"/share/anydsl/cmake
    cp -rvaf "${source_dir}"/cmake/modules ${out}/share/anydsl/cmake/
fi

for dir in "${build_dir}"/{bin,lib,share}; do
    if [[ ! -d "${dir}" ]]; then
        continue
    fi
    cp -rvaf "${dir}"/ "${out}"/
done

while read binary; do
    if ! file "${binary}" | grep -q ELF; then
        continue
    fi
    fix_rpath "${binary}"
done < <(find "${out}" -type f -iname '*.so' -o -iname '*.a' -o -path '*/bin/*')

# However, the built artefacts contain references to the build dir.
# So I present this abomination for removing them:
sed -r -e "s:$build_dir/(bin|lib|share|include):$out/\1:g" -e "s:;$source_dir/src[^\";]*::g" -i $out/share/anydsl/cmake/*.cmake
sed -r -e ":$build_dir:d" -i $out/share/anydsl/cmake/*-config.cmake

# This is a massive hack. Instead of doing this, we should coerce cmake
# to output a proper tree that doesn't reference the build dir. TODO.
