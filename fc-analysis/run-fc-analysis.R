## written by K. Garner, 2020
# this is to conduct and plot a basic FC analysis, from the regions
# of interest in the left and right hemipheres of Garner et al 2020 https://doi.org/10.1101/564450
# as requested by the editor of eNeuro

rm(list=ls())

# load required packages and plotting resources
# --------------------------------------------------------------------------------
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(cowplot)
library(wesanderson)
library(BayesFactor)
library(rstatix)
source("../s2n_analysis/R_rainclouds.R")


# define functions 
# --------------------------------------------------------------------------------
get.data <- function(csv_file, data_path, conds, excl){
  # csv_file = csv file name
  # data_path = folder name of csv file
  # conds = 2 element vector of the two condition names
  data <- read.csv(paste('../', data_path, '/', csv_file, sep=""), header=F)
  names(data) <- c("IPL", "Put", "SMA", "sub", "cond")
  data$group <- NA
  data$group[data$sub < 200] <- "P"
  data$group[data$sub > 199] <- "C"
  data = data %>% filter(!(sub %in% excl)) # remove excl subs
  # label factors
  data$sub <- as.factor(data$sub)
  for (i in 1:length(conds))  data$cond[data$cond == i] <- conds[i]
  data$cond <- as.factor(data$cond)
  data$group <- factor(data$group, levels=c("P", "C"))
  data
}


get.cor.results <- function(data, pair, name){
  
  data %>% filter(region %in% pair) %>%
    group_by(sub, cond) %>%
    summarise(group=group[1],
              regions=name,
              r=cor(y[region==pair[1]], y[region==pair[2]]))
  
}

plot.cor.results <- function(data, title){
  
  ggplot(data, aes(x=regions, y=r, fill = cond, colour = cond)) +
    geom_flat_violin(aes(fill=cond), position = position_nudge(x = .25, y = 0), adjust=1.5, trim =
                       FALSE, alpha = 0.6) +
    geom_point(aes(x=regions, y=r, colour=cond), position = position_jitter(width = .15), size = .3) +
    geom_boxplot(aes(x = regions, y = r, fill=cond), outlier.shape = NA,
                 alpha = 0.8, width = .05, colour = "BLACK") +
    scale_color_manual(values=wes_palette("Royal1")) +
    scale_fill_manual(values=wes_palette("Royal1")) +
    ylab('r') + xlab('region pairing') + theme_cowplot() + 
    facet_wrap(~group, nrow=2) +
    theme(axis.text.x = element_text(face = "italic")) +
    ggtitle(title)
}


# define file variables
# --------------------------------------------------------------------------------
s1.LH.excl = c(102, 128, 138, 203)
s1.RH.excl = c(128, 203)
s2.LH.SING.excl = c(102, 128, 138, 144, 203)
s2.RH.SING.excl = c(102, 106, 128, 138, 144, 203)
s2.LH.MULT.excl = c(102, 128, 138, 144, 203)
s2.RH.MULT.excl = c(102, 104, 106, 128, 138, 144, 203)
data.dir = 'processed-data'
dat.csv = 's2_RH_MULT_tSERIES.csv'
roi_names = c("IPS", "Put", "SMA")
conds = c("Pre", "Post")
save.name = 'fc-s2-RH-MULT'
excl = s2.RH.MULT.excl
plot_title = "left: M PrevPost"
session = 2

###########################################################################################
# RUN CODE


data <- get.data(csv_file=dat.csv, data_path=data.dir, conds=conds, excl=excl) %>%
                 pivot_longer(c('IPL', 'Put', 'SMA'), names_to = "region", values_to="y") 

# if s1 run this code
data$cond <- factor(data$cond, levels=conds)

# run correlation by reg
reg.pair <- list(c("IPL", "Put"), c("Put", "SMA"), c("IPL", "SMA"))
reg.pair.name <- list(c("IPL-Put"), c("Put-SMA"), c("IPL-SMA"))
cor.results <- do.call(rbind, (mapply(get.cor.results, pair=reg.pair, name=reg.pair.name, MoreArgs=list(data=data), SIMPLIFY=FALSE)))
cor.results$regions <- factor(cor.results$regions, levels=do.call(cbind, reg.pair.name))

p <- plot.cor.results(cor.results, title=plot_title)
ggsave(paste(save.name, '.pdf', sep=''), plot = p, width=15, height=15, units="cm")
ggsave(paste(save.name, '.png', sep=''), plot = p, width=15, height=15, units="cm")

# ttests on the resulting correlation values
# IF SESSION ONE
if (session == 1){
 results.cond.comp <- with(cor.results, lapply(unique(regions), function(x) t.test(r[regions == x & cond == conds[1]],
                                                                                    r[regions == x & cond == conds[2]], var.equal = FALSE, paired=TRUE)))
 } else {
  results.cond.comp <- lapply(unique(cor.results$regions),
                              function(x) aov(r~(cond*group)+Error(sub/(cond))+(group),
                                              data=cor.results[cor.results$regions==x,]))
 }

## summarise results
cor.sum <- cor.results %>% group_by(cond, regions) %>%
  summarise(mean = mean(r),
            N = length(r),
            SE = sd(r)/sqrt(N))

summary(results.cond.comp[[1]])
###### Correction: Sidak
# (1 - α)^1/m
1-(.95^(1/3))
# = 0.01695243

###### s1 SINGLE vs MULTI -----------------------------------------------------------------------------------------
###### LEFT HEMISPHERE
# 1 S     IPL-Put 0.174    96 0.0166
# 2 S     Put-SMA 0.355    96 0.0159
# 3 S     IPL-SMA 0.266    96 0.0196
# 4 M     IPL-Put 0.183    96 0.0182
# 5 M     Put-SMA 0.374    96 0.0166
# 6 M     IPL-SMA 0.278    96 0.0213


# IPL-Put
# 
# Paired t-test
# 
# data:  r[regions == x & cond == conds[1]] and r[regions == x & cond == conds[2]]
# t = -1.012, df = 95, p-value = 0.3141
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -0.027231076  0.008842705
# sample estimates:
#   mean of the differences 
# -0.009194185 
# 
# 
# Put-SMA
# 
# Paired t-test
# 
# data:  r[regions == x & cond == conds[1]] and r[regions == x & cond == conds[2]]
# t = -1.9769, df = 95, p-value = 0.05095
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -3.696533e-02  7.800597e-05
# sample estimates:
#   mean of the differences 
# -0.01844366 
# 
# 
# IPL-SMA
# 
# Paired t-test
# 
# data:  r[regions == x & cond == conds[1]] and r[regions == x & cond == conds[2]]
# t = -1.1889, df = 95, p-value = 0.2374
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -0.030634662  0.007685414
# sample estimates:
#   mean of the differences 
# -0.01147462 

######## Right hemisphere
# IPL-Put
# 
# Paired t-test
# 
# data:  r[regions == x & cond == conds[1]] and r[regions == x & cond == conds[2]]
# t = -1.9175, df = 97, p-value = 0.05812
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -0.0366049308  0.0006309066
# sample estimates:
#   mean of the differences 
# -0.01798701 
# 
# 
# Put-SMA
# 
# Paired t-test
# 
# data:  r[regions == x & cond == conds[1]] and r[regions == x & cond == conds[2]]
# t = -1.8122, df = 97, p-value = 0.07305
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -0.033571780  0.001525436
# sample estimates:
#   mean of the differences 
# -0.01602317 
# 
# 
# IPL-SMA
# 
# Paired t-test
# 
# data:  r[regions == x & cond == conds[1]] and r[regions == x & cond == conds[2]]
# t = -2.7107, df = 97, p-value = 0.007941
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -0.045201864 -0.006988837
# sample estimates:
#   mean of the differences 
# -0.02609535 

###########################
#### SINGLE TASK - LH
# 1 Pre   IPL-Put 0.225    95 0.0153
# 2 Pre   Put-SMA 0.387    95 0.0152
# 3 Pre   IPL-SMA 0.315    95 0.0188
# 4 Post  IPL-Put 0.212    95 0.0154
# 5 Post  Put-SMA 0.335    95 0.0171
# 6 Post  IPL-SMA 0.301    95 0.0199

# IPL-Put
# Error: sub
# Df Sum Sq Mean Sq F value Pr(>F)
# group      1  0.018 0.01757   0.429  0.514
# Residuals 93  3.808 0.04094               
# 
# Error: sub:cond
# Df Sum Sq  Mean Sq F value Pr(>F)
# cond        1 0.0087 0.008720   2.099  0.151
# cond:group  1 0.0014 0.001369   0.330  0.567
# Residuals  93 0.3863 0.004154

# Put-SMA
# Error: sub
# Df Sum Sq Mean Sq F value Pr(>F)
# group      1  0.017 0.01710   0.435  0.511
# Residuals 93  3.654 0.03929               
# 
# Error: sub:cond
# Df Sum Sq Mean Sq F value   Pr(>F)    
# cond        1 0.1280  0.1280  11.961 0.000821 ***
#   cond:group  1 0.0099  0.0099   0.925 0.338531    
# Residuals  93 0.9951  0.0107

# IPL-SMA
# Error: sub
# Df Sum Sq Mean Sq F value Pr(>F)
# group      1  0.017 0.01733   0.297  0.587
# Residuals 93  5.425 0.05833               
# 
# Error: sub:cond
# Df Sum Sq  Mean Sq F value Pr(>F)
# cond        1 0.0095 0.009466   0.717  0.399
# cond:group  1 0.0001 0.000149   0.011  0.916
# Residuals  93 1.2281 0.013206 

#### SINGLE TASK - RH
# 1 Pre   IPL-Put 0.213    94 0.0169
# 2 Pre   Put-SMA 0.398    94 0.0148
# 3 Pre   IPL-SMA 0.316    94 0.0193
# 4 Post  IPL-Put 0.189    94 0.0171
# 5 Post  Put-SMA 0.348    94 0.0178
# 6 Post  IPL-SMA 0.277    94 0.0184
# IPL - Put
# Error: sub
# Df Sum Sq Mean Sq F value Pr(>F)
# group      1  0.003 0.00350   0.073  0.788
# Residuals 92  4.424 0.04809               
# 
# Error: sub:cond
# Df Sum Sq  Mean Sq F value Pr(>F)  
# cond        1 0.0278 0.027785   4.122 0.0452 *
#   cond:group  1 0.0114 0.011369   1.687 0.1973  
# Residuals  92 0.6201 0.006741 

# Put - SMA
# Error: sub
# Df Sum Sq Mean Sq F value Pr(>F)
# group      1  0.001 0.00147   0.037  0.847
# Residuals 92  3.602 0.03915               
# 
# Error: sub:cond
# Df Sum Sq Mean Sq F value  Pr(>F)   
# cond        1 0.1204 0.12038  10.436 0.00171 **
#   cond:group  1 0.0065 0.00654   0.567 0.45329   
# Residuals  92 1.0612 0.01154         

# Error: sub
# Df Sum Sq Mean Sq F value Pr(>F)
# group      1  0.013 0.01276   0.221  0.639
# Residuals 92  5.310 0.05772               
# 
# Error: sub:cond
# Df Sum Sq Mean Sq F value  Pr(>F)   
# cond        1 0.0707 0.07070   7.340 0.00804 **
#   cond:group  1 0.0018 0.00177   0.183 0.66959   
# Residuals  92 0.8862 0.00963 


# ---
# LH Multitask
# Error: sub
# Df Sum Sq Mean Sq F value Pr(>F)
# group      1  0.006 0.00592   0.134  0.715
# Residuals 93  4.098 0.04407               
# 
# Error: sub:cond
# Df Sum Sq  Mean Sq F value Pr(>F)
# cond        1 0.0076 0.007581   1.234  0.269
# cond:group  1 0.0008 0.000755   0.123  0.727
# Residuals  93 0.5713 0.006143  

# Error: sub
# Df Sum Sq Mean Sq F value Pr(>F)
# group      1  0.037 0.03660   0.835  0.363
# Residuals 93  4.076 0.04383               
# 
# Error: sub:cond
# Df Sum Sq  Mean Sq F value Pr(>F)
# cond        1 0.0113 0.011332   1.242  0.268
# cond:group  1 0.0008 0.000834   0.091  0.763
# Residuals  93 0.8483 0.009122 

# Error: sub
# Df Sum Sq Mean Sq F value Pr(>F)
# group      1  0.022 0.02180   0.306  0.581
# Residuals 93  6.619 0.07118               
# 
# Error: sub:cond
# Df Sum Sq  Mean Sq F value Pr(>F)
# cond        1 0.0077 0.007722   0.600  0.441
# cond:group  1 0.0017 0.001724   0.134  0.715
# Residuals  93 1.1969 0.012870

## RH MULT
# Error: sub
# Df Sum Sq Mean Sq F value Pr(>F)
# group      1  0.020 0.02012   0.357  0.552
# Residuals 90  5.075 0.05639               
# 
# Error: sub:cond
# Df Sum Sq  Mean Sq F value Pr(>F)
# cond        1 0.0074 0.007431   1.347  0.249
# cond:group  1 0.0003 0.000293   0.053  0.818
# Residuals  90 0.4964 0.005516 

# Error: sub
# Df Sum Sq Mean Sq F value Pr(>F)
# group      1  0.000 0.00009   0.002  0.963
# Residuals 90  3.772 0.04191               
# 
# Error: sub:cond
# Df Sum Sq  Mean Sq F value Pr(>F)
# cond        1 0.0010 0.001038   0.119  0.731
# cond:group  1 0.0013 0.001327   0.152  0.698
# Residuals  90 0.7858 0.008731

# Error: sub
# Df Sum Sq Mean Sq F value Pr(>F)
# group      1  0.012 0.01207   0.172   0.68
# Residuals 90  6.331 0.07035               
# 
# Error: sub:cond
# Df Sum Sq  Mean Sq F value Pr(>F)
# cond        1 0.0006 0.000592    0.06  0.807
# cond:group  1 0.0015 0.001472    0.15  0.700
# Residuals  90 0.8843 0.009825 




                  