set -e

export DAPP_SRC=${DAPP_SRC-src}
export DAPP_FLAT=${DAPP_FLAT-flat}
export DAPP_OUT=${DAPP_OUT-out}
export DAPP_JSON=${DAPP_JSON-${DAPP_OUT}/dapp.sol.json}

(set -x; rm -rf "${DAPP_FLAT?}")
mkdir -p "$DAPP_FLAT"

(dapp build)

find "$DAPP_SRC" -not \( -path ${DAPP_SRC}/common -prune \) -not \( -path ${DAPP_SRC}/test -prune \) -not \( -path ${DAPP_SRC}/interfaces -prune \) -name '*.sol' | while read -r x; do
  filename=$(basename -- $x .sol)
  flat_file="${DAPP_FLAT}/${filename}.f.sol"
  (set -x; hevm flatten --source-file "$x" --json-file "${DAPP_JSON}" >"$flat_file")
done
