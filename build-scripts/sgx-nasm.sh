#!/bin/sh

set -e

if test "$1" == "-v"
then
    exec nasm -v
else
    here=$(dirname $0)
    echo python ${here}/sgx-asm-pp.py --assembler=nasm --MITIGATION-CVE-2020-0551=${MITIGATION} "$@"
    exec python ${here}/sgx-asm-pp.py --assembler=nasm --MITIGATION-CVE-2020-0551=${MITIGATION} "$@"
fi
