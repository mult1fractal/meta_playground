# in a r-docker
# docker run --rm -it -v $PWD:/input nanozoo/r_ggpubr:0.2.5--4b52011


#libs
library(ggpubr)
library(viridis)
library(reshape2)
library(ggplot2)
library(viridis)


# inputs
setwd ("/input")
dt <- read.csv(file = 'yield_over_time.csv')
dt2 <- read.csv(file = 'reads_over_time.csv')


options(ggplot2.continuous.colour="viridis")

# group: gruppiring von Region -alles zu einer kurve
# scale: distannce between plots
# size: 
# rel_min_height  tailing of lines until end of plot
# as Date: erkennt columns als date + scale_x_date --> sets x axis as date

# area

plota <- ggplot(dt, aes(x=time, y=estimated_bases, fill=sample)) + 
    geom_area(alpha=0.6 , size=.5, colour="white") + 
    scale_fill_viridis(discrete = T)
svg("yield_area.svg", width = 20, height = 3.5)
print(plota)
dev.off()


plotb <- ggplot(dt2, aes(x=time, y=reads, fill=sample)) + 
    geom_area(alpha=0.6 , size=.5, colour="white") +
    scale_fill_viridis(discrete = T)
svg("reads_area.svg", width = 20, height = 3.5)
print(plotb)
dev.off()
