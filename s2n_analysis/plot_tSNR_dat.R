## written by K. Garner, 2020
# this is to plot the standard deviations of the timecourses, from the regions
# of interest in the left and right hemipheres of Garner et al 2020 https://doi.org/10.1101/564450
rm(list=ls())

# load required packages and plotting resources
# --------------------------------------------------------------------------------
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(cowplot)
library(wesanderson)
library(BayesFactor)
source("R_rainclouds.R")

# define functions
# --------------------------------------------------------------------------------
make.plot <- function(data){
  ggplot(data, aes(x=region, y=std, fill = region, colour = region)) +
    geom_flat_violin(position = position_nudge(x = .25, y = 0), adjust =2, trim =
                       TRUE, alpha = 0.6) +
    geom_point(position = position_jitter(width = .15), size = .25) +
    geom_boxplot(aes(x = region, y = std), outlier.shape = NA,
                 alpha = 0.3, width = .1, colour = "BLACK") +
    scale_color_manual(values=wes_palette("IsleofDogs1")) +
    scale_fill_manual(values=wes_palette("IsleofDogs1")) +
    ylab('std') + xlab('ROI') + theme_cowplot() + 
    facet_wrap(~hemisphere) +
    guides(fill = FALSE, colour = FALSE) +
    theme(axis.text.x = element_text(face = "italic"))
}

z.test <- function(x, y, name){
  # compute z test, return statistic value and a 2 sided p-value
  z <- list(region = name, z = NA, p = NA)
  z$z <- (mean(x) - mean(y)) / sqrt( (sd(x)/sqrt(length(x)))  + (sd(y)/sqrt(length(y))) )
  z$p <- 2*pnorm(-abs(z$z))
  z
}

# define file variables
# --------------------------------------------------------------------------------
data.dir = 'processed-data'
LH.dat.csv = 's2_LH_SING.csv'
RH.dat.csv = 's2_RH_SING.csv'
roi_names = c("IPS", "Put", "SMA")
save.name = 'tc-std-s1s2-sing'

# data wrangle
# --------------------------------------------------------------------------------
LH = read.csv(paste('../', data.dir, '/', LH.dat.csv, sep=""), header=F)
names(LH) = roi_names
LH$hemisphere = "left"

RH = read.csv(paste('../', data.dir, '/', RH.dat.csv, sep=""), header=F)
names(RH) = roi_names
RH$hemisphere = "right"

LH = LH %>% pivot_longer(c('IPS', 'Put', 'SMA'), names_to = "region", values_to="std")
RH = RH %>% pivot_longer(c('IPS', 'Put', 'SMA'), names_to = "region", values_to="std")
dat = rbind(LH, RH)


# make plot and save
# --------------------------------------------------------------------------------
p <- make.plot( dat )
ggsave(paste(save.name, '.pdf', sep=''), plot = p, width=10, height=10, units="cm")
ggsave(paste(save.name, '.png', sep=''), plot = p, width=10, height=10, units="cm")

# conduct z-tests on each region and print output
# --------------------------------------------------------------------------------
reg = c("IPS", "Put", "SMA")
lapply(reg, function(x) with(dat, z.test(std[hemisphere == "left" & reg == x],
                                         std[hemisphere == "right" & reg == x],
                                         x)))

# s1 data = IPS: z = -0.2, p = .844, Put: z = 0.12, p = .91, SMA: z = .02, p = .98
# s2_SING = IPS: z = -0.3, p = .78, Put: z = .05, p = .96, SMA: z = -0.01, p = .99
# s2_MULT = IPS: z = -0.28, p = .77, Put: z = .05, p = .96, SMA: z = -0.04, p = .97 
