"""Copyright (c) Meta Platforms, Inc. and affiliates."""

import os
import pickle
import warnings
from typing import Callable, List, Optional

import numpy as np
import torch
from rdkit import Chem
from torch_geometric.data import Data, InMemoryDataset
from tqdm import tqdm

warnings.simplefilter("ignore", UserWarning)
warnings.simplefilter("ignore", DeprecationWarning)


class GEOM(InMemoryDataset):
    """
    GEOM-DRUGS dataset as a PyG InMemoryDataset.

    In order to create a torch_geometric.data.InMemoryDataset, you need to implement four fundamental methods:
    - InMemoryDataset.raw_file_names(): A list of files in the raw_dir which needs to be found in order to skip the download.
    - InMemoryDataset.processed_file_names(): A list of files in the processed_dir which needs to be found in order to skip the processing.
    - InMemoryDataset.download(): Downloads raw data into raw_dir.
    - InMemoryDataset.process(): Processes raw data and saves it into the processed_dir.

    Args:
        root (str): Root directory where the dataset should be saved.
        transform (callable, optional): A function/transform that takes in an
            :obj:`torch_geometric.data.Data` object and returns a transformed
            version. The data object will be transformed before every access.
            (default: :obj:`None`)
        pre_transform (callable, optional): A function/transform that takes in
            an :obj:`torch_geometric.data.Data` object and returns a
            transformed version. The data object will be transformed before
            being saved to disk. (default: :obj:`None`)
        pre_filter (callable, optional): A function that takes in an
            :obj:`torch_geometric.data.Data` object and returns a boolean
            value, indicating whether the data object should be included in the
            final dataset. (default: :obj:`None`)
        force_reload (bool, optional): Whether to re-process the dataset.
            (default: :obj:`False`)
    """

    def __init__(
        self,
        root: str,
        transform: Optional[Callable] = None,
        pre_transform: Optional[Callable] = None,
        pre_filter: Optional[Callable] = None,
        force_reload: bool = False,
    ) -> None:
        super().__init__(root, transform, pre_transform, pre_filter, force_reload=force_reload)
        self.load(self.processed_paths[0])

    @property
    def raw_file_names(self) -> List[str]:
        return ["train.pt", "val.pt", "test.pt"]

    @property
    def processed_file_names(self) -> List[str]:
        return ["geom.pt"]

    def download(self) -> None:
        return

    def process(self) -> None:
        return


# Separate processing script to convert raw data to PyG format
# Raw pickle files downloaded from https://github.com/cvignac/MiDi

# import pickle
# import torch
# from rdkit import Chem
# from torch_geometric.data import Data
# from tqdm.auto import tqdm


# for split in ['val', 'test', 'train']:

#     with open(f"raw/{split}_data.pickle", 'rb') as f:
#         raw_data_list = pickle.load(f)
#     print(f"Loaded {len(raw_data_list)} entries from {split} set")

#     pyg_data_list = []
#     smiles_list = []
#     for entry_idx, entry in tqdm(enumerate(raw_data_list), total=len(raw_data_list)):

#         smiles, data = entry
#         for conformer_idx, mol in enumerate(data):
#             if conformer_idx >= 5:
#                 break

#             N = mol.GetNumAtoms()

#             # 3D coordinates
#             pos = mol.GetConformer().GetPositions()
#             pos = torch.tensor(pos, dtype=torch.float)

#             # Atom types
#             atomic_number = []
#             for atom in mol.GetAtoms():
#                 atomic_number.append(atom.GetAtomicNum())
#             z = torch.tensor(atomic_number, dtype=torch.long)

#             # Metadata
#             smiles = Chem.MolToSmiles(mol, isomericSmiles=True)
#             id = f"geom_{split}_{entry_idx}_{conformer_idx}"

#             pyg_data = Data(
#                 id=id,
#                 atom_types=z,
#                 pos=pos,
#                 # frac_coords=torch.zeros_like(pos),
#                 # cell=torch.zeros((1, 3, 3)),
#                 # lattices=torch.zeros(1, 6),
#                 # lattices_scaled=torch.zeros(1, 6),
#                 # lengths=torch.zeros(1, 3),
#                 # lengths_scaled=torch.zeros(1, 3),
#                 # angles=torch.zeros(1, 3),
#                 # angles_radians=torch.zeros(1, 3),
#                 # num_atoms=torch.LongTensor([N]),
#                 # num_nodes=torch.LongTensor([N]),  # special attribute used for PyG batching
#                 # spacegroup=torch.zeros(1, dtype=torch.long),  # null spacegroup
#                 # token_idx=torch.arange(N),
#                 # dataset_idx=torch.tensor([1], dtype=torch.long),  # 1 --> indicates non-periodic/molecule
#             )
#             pyg_data_list.append(pyg_data)
#             smiles_list.append(smiles)

#     # Save the data
#     print(f"Saving {len(pyg_data_list)} entries to {split} set")
#     torch.save(pyg_data_list, f"new/{split}.pt")
#     torch.save(smiles_list, f"new/{split}_smiles.pt")
