
singularity \
run \
--bind INPUTS:/INPUTS \
--bind OUTPUTS:/OUTPUTS \
baxpr-ndw_wm_edat-master-v3.0.0.simg \
edat_dir /INPUTS/edats \
project UNK_PROJ2 \
subject UNK_SUBJ2 \
session UNK_SESS2 \
out_dir /OUTPUTS
