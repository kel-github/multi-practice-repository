##### written by K. Garner 2018
##### what this code does:
##### 1. load packages
##### 2. simulate and plot HRFs
##### 3. Save
rm(list=ls())
#########################################################################################
# 1. load packages
library(wesanderson)
library(dplyr)
library(tidyr)
library(ggplot2)
library(neuRosim)

# set working directory to current
setwd("~/Dropbox/QBI/mult-conn/multi-practice-repository/produce_model_space_plots")
#########################################################################################
# using the neuRosim package, I simulate a HRF fpr single and multitask conditions (making the HRF
# slightly smaller for single tasks)
hrf = data.frame(time = rep(seq(0,30,.1), times=2),
                 hrf  = c(canonicalHRF(seq(0,30,.1), param=list(a1=6, a2=12, b1=0.7, b2=0.7, c=.35)), 
                          canonicalHRF(seq(0,30,.1), param=list(a1=16, a2=22, b1=0.9, b2=0.9, c=.35))),    
                 cond = rep(c("ST", "MT"), each = 301))
hrf$cond <- factor(as.character(hrf$cond), c("ST", "MT"))
# now make a simple line graph coloured by condition
pdf("HRF_sim.pdf", width=1, height=1)
ggplot(hrf, aes(x=time, y=hrf, group=cond)) + 
  geom_line(size=1.2, aes(color=cond)) +
  scale_color_manual(values=wes_palette("Chevalier1")[c(1,3)]) +
  theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
                     text=element_text(size=8),
                     axis.text.x = element_blank(),
                     axis.text.y = element_blank(),
                     legend.position ='none') + ylab("HRF") + xlab("time")
dev.off()
                     