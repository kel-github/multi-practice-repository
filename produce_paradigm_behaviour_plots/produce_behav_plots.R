#### written by K. Garner, 2018
#### plot behavioural data from Garner & Dux, 2015, PNAS
#### What this code does:
#### 1. load packages
#### 2. load multitasking behavioural data 
#### 3. summarise single and multitask performance for each participant and session
#### 4. plot, by group and by session, the difference between single and multitask trials 
#### Plots shown mean with confidence intervals as a bold dot with error bars. The individual 
#### participant data is represented by the coloured lines
rm(list=ls())
#########################################################################################
# 1. load packages
library(wesanderson)
library(dplyr)
library(tidyr)
library(ggplot2)

# set working directory to current
setwd("~/Dropbox/QBI/mult-conn/multi-practice-repository/produce_paradigm_behaviour_plots")
#########################################################################################

#########################################################################################
# 2. load multitasking behavioural data
get.behav.data <- function(fname){
  # this function assumes that the behavioural data is stored in the below folder
  behav.dat        <- read.csv(fname)
  behav.dat$sub    <- as.factor(behav.dat$sub)
  behav.dat$Group  <- as.factor(behav.dat$Group)
  levels(behav.dat$Group) <- c("T","C")
  
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
sum.rt.dat$session = as.factor(sum.rt.dat$session)

sum.acc.dat = behav.dat %>% group_by(sub, Group) %>%
                            summarise(pre_ACC_sing = mean(Pre_Vis_Sing_Acc, Pre_Aud_Sing_Acc), 
                                      pre_ACC_mult = mean(Pre_Vis_Mixed_Acc, Pre_Aud_Mix_Correct),
                                      post_ACC_sing = mean(Post_Vis_Sing_Acc, Post_Aud_Sing_Acc),
                                      post_ACC_mult = mean(Post_Vis_Mixed_Acc, Post_Aud_Mix_Correct))
sum.acc.dat = gather(sum.acc.dat, condition, ACC, pre_ACC_sing:post_ACC_mult, factor_key = TRUE)
sum.acc.dat$session[sum.acc.dat$condition == "pre_ACC_sing"|sum.acc.dat$condition == "pre_ACC_mult"] = "Pre"
sum.acc.dat$session[sum.acc.dat$condition == "post_ACC_sing"|sum.acc.dat$condition == "post_ACC_mult"] = "Post"
sum.acc.dat$session = as.factor(sum.acc.dat$session)
#########################################################################################

#########################################################################################
# 4. plot, by group and by session, the difference between single and multitask trials 
plot_multi_performance <- function(data, dv, conds){

  # input = summary data frame
  # dv = Acc or RT?
  # conds = a list of the condition names (for renaming so the plot is easier/cleaner)
  # grp.dat = group level data summary
  # 1. rename the trial types
  data$trial[ data$condition == conds[[1]][1]] = "S"
  data$trial[ data$condition == conds[[1]][2]] = "M"
  data$trial[ data$condition == conds[[1]][3]] = "S"
  data$trial[ data$condition == conds[[1]][4]] = "M"
  data$trial <- factor(as.character(data$trial), c("S", "M"))
  data$session <- factor(data$session, levels(data$session)[c(2,1)])

 
  dodge <- position_dodge(width = 0.75)  
  train.col = wesanderson::wes_palette("Royal1")[2]
  cont.col = wesanderson::wes_palette("Royal1")[1]
  plot_out <- data %>%
    ggplot(aes_string("trial", dv, fill="Group")) +
    geom_violin(position=dodge) + geom_boxplot(width=.2, position=dodge) +
    facet_wrap(~session) +
    scale_fill_manual(values = c(train.col, cont.col)) +
    xlab("Condition") + ylab(eval(dv)) +
    theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                       panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
                       text=element_text(size=10),
                       axis.text.x = element_text(size=10),
                       axis.text.y = element_text(size=10))
  if (dv == "ACC") plot_out = plot_out + ylim(c(0,100))
  plot_out
}


rt.conds = list(levels(sum.rt.dat$condition))
pdf("SessGrp_RT.pdf", width=3.34, height=1.67)
plot_multi_performance(sum.rt.dat, "RT", rt.conds)
dev.off()


acc.conds = list(levels(sum.acc.dat$condition))
pdf("SessGrp_ACC.pdf", width=3.34, height=1.67)
plot_multi_performance(sum.acc.dat, "ACC", acc.conds)
dev.off()
