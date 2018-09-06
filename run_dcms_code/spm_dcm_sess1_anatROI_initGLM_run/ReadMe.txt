Multitasking/DCM Analysis notes - Mon 21st May 2018
Analysis code run using fmri_euramoo_v7.pbs and dcm_analysis_v5.m
Dependent on spm12
Data backups stored in dropbox

spm_dcm_dat.zip https://www.dropbox.com/s/m1xbh4cd6s336rx/spm_dcm_dat.zip?dl=0

spm_dcm_run_sess1 – includes fitting of glm from session 1 to identify peaks via contrast of interest
(open single plus single vs multi) and fits a dcm to session 1 data, modelling the effects of multitasking only
idea is to run on 5 participants and check variance explained

dcm_analysis_v5 updated from v4 to include this capacity and adds the fitting of models with input to SMFC

Subs with errors during model fitting:
sub 128: SESSION 1 IMAGES ARE MISSING
sub 138: SESSION 2 FILES ARE MISSING
sub 223: SESSION 1 IMAGES ARE MISSING


Notes re: setting up

Manual definitions of subs 111-115 using multi > sing masked with open sing contrast inclusive
look for clusters of 4 voxels at p< .005
LIPL study def [-36 -55 44]     
LPut study def is [-25 8 1]
SMFC study def is [-8 -12 61]

sub 111
LIPL [-38.11 -38.24 41.38] Left BA 40
LPUT [-25 12 10] (strictly outside predefined areas)
SMFC [-4.33 -6.38 62] Left BA 6


sub 112 - used just open single-task contrast as no sig putamen when it masks the single vs multi contrast
LIPL [-36 -52 32] Left BA 39
LPut [-26 13 2]
SMFC [-16.5 -11 62] (outside defined BA's)

sub 113
LIPL [-36 -51 34.5] Left BA 39
LPUT [-26.09 14.44 2]
SMFC [-14 -11 62] (outside defined BA's)

sub 114
LIPL [-32 -54 44] Left BA-39
LPUT [-29 -2 -7] 
SMFC [-8 -14 61] Left BA-6

sub 115 - lots of activity
LIPL [-36 -55 44]  Left BA-39
LPUT [-25 8 1]
SMFC [-3 -12 62] Left BA-6





