#! /usr/bin/env bash
function atparse {
    local __set_x
    [ -o xtrace ] && __set_x='set -x' || __set_x='set +x'
    set +x
    # Use __ in names to avoid clashing with variables in {var} blocks.
    local __text __before __after __during
    for __text in "$@" ; do
        if [[ $__text =~ ^([a-zA-Z][a-zA-Z0-9_]*)=(.*)$ ]] ; then
            eval "local ${BASH_REMATCH[1]}"
            eval "${BASH_REMATCH[1]}="'"${BASH_REMATCH[2]}"'
        else
            echo "ERROR: Ignoring invalid argument $__text\n" 1>&2
        fi
    done
    while IFS= read -r __text ; do
        while [[ "$__text" =~ ^([^@]*)(@\[[a-zA-Z_][a-zA-Z_0-9]*\]|@\[\'[^\']*\'\]|@\[@\]|@)(.*) ]] ; do
            __before="${BASH_REMATCH[1]}"
            __during="${BASH_REMATCH[2]}"
            __after="${BASH_REMATCH[3]}"
#            printf 'PARSE[%s|%s|%s]\n' "$__before" "$__during" "$__after"
            printf %s "$__before"
            if [[ "$__during" =~ ^@\[\'(.*)\'\]$ ]] ; then
                printf %s "${BASH_REMATCH[1]}"
            elif [[ "$__during" == '@[@]' ]] ; then
                printf @
            elif [[ "$__during" =~ ^@\[([a-zA-Z_][a-zA-Z_0-9]*)\] ]] ; then
                eval 'printf %s "$'"${BASH_REMATCH[1]}"'"'
            else
                printf '%s' "$__during"
            fi
            if [[ "$__after" == "$__text" ]] ; then
                break
            fi
            __text="$__after"
        done
        printf '%s\n' "$__text"
    done
    eval "$__set_x"
}

function test_atparse {
    # Note that these cannot be local since they will be invisible
    # to atparse:
    testvar='[testvar]'
    var1='[var1]'
    var2='[var2]'
    cat<<\EOF | atparse var3='**'
Nothing special here. = @['Nothing special here.']
[testvar] = @[testvar]
[var1] [var2] = @[var1] @[var2]
** = @[var3]
@ = @[@] = @['@']
-n
 eval "export PE$c=\${PE$c:-0}" = @[' eval "export PE$c=\${PE$c:-0}"']
EOF
    echo "After block, \$var3 = \"$var3\" should be empty"
}

function compute_petbounds() {

  # each test MUST define ${COMPONENT}_tasks variable for all components it is using
  # and MUST NOT define those that it's not using or set the value to 0.

  # ATM is a special case since it is running on the sum of compute and io tasks.
  # CHM component and mediator are running on ATM compute tasks only.

  local n=0
  unset atm_petlist_bounds ocn_petlist_bounds ice_petlist_bounds wav_petlist_bounds chm_petlist_bounds med_petlist_bounds aqm_petlist_bounds

  # ATM
  ATM_io_tasks=${ATM_io_tasks:-0}
  if [[ $((ATM_compute_tasks + ATM_io_tasks)) -gt 0 ]]; then
     atm_petlist_bounds="${n} $((n + ATM_compute_tasks + ATM_io_tasks -1))"
     n=$((n + ATM_compute_tasks + ATM_io_tasks))
  fi

  # OCN
  if [[ ${OCN_tasks:-0} -gt 0 ]]; then
     ocn_petlist_bounds="${n} $((n + OCN_tasks - 1))"
     n=$((n + OCN_tasks))
  fi

  # ICE
  if [[ ${ICE_tasks:-0} -gt 0 ]]; then
     ice_petlist_bounds="${n} $((n + ICE_tasks - 1))"
     n=$((n + ICE_tasks))
  fi

  # WAV
  if [[ ${WAV_tasks:-0} -gt 0 ]]; then
     wav_petlist_bounds="${n} $((n + WAV_tasks - 1))"
     n=$((n + WAV_tasks))
  fi

  # CHM
  chm_petlist_bounds="0 $((ATM_compute_tasks - 1))"

  # MED
  med_petlist_bounds="0 $((ATM_compute_tasks - 1))"

  # AQM
  aqm_petlist_bounds="0 $((ATM_compute_tasks - 1))"

  UFS_tasks=${n}

  echo "ATM_petlist_bounds: ${atm_petlist_bounds:-}"
  echo "OCN_petlist_bounds: ${ocn_petlist_bounds:-}"
  echo "ICE_petlist_bounds: ${ice_petlist_bounds:-}"
  echo "WAV_petlist_bounds: ${wav_petlist_bounds:-}"
  echo "CHM_petlist_bounds: ${chm_petlist_bounds:-}"
  echo "MED_petlist_bounds: ${med_petlist_bounds:-}"
  echo "AQM_petlist_bounds: ${aqm_petlist_bounds:-}"
  #echo "UFS_tasks         : ${UFS_tasks:-}"

}
