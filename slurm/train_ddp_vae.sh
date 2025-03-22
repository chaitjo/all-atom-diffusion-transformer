"""Copyright (c) Meta Platforms, Inc. and affiliates."""

#!/bin/bash
#! Name of the job:
#SBATCH -J vae
#SBATCH -o /home/ckj24/rds/hpc-work/all-atom-diffusion-transformer/slurm/logs/train%j.out # File to which STDOUT will be written
#SBATCH -o /home/ckj24/rds/hpc-work/all-atom-diffusion-transformer/slurm/logs/train%j.err # File to which STDERR will be written

#! Which project should be charged (NB Wilkes2 projects end in '-GPU'): 
#SBATCH --account T2-CS181-GPU
#! How many whole nodes should be allocated? 

#! Partition:
#! Do not change:
#SBATCH -p ampere

#! How many whole compute nodes should be allocated?
#SBATCH --nodes=1

#! How many total CPU tasks will there be in total?
#! Note probably this should not exceed the total number of GPUs in use.
#SBATCH --ntasks=1 
###SBATCH --ntasks-per-node=8

#! Specify the number of GPUs per node (between 1 and 8).
#SBATCH --gres=gpu:8
###SBATCH --gpus-per-node=8

#! Specify the number of CPUs for your job. You should always allocate only 10 CPUs per requested GPU.
#! Requesting less than 10 CPUs per GPU will make the GPU efficiency low.
####SBATCH --cpus-per-task=10

#! How much memory is required? (default to 64GB if not specified)
####SBATCH --mem=64GB

#! How much wallclock time will be required? (at most 72:00:00 in general)
#SBATCH --time=72:00:00

#! What types of email messages do you wish to receive? 
#SBATCH --mail-type=begin 
#SBATCH --mail-type=end 
#SBATCH --mail-user=ckj24

#! sbatch directives end here (put any additional directives above this line)

############################################################
#! Modify the settings below to specify the application's environment, location
#! and launch method:

#! Optionally modify the environment seen by the application
#! (note that SLURM reproduces the environment at submission irrespective of ~/.bashrc):
./etc/profile.d/modules.sh                 # Enables the module command
module purge                               # Removes all modules still loaded
module load rhel8/default-amp              # REQUIRED - loads the basic environment 

#! Insert additional module load commands after this line if needed:
module unload miniconda/3 
module load cuda/11.8

#! Load python environment
source /home/ckj24/.bashrc
mamba activate /home/ckj24/rds/hpc-work/envs/myenv

############################################################

#! Full path to application executable:
application="srun python /home/ckj24/all-atom-diffusion-transformer/src/train_autoencoder.py"

#! Set hparams in configs/autoencoder_module/vae.yaml, or below:
latent_dim=8  # 4 / 8
loss_kl=0.00001  # 0.0001 / 0.00001

#! (for logging purposes)
latent_str="latent@${latent_dim}"
kl_str="kl@${loss_kl}"
name="vae_${latent_str}_${kl_str}"

#! Run options for the application:
options="trainer=ddp logger=wandb name=$name ++autoencoder_module.latent_dim=$latent_dim ++autoencoder_module.loss_weights.loss_kl.mp20=$loss_kl ++autoencoder_module.loss_weights.loss_kl.qm9=$loss_kl"

#! Work directory (i.e. where the job will run):
workdir="/home/ckj24/all-atom-diffusion-transformer/"

CMD="$application $options"

###############################################################
### You should not have to change anything below this line ####
###############################################################

cd $workdir
echo -e "Changed directory to `pwd`.\n"

JOBID=$SLURM_JOB_ID

echo -e "JobID: $JOBID\n======"
echo "Time: `date`"
echo "Running on master node: `hostname`"
echo "Current directory: `pwd`"
echo "CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES"

echo -e "\nExecuting command:\n==================\n$CMD\n"

eval $CMD
