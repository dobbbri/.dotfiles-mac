#!/bin/bash

# git clone git@github.com:dobbbri/dotfiles.git
# git clone git@github.com:elisapetcare/epc_in_dev.git
# git clone git@github.com:dobbbri/elisa_pet_care_v2.git
# git clone git@github.com:dobbbri/Projects.git

echo "Add Sites Folder -----------------------------------------------------------"
mkdir -p ~/Sites

cd ~/Sites

git clone git@github.com:dobbbri/videira-blog-2025.git
git clone git@github.com:dobbbri/espaco_videira_2025.git
git clone git@github.com:dobbbri/terapeuta_luciana_2025.git

git clone git@github.com:dobbbri/pousada_do_tucunare_2026.git
git clone git@github.com:dobbbri/pousada_do_tucunare_2020.git
git clone git@github.com:dobbbri/pousada_do_tucunare.git

git clone git@github.com:elisapetcare/epc_in_dev.git
git clone git@github.com:dobbbri/elisa_pet_care_v2.git
git clone git@github.com:dobbbri/epc_in_dev_v2_audios_colors.git
git clone git@github.com:elisapetcare/elisa_pet_care_lp_2025.git

cd ~
