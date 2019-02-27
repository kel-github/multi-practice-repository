##### written by K. Garner, 2018
#### plot correlations between DCM parameters and behaviour
#### What this code does:
#### for the correlation between multitasking change and b LPut -> SMFC parameter 
#### 1. load packages
#### 2. load multitasking behavioural data 
#### 3. load b parameters and join with behavioural
#### 4. plot correlation, both groups, with regression line
#### for the correlation between single task change and b LPut -> SMFC parameter 
#### 5. compute single task prct change
#### 6. load b parameters and join with behavioural
#### 7. plot correlation, both groups, with regression line

rm(list=ls())
#########################################################################################
# 1. load packages
library(dplyr)
library(tidyr)
library(ggplot2)
#########################################################################################
# 2. load multitasking behaviour data
get.behav.data <- function(fname){
  # this function assumes that the behavioural data is stored in the below folder
  behav.dat        <- read.csv(fname)
  behav.dat$sub    <- as.factor(behav.dat$sub)
  behav.dat$Group  <- as.factor(behav.dat$Group)
  levels(behav.dat$Group) <- c("train","control")
  
  behav.dat = behav.dat[,c(1:10, 29, 32, 27, 28, 33, 34)]
  behav.dat
}

behav.dat = get.behav.data('../s1s2_behavioural_data/final_data_cleaned_250ms_to_3_sdevs_1331_recode.csv')

#########################################################################################
# 3. get parameter data and link to behavioural in a dataframe called data
get.b.data <- function(fname){
  
  dat <- read.csv(fname, header = TRUE)
  dat$sub = as.factor(dat$sub)
  dat$grp = as.factor(dat$grp)
  levels(dat$grp) = c("train", "control")
  # assign parameter name
  dat$con = rep(c("lipl_to_lput", "lput_to_lipl", "lput_to_smfc", "smfc_to_lipl"), times = length(levels(dat$sub)))
  dat$con = as.factor(dat$con)
  dat
}
fname = "../s1s2_singOut_practice_dcm_analysis_outdata/behav_correlations/sub_b_params.csv"
params = get.b.data(fname)
cons.of.int = c("lput_to_smfc")
params = params[params$con %in% cons.of.int, ]
params$con = droplevels(params$con)

data = inner_join(params, behav.dat, by=c("sub"))

data = data %>% mutate( pre_cost  = (Pre_VM - Pre_VS) + (Pre_AM - Pre_AS) ,
                        post_cost = (Post_VM - Post_VS) + (Post_AM - Post_AS),
                        mt_prct_down = ((post_cost/pre_cost)*100) )

#########################################################################################
# 4. plot correlation, coloured by group, 
train.col = "#e66101"
cont.col  = "#5e3c99"
f_size    = 18

annote_label_a <- "r[s] == .26 p == .01"
mt.plot = ggplot(data, aes(x=b, y=mt_prct_down, color=Group))+
  geom_point() + scale_color_manual(values=c(train.col, cont.col)) +
  geom_smooth(aes(x=b, y=mt_prct_down), data, method=lm, se=TRUE, 
              inherit.aes=FALSE, color="darkgrey") +
              ylab(expression(paste(Delta, "M"["cost"]))) + xlab("Put -> SMA coupling") + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        text=element_text(size=f_size),
        axis.text.x = element_text(size=f_size),
        axis.text.y = element_text(size=f_size),
        legend.position = "none") +
        annotate("text", x = 0, y = 160, label=paste("list(italic(r[s]) ==", .26, ", p==.01)"), parse=TRUE, size = 6) 
        
  # add r values
  # add legend
ggplot2::ggsave('mt_reduct_by_SMA_coupling.png', mt.plot, width = 10, height = 10, units = "cm")




#########################################################################################
# 5. compute single task prct change
st.data = behav.dat %>% mutate( pre_sing_total = Pre_VS + Pre_AS,
                        post_sing_total = Post_VS + Post_AS,
                        prct_down = ((post_sing_total/pre_sing_total)*100) )

#########################################################################################
# 6. get b params
fname = "../s1s2_mtOut_practice_dcm_analysis_outdata/behav_correlations/sub_b_params.csv"
params = get.b.data(fname)
cons.of.int = c("lput_to_smfc")
params = params[params$con %in% cons.of.int, ]
params$con = droplevels(params$con)

st.data = inner_join(params, st.data, by=c("sub"))

st.plot = ggplot(st.data, aes(x=b, y=prct_down, color=Group))+
  geom_point() + scale_color_manual(values=c(train.col, cont.col)) +
  geom_smooth(aes(x=b, y=prct_down), st.data, method=lm, se=TRUE, 
              inherit.aes=FALSE, color="darkgrey") +
  ylab(expression(paste(Delta, "RT"["s"]))) + xlab("Put -> SMA coupling") + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        text=element_text(size=f_size),
        axis.text.x = element_text(size=f_size),
        axis.text.y = element_text(size=f_size),
        legend.position = "none")  +
  annotate("text", x = 0, y = 120, label=paste("list(italic(r[s]) ==", .25, ", p==.015)"), parse=TRUE, size = 6) 
ggplot2::ggsave('st_reduct_by_SMA_coupling.png', st.plot, width = 10, height = 10, units = "cm")

