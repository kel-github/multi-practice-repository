# the modulatory influence of training on the brain network that underpins multitasking

Analysis code for investigation of how multitasking and practice influence cortico-striatal connectivity  
Link to the data:  https://espace.library.uq.edu.au/view/UQ:370251  
Link to the paper: https://www.biorxiv.org/content/10.1101/564450v1  

(c) Kelly Garner, 2018  
Free to use and share, please cite author/source  

This repository contains analysis code for preprocessing and running a DCM analysis on the data collected in the paper [Garner & Dux, 2015. Training conquers multitasking costs by dividing task representations in the frontoparietal-subcortical system. PNAS, 112(46)](http://www.pnas.org/content/112/46/14372)   

and [Garner, K., Garrido, M.I., & Dux, P.E. 2019. Cognitive capacity limits are remediated by practice-induced plasticity in a striatal-cortical network](https://www.biorxiv.org/node/201991.external-links.html)


### how to use this repository:
To get a summary of the outcomes from the analyses, you can read the markdown summaries in each of these folders:  
*s1_multitask_network_dcm_analysis_code*  
*s1s2_mtOut_practice_dcm_analysis_code* - for the influence of practice on the single-task trials  
*s1s2_singOut_practice_dcm_analysis_code* - for the influence of practice on multi-task trials  

If you want to follow the steps of the analyses, you can read the code and comments in the following files:  
*s1_multitask_network_dcm_analysis_code/run_analysis.m*  
*s1s2_mtOut_practice_dcm_analysis_code/run_analysis.m*  
*s1s2_singOut_practice_dcm_analysis_code/run_analysis.m*  

If you want to rerrun the analyses, then download the code in this repository and the data at link:   
Use the 'run_analysis.m' files above for guidelines on how to structure the analysis and data directories for easy code use  

To produce the figures from the paper linked to above, follow the code in the releveant produce_blahblah_plots  

Any questions? getkellygarner@gmail.com  
