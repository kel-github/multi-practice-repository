#### written by K. Garner, 2018
#### plot behavioural data from Garner & Dux, 2015, PNAS
#### What this code does:
#### 1. load packages
#### 2. load multitasking behavioural data 
#### FOR RT
#### 3. summarise single and multitask performance for each participant for session 1
#### &  summarise by participant, the multitasking cost for session 1 and session 2 
#### 4. produce raincloud plot for both groups at session 1
#### 5. produce raincloud plots for both groups of mt cost at s1 and s2
#### FOR ACCURACY


#### pallettes 
#### http://colorbrewer2.org/?type=diverging&scheme=RdBu&n=6 # BAYESIAN
#### http://colorbrewer2.org/?type=diverging&scheme=PuOr&n=4 # train vs control


rm(list=ls())
#########################################################################################
# 1. load packages
library(wesanderson)
library(dplyr)
library(tidyr)
library(ggplot2)
library(cowplot)
library(readr)
# raincloud package dependencies
packages <- c("ggplot2", "dplyr", "lavaan", "plyr", "cowplot", "rmarkdown", 
              "readr", "caTools", "bitops")

if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
}

# set working directory to current
setwd("~/Dropbox/QBI/mult-conn/multi-practice-repository/produce_paradigm_behaviour_plots")
source("R_rainclouds.R")

#########################################################################################
# 2. load multitasking behavioural data
get.behav.data <- function(fname){
  # this function assumes that the behavioural data is stored in the below folder
  behav.dat        <- read.csv(fname)
  behav.dat$sub    <- as.factor(behav.dat$sub)
  behav.dat$Group  <- as.factor(behav.dat$Group)
  levels(behav.dat$Group) <- c("Practice","Control")
  
  #behav.dat = behav.dat[,c(1:2, 29, 32, 27, 28, 33, 34)]
  behav.dat
}

behav.dat = get.behav.data('../s1s2_behavioural_data/final_data_cleaned_250ms_to_3_sdevs_1331_recode.csv')
#########################################################################################

#########################################################################################
# 3. summarise single and multitask performance for each participant and session
sum.rt.dat = behav.dat %>% group_by(sub, Group) %>%
  summarise(pre_RT_sing = mean(Pre_VS, Pre_AS), 
            pre_RT_mult = mean(Pre_VM, Pre_AM),
            post_RT_sing = mean(Post_VS, Post_AS),
            post_RT_mult = mean(Post_VM, Post_AM))
sum.rt.dat = gather(sum.rt.dat, condition, RT, pre_RT_sing:post_RT_mult, factor_key = TRUE)
sum.rt.dat$session[sum.rt.dat$condition == "pre_RT_sing"|sum.rt.dat$condition == "pre_RT_mult"] = "Pre"
sum.rt.dat$session[sum.rt.dat$condition == "post_RT_sing"|sum.rt.dat$condition == "post_RT_mult"] = "Post"
sum.rt.dat$session = factor(sum.rt.dat$session, levels=c("Pre", "Post"))
sum.rt.dat$task[sum.rt.dat$condition == "pre_RT_sing"] = "S"
sum.rt.dat$task[sum.rt.dat$condition == "pre_RT_mult"] = "M"
sum.rt.dat$task[sum.rt.dat$condition == "post_RT_sing"] = "S"
sum.rt.dat$task[sum.rt.dat$condition == "post_RT_mult"] = "M"
sum.rt.dat$task = factor(sum.rt.dat$task, levels=c("S", "M"))

mult.cost.dat = sum.rt.dat %>% group_by(sub, Group, session) %>%
  summarise(cost = RT[task=="M"] - RT[task=="S"])
#########################################################################################

#########################################################################################
# 4. produce raincloud plot for both groups at session 1
pre.plot <- ggplot(sum.rt.dat, aes(x = task, y = RT, fill = task)) +
  geom_flat_violin(aes(fill = task),position = position_nudge(x = .1, y = 0), 
                   adjust = 1.5, trim = FALSE, alpha = .5, colour = NA) +
  geom_point(aes(x = as.numeric(task)-.15, y = RT, colour = task),
             position = position_jitter(width = .075), size = .1, shape = 20,
             alpha = .5) +
  geom_boxplot(aes(x = task, y = RT, fill = task), outlier.shape = NA, 
               alpha = .5, width = .1, colour = "black") +
  scale_fill_manual(values=c(wesanderson::wes_palette("Chevalier1")[c(1:2)])) +
  scale_color_manual(values=c(wesanderson::wes_palette("Chevalier1")[c(1:2)])) + facet_wrap(~Group)                                                                                                    

ggplot2::ggsave('pre_training_behav.png', pre.plot, width = 10, height = 6, units = "cm")
#########################################################################################

#########################################################################################
# 5. produce raincloud plots for both groups of mt cost at s1 and s2

train.col = "#e66101"
cont.col = "#5e3c99"
f_size = 18
cost.plot <- ggplot(mult.cost.dat, aes(x = session, y = cost, fill = Group)) +
            geom_flat_violin(aes(fill = Group), position = position_nudge(x = .1, y = 0), 
                             adjust = 1.5, trim = FALSE, alpha = .5, colour = NA) +
            geom_point(aes(x = as.numeric(session)-.15, y = cost, colour = Group),
                       position = position_jitter(width = .075), size = .1, shape = 20,
                       alpha = .5) +
            geom_boxplot(aes(x = session, y = cost, fill = Group), outlier.shape = NA, 
                       alpha = .5, width = .1, colour = "black") +
            scale_fill_manual(values=c(train.col, cont.col)) +
            scale_color_manual(values=c(train.col, cont.col)) + facet_wrap(~Group)  +
            ylab("Multitasking Cost") + xlab("Session") + 
            theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
                  text=element_text(size=f_size),
                  axis.text.x = element_text(size=f_size),
                  axis.text.y = element_text(size=f_size),
                  legend.position = "none")

ggplot2::ggsave('mt_cost_by_group_by_sess_poster.png', cost.plot, width = 14, height = 10, units = "cm")


###################################################################################
# accuracy
sum.acc.dat = behav.dat %>% group_by(sub, Group) %>%
  summarise(pre_ACC_sing = mean(Pre_Vis_Sing_Acc, Pre_Aud_Sing_Acc), 
            pre_ACC_mult =  mean(Pre_Vis_Mixed_Acc, Pre_Aud_Mix_Correct),
            post_ACC_sing = mean(Post_Vis_Sing_Acc, Post_Aud_Sing_Acc),
            post_ACC_mult = mean(Post_Vis_Mixed_Acc, Post_Aud_Mix_Correct))
sum.acc.dat = gather(sum.acc.dat, condition, ACC, pre_ACC_sing:post_ACC_mult, factor_key = TRUE)
sum.acc.dat$session[sum.acc.dat$condition == "pre_ACC_sing"|sum.acc.dat$condition == "pre_ACC_mult"] = "Pre"
sum.acc.dat$session[sum.acc.dat$condition == "post_ACC_sing"|sum.acc.dat$condition == "post_ACC_mult"] = "Post"
sum.acc.dat$session = factor(sum.acc.dat$session, levels=c("Pre", "Post"))
sum.acc.dat$task[sum.acc.dat$condition == "pre_ACC_sing"] = "S"
sum.acc.dat$task[sum.acc.dat$condition == "pre_ACC_mult"] = "M"
sum.acc.dat$task[sum.acc.dat$condition == "post_ACC_sing"] = "S"
sum.acc.dat$task[sum.acc.dat$condition == "post_ACC_mult"] = "M"
sum.acc.dat$task = factor(sum.acc.dat$task, levels=c("S", "M"))

mult.cost.acc = sum.acc.dat %>% group_by(sub, Group, session) %>%
  summarise(cost = ACC[task=="M"] - ACC[task=="S"])
#########################################################################################
# 4. produce raincloud plot for accuracy both groups at session 1
pre.plot.acc <- ggplot(sum.acc.dat, aes(x = task, y = ACC, fill = task)) +
  geom_flat_violin(aes(fill = task),position = position_nudge(x = .1, y = 0), 
                   adjust = 1.5, trim = FALSE, alpha = .5, colour = NA) +
  geom_point(aes(x = as.numeric(task)-.15, y = ACC, colour = task),
             position = position_jitter(width = .075), size = .1, shape = 20,
             alpha = .5) +
  geom_boxplot(aes(x = task, y = ACC, fill = task), outlier.shape = NA, 
               alpha = .5, width = .1, colour = "black") +
  scale_fill_manual(values=c(wesanderson::wes_palette("Chevalier1")[c(1:2)])) +
  scale_color_manual(values=c(wesanderson::wes_palette("Chevalier1")[c(1:2)])) + facet_wrap(~Group) +
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        text=element_text(size=8),
        axis.text.x = element_text(size=8),
        axis.text.y = element_text(size=8),
        legend.position = "none")

ggplot2::ggsave('pre_training_ACC_behav.png', pre.plot.acc, width = 7, height = 4.7, units = "cm")
#########################################################################################

cost.plot.acc <- ggplot(mult.cost.acc, aes(x = session, y = cost, fill = Group)) +
  geom_flat_violin(aes(fill = Group), position = position_nudge(x = .1, y = 0), 
                   adjust = 1.5, trim = FALSE, alpha = .5, colour = NA) +
  geom_point(aes(x = as.numeric(session)-.15, y = cost, colour = Group),
             position = position_jitter(width = .075), size = .1, shape = 20,
             alpha = .5) +
  geom_boxplot(aes(x = session, y = cost, fill = Group), outlier.shape = NA, 
               alpha = .5, width = .1, colour = "black") +
  scale_fill_manual(values=c(train.col, cont.col)) +
  scale_color_manual(values=c(train.col, cont.col)) + facet_wrap(~Group)  +
  ylab("Multitasking Cost") + xlab("Session") + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        text=element_text(size=8),
        axis.text.x = element_text(size=8),
        axis.text.y = element_text(size=8),
        legend.position = "none")

ggplot2::ggsave('mt_cost_acc_by_group_by_sess.png', cost.plot.acc, width = 7, height = 4.7, units = "cm")
