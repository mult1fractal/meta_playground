# in a r-docker
# docker run --rm -it -v $PWD:/input nanozoo/r_ggpubr:0.2.5--4b52011

install.packages("tidyverse")
#libs
library(ggpubr)
library(viridis)
library(reshape2)
library(ggplot2)
library(viridis)
library(tidyverse)


# inputs
setwd ("/input")
#dt <- read.csv(file = 'read_distribution.csv', sep= "\t")
temp = list.files(pattern="*.tsv")
myfiles = lapply(temp, read.delim)
dt <- myfiles

options(ggplot2.continuous.colour="viridis")


# Hexbin chart with default option
ggplot(dt, aes(x=x, y=y) ) +
  geom_hex() +
  theme_bw()
 
# Bin size control + color palette
ggplot(dt, aes(x=sequence_lenght, y=sequence_lenght) ) +
  geom_hex(bins = 70) +
  scale_fill_continuous(type = "viridis") +
  theme_bw()

