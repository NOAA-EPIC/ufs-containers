#!/bin/bash 
set -euo pipefail

work_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly work_dir

readonly ARGC=$#

if [[ ${ARGC} -lt 2 &&  ${ARGC} -gt 0 ]]; then
  echo "Usage: $0 [INTEL-SANDBOX TARGET-SANDBOX ]"
  echo "INTEL-SANDBOX and TARGET-SANDBOX are sandbox names relative to the current directory"
  echo "Usage incorrect, provide two arguments exactly, or no arguments to use default names,"
  echo "Please try again..."
  exit 1
else
  intel_sandbox=${1:-intel-sandbox}
  target_sandbox=${2:-rocky9-oneapi2024.2-ss192}
  echo "INTEL-SANDBOX is ${work_dir}/$intel_sandbox "
  echo "TARGET-SANDBOX is ${work_dir}/$target_sandbox "
fi  

cmd=${CMD:-cp -r}

mkdir -p  ${work_dir}/${target_sandbox}/opt/intel/oneapi
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/2024.2  ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/basekit  ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/hpckit  ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/compiler ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/common ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/debugger ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/dev-utilities ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/diagnostics ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/dpl ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/licensing ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/mkl ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/mpi ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/*.sh ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/support.txt ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/tbb ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/tcm ${work_dir}/${target_sandbox}/opt/intel/oneapi/.
${cmd} ${work_dir}/${intel_sandbox}/opt/intel/oneapi/.toolkit_linking_tool ${work_dir}/${target_sandbox}/opt/intel/oneapi/.

echo "Done: copying directories from  ${work_dir}/${intel_sandbox}/opt/intel/oneapi to ${work_dir}/${target_sandbox}/opt/intel/oneapi/ "

#rm -rf ${work_dir}/${intel_sandbox}
