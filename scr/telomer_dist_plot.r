# Wed Aug  6 15:55:25 2025 

# Title:
# Author: Nicolò T.
# Status: Draft

# Comments:

# Options ----

rm(list = ls())
options(warn = 1)
options(stringsAsFactors = F)
gc()
gcinfo(FALSE)
options(scipen=999)

# Variables ----

# baseDir <- '/home/ntellini/proj/SGRP5/denovoassembliesont/sunp2/FKS1-assemblies/pipeline-v5/tlo'
# ind="yS1161"
# allDir <- list.dirs()
# allFiles <- list.files()

argsVal <- commandArgs(trailingOnly = T)
baseDir <- as.character(argsVal[1])
ind <- as.character(argsVal[2])
setwd(baseDir)

# Libraries ----

library(ggplot2)
library(data.table)

# body ----

files <- list.files(recursive = T, pattern = "clean")

all_tel <- data.frame()
for (i in files) {
  df_t <-  fread(i,data.table = F)
  if (nrow(df_t) >= 1) {
    df_t$file <- i
    chr_coord <- gsub(".clean.txt","",gsub("telo-","",sapply(strsplit(i,"/"),"[[",2)))
    df_t$chr_coord <- chr_coord
    all_tel <- rbind(all_tel,df_t)
  }
}  

all_tel$diff <- abs(all_tel[,2] - all_tel[,3]) + 1
all_tel[grep("-1-20000",all_tel$chr_coord),"tel_pos"] <- "L"
all_tel[grep("-1-20000",all_tel$chr_coord,invert = T),"tel_pos"] <- "R"
all_tel$chrs <- sapply(strsplit(all_tel$chr_coord,"-"),"[[",1)
print(paste0("before len filt: ",nrow(all_tel)))
all_tel[all_tel$tel_pos == "L","diff"] <- -1 * all_tel[all_tel$tel_pos == "L","diff"]
all_tel <- all_tel[all_tel$diff >= -1000 & all_tel$diff <= 1000,]
print(paste0("before len filt: ",nrow(all_tel)))
vline_dfR <- unique(all_tel[all_tel$tel_pos == "R", c("chrs", "tel_pos")])
vline_dfR$xintercept <- 345
vline_dfL <- unique(all_tel[all_tel$tel_pos == "L", c("chrs", "tel_pos")])
vline_dfL$xintercept <- -345
all_tel[,"colors"] <- "darkred"
v_left <- vector(mode = "character",length = 10)
v_rigth <- vector(mode = "character",length = 10)

v_left[7] <- -1000
v_left[8] <- "L"
v_left[9] <- "I"
v_left[10] <-  NA

v_rigth[7] <- 1000
v_rigth[8] <- "R"
v_rigth[9] <- "I"
v_rigth[10] <- NA

borders <- as.data.frame(rbind(v_rigth,v_left))
colnames(borders) <- colnames(all_tel)
borders[,7] <- as.numeric(borders[,7])

plot_tel_dist <- ggplot() + 
  geom_vline(data = vline_dfR, mapping = aes(xintercept = xintercept), color = "darkblue") +
  geom_vline(data = vline_dfL, mapping = aes(xintercept = xintercept), color = "darkblue") +
  geom_jitter(all_tel,mapping = aes(x=diff,chrs),width = 0,height = 0.2,alpha=0.5,color="darkgreen")+
  geom_boxplot(all_tel,mapping=aes(diff,chrs),alpha=0.00001) +
  geom_point(borders,mapping = aes(x=diff,chrs),color=NA)+
  facet_grid(chrs~tel_pos,scales = "free") +
  scale_x_continuous(n.breaks =10,labels = function(x) abs(x))+
  theme_bw() +
  theme(axis.text.y = element_blank(),axis.ticks.y = element_blank()) +
  ggtitle(label =  ind) +
  xlab("TEL len")


ggsave(plot_tel_dist, 
       filename =  paste0(baseDir,"/",ind,".tlodist.pdf"),
       device = "pdf",
       height = 12, width = 6, units = "in")

fn <- paste0(baseDir,"/Rplots.pdf")
if (file.exists(fn)) {
  file.remove(fn)
}