library(ggplot2)
library(gridExtra)

inpath="reports"
outdir="plots"
dir.create(outdir,showWarnings = FALSE)
file.names <- dir(inpath, pattern =".yn00.tab")
pdf(sprintf("%s/%s","plots","dN_dS_yn00_plots.pdf"),onefile=TRUE,width=12)

for(i in 1:length(file.names)){
  file <- read.table(sprintf("%s/%s",inpath,file.names[i]),
                     header=TRUE, sep="\t",
                     stringsAsFactors=FALSE)
  outbase = sub('\\.yn00\\.tab$', '',file.names[i])
  outpdf = sub('\\.tab$', '.rate_plot.pdf', file.names[i])
  dSsumQuartiles = summary(file$dS)
  dSquartile3 = dSsumQuartiles[4]
  dSPlot <- ggplot(data=file,aes(file$dS)) +
      geom_histogram(breaks=seq(0,dSquartile3,by = dSquartile3/100),fill="slategray") +
      labs(title=sprintf("dS for %s", outbase),xlab="dS") + theme_minimal()
  dNsumQuartiles = summary(file$dN)
  dNquartile3 = dNsumQuartiles[4]

  dNPlot <- ggplot(data=file,aes(file$dN)) +
      geom_histogram(breaks=seq(0,dNquartile3,by = dNquartile3/100),fill="maroon") +
      labs(title=sprintf("dN for %s", outbase),xlab="dN") + theme_bw()
  grid.arrange(dSPlot,dNPlot)
}
