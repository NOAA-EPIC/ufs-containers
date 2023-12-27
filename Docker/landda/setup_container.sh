#!/bin/bash
#set -x


Help()
{
    # Display Help
    echo "This script sets up the Land DA workflow to run on Derecho and Gaea."
    echo
    echo "Syntax: ./setup_container.sh [-h|-p=<platform>]"
    echo "options:"
    echo "-h     Prints out help function."
    echo "-p     Name of platform you are running on. Only Derecho and Gaea are accepted."
}


while getopts "h:p:" flag;
do 
    case "${flag}" in 
	h) Help
           exit;;
	p) platform=${OPTARG}

    esac
done


if [[ "$platform" =~ derecho ]]; then

     echo "Updating do_submit_cycle.sh file with PBS info for Derecho."
     sed -i 's|#SBATCH --account=|#PBS -A |g' do_submit_cycle.sh
     sed -i 's|#SBATCH --account|#PBS -A|g' do_submit_cycle.sh
     sed -i '/export MPIEXEC=/c export MPIEXEC=/glade/u/apps/derecho/23.06/spack/opt/spack/intel-oneapi-mpi/2021.8.0/oneapi/2023.0.0/mhf4/mpi/2021.8.0/bin/mpiexec' do_submit_cycle.sh
     sed -i 's|sbatch|qsub|g' do_submit_cycle.sh

     echo "Updating submit_cycle.sh file with PBS info for Derecho."
     sed -i '/^#SBATCH/d' submit_cycle.sh
     sed -i '2i #PBS -N ufs_land_da' submit_cycle.sh 
     sed -i '3i #PBS -A NRAL0032' submit_cycle.sh
     sed -i '4i #PBS -q main' submit_cycle.sh
     sed -i '5i #PBS -l select=1:mpiprocs=6:ncpus=6' submit_cycle.sh
     sed -i '6i #PBS -l walltime=00:30:00' submit_cycle.sh
     sed -i '7i #PBS -V' submit_cycle.sh
     sed -i '8i #PBS -o log_noahmp.%j.log' submit_cycle.sh
     sed -i '9i #PBS -e err_noahmp.%j.err' submit_cycle.sh

     sed -i 's|sbatch|qsub|g' submit_cycle.sh

elif [[ "$platform" =~ gaea ]]; then

    echo "Updating do_submit_cycle.sh file with srun for Gaea."
    sed -i 's|MPIEXEC=`which mpiexec`|MPIEXEC=`which srun`|g' do_submit_cycle.sh

    echo "Updating submit_cycle.sh file with Gaea specific info and srun."
    sed -i '11i #SBATCH --clusters=c5' submit_cycle.sh
    sed -i '12i #SBATCH --partition=batch' submit_cycle.sh
    sed -i 's|MPIRUN:-`which mpiexec`|MPIRUN:-`which srun`|g' submit_cycle.sh
    sed -i 's|${MPIRUN} -n ${TASKS}|${MPIRUN} -n ${TASKS} --mpi=pmi2|g' submit_cycle.sh
    
    echo "Updating DA_update/do_landDA.sh file with Gaea specific info."
    sed -i 's|${MPIEXEC} -n $NPROC_JEDI|${MPIEXEC} -n $NPROC_JEDI --mpi=pmi2|g' DA_update/do_landDA.sh

    echo "Updating module_check.sh file with srun for Gaea."
    sed -i 's|mpiexec|srun|g' module_check.sh 

else
     echo "Platform doesn't exist! Exiting!"
     exit
fi
