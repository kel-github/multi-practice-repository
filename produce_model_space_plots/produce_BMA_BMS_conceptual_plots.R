# written by K. Garner, 2018, R 3.4.4
# generate pdfs using the beta distribution and ggplot 2 for 
# family model selection and bayesian model averaging concept plots
##############################################################################################
# Load libraries
library(ggplot2)
library(wesanderson)
##############################################################################################
# Family model selection
probs = seq(0, 1, .01)
fa <- rbeta(length(probs), 1, 9)
fb <- rbeta(length(probs), 3, 6)
fc <- rbeta(length(probs), 8, 2)


df <- data.frame(cond = factor(rep(c(1,2,3), each = 101)),
                 dens = c(fa, fb, fc),
                 x    = rep(probs, times = 3))

pdf("FAM_INF.pdf", width=2, height=2)
p <- ggplot(df, aes(dens, fill=cond, color=cond)) +
     geom_density(alpha=0.4) +
     scale_color_manual(values=wes_palette("Chevalier1")) +
     scale_fill_manual(values=wes_palette("Chevalier1")) +
     theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
                        text=element_text(size=10),
                        axis.text.x = element_text(size=10),
                        axis.text.y = element_blank(),
                        legend.position = "none") + ylab("p(f|m)") + xlab("")
p
dev.off()

##############################################################################################
# BMA
probs = seq(0, 1, .01)
da <- rbeta(length(probs), 80, 20) 
db <- rbeta(length(probs), 40, 10) 
dc <- rbeta(length(probs), 20, 0) 

df <- data.frame(cond = factor(rep(c(1,2,3), each = 101)),
                 dens = c(da, db, dc),
                 x    = rep(probs, times = 3))

pdf("BMA.pdf", width=2, height=2)
bmp("BMA.bmp", width=200, height=200)
p = ggplot(df, aes(dens)) +
    geom_density(aes(fill=cond), position="stack", alpha = 0.4) +
    scale_color_manual(values=wes_palette("Chevalier1")) +
    scale_fill_manual(values=wes_palette("Chevalier1")) + 
    labs(title=expression(theta),
       x = "",
       y=expression("P("~theta~"|Y, m)")) +
    xlim(c(0,1)) + 
    theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
                     text=element_text(size=10),
                     axis.text.x = element_text(size=10),
                     axis.text.y = element_blank(),
                     axis.title.y = element_text(expression(theta)),
                     legend.position = "none",
                     plot.title = element_text(hjust=0.5)) 
p
#ggsave("BMA.svg", plot=p, device="pdf", width=2, height=2, units="in")
dev.off()