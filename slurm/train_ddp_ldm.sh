#!/bin/bash
#! Name of the job:
#SBATCH -J ldm
#SBATCH -o /home/ckj24/rds/hpc-work/all-atom-diffusion-transformer/slurm/logs/GEOM/train_ldm_%j.out # File to which STDOUT will be written
#SBATCH -e /home/ckj24/rds/hpc-work/all-atom-diffusion-transformer/slurm/logs/GEOM/train_ldm_%j.err # File to which STDERR will be written

#! Which project should be charged (NB Wilkes2 projects end in '-GPU'):
#SBATCH --account T2-CS181-GPU
###SBATCH --account LIO-SL2-GPU
#! How many whole nodes should be allocated?

#! Partition:
#! Do not change:
#SBATCH -p ampere

#! How many whole compute nodes should be allocated?
#SBATCH --nodes=1

#! How many total CPU tasks will there be in total?
#! Note probably this should not exceed the total number of GPUs in use.
#SBATCH --ntasks=1

#! Specify the number of GPUs per node (between 1 and 8).
#SBATCH --gres=gpu:4

#! How much wallclock time will be required? (at most 72:00:00 in general)
#SBATCH --time=36:00:00

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
bash /etc/profile.d/modules.sh             # Enables the module command
module purge                               # Removes all modules still loaded
module load rhel8/default-amp              # REQUIRED - loads the basic environment

#! Insert additional module load commands after this line if needed:
module unload miniconda/3
module load cuda/12.1
module load gcc/11
module list                                # Lists the modules loaded

#! Load python environment
source /home/ckj24/.bashrc
mamba activate /home/ckj24/rds/hpc-work/envs/myenv
export LD_LIBRARY_PATH=/home/ckj24/rds/hpc-work/envs/myenv/lib:$LD_LIBRARY_PATH

############################################################

#! Full path to application executable:
application="srun python /home/ckj24/adit-geom/src/train_diffusion.py"

#! Set autoencoder_ckpt and hparams in configs/diffusion_module/ldm.yaml, or below:
d_x=8  # 4 / 8
kl=0.00001  # 0.0001 / 0.00001
num_layers=24  # 12, 12, 24
d_model=1024  # 384, 768, 1024
nhead=16  # 6, 12, 16
# for DiT-L, add to options: ++data.datamodule.batch_size.train=64 ++trainer.accumulate_grad_batches=4

#! (for logging purposes)
name="DiT-L__vae_latent@${d_x}_kl@${kl}_GEOM_resume1505"

#! Resume from checkpoint:
ckpt_path="/home/ckj24/adit-geom/logs/train_diffusion/runs/DiT-L__vae_latent@8_kl@0.00001_GEOM_2025-05-13_22-38-03/checkpoints/last.ckpt"

#! Run options for the application:
options="++data.datamodule.batch_size.train=64 ++trainer.accumulate_grad_batches=4 ckpt_path=$ckpt_path trainer=ddp logger=wandb name=$name ++diffusion_module.denoiser.num_layers=$num_layers ++diffusion_module.denoiser.d_model=$d_model ++diffusion_module.denoiser.nhead=$nhead ++diffusion_module.denoiser.d_x=$d_x"

#! Work directory (i.e. where the job will run):
workdir="/home/ckj24/adit-geom/"

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
