mamba create -n myenv python=3.10 -c defaults
mamba activate myenv
mamba install -y pytorch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 pytorch-cuda=12.1 -c pytorch -c nvidia -c defaults
pip install torch_geometric
pip install torch_scatter torch_cluster -f https://data.pyg.org/whl/torch-2.3.0+cu121.html
pip install lightning==2.4.0 hydra-core==1.* hydra-colorlog
mamba install -y ase==3.23.0  # individually installed due to dependency conflict
mamba install -y matminer==0.9.2  # individually installed due to dependency conflict
mamba install -y smact==2.6  # individually installed due to dependency conflict
mamba install -y openbabel==3.1.1  # individually installed due to dependency conflict
mamba install -y jupyterlab pandas seaborn joblib yaml -c conda-forge
pip install pyxtal==0.6.7 mofchecker==0.9.6 rdkit==2024.3.5 e3nn==0.5.1 posebusters==0.3.1 download==0.3.5 ipdb wandb rootutils rich pathos p-tqdm einops svgwrite cairosvg reportlab lmdb torchdiffeq huggingface_hub pre-commit
pre-commit install
