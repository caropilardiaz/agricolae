setwd("d:/statistics/agricolae/R")
#setwd("f:/statistics/agricolae/R")
library(agricolae)
data(CIC)
data(ComasOxapampa)
data(Glycoalkaloids)
data(LxT)
data(carolina1)
data(carolina2)
data(carolina3)
data(clay)
data(corn)
data(cotton)
data(disease)
data(genxenv)
data(grass)
data(growth)
data(haynes)
data(homog1)
data(huasahuasi)
data(ltrv)
data(markers)
data(melon)
data(natives)
data(paracsho)
data(pamCIP)
data(plots)
data(potato)
data(ralstonia)
data(rice)
data(RioChillon)
data(sinRepAmmi)
data(soil)
data(sweetpotato)
data(trees)
data(wilt)

source("AMMI.contour.R")
source("AMMI.R")
source("audpc.R")
source("bar.err.R")
source("bar.group.R")
source("BIB.test.R")
source("carolina.R")
source("consensus.R")
source("correl.R")
source("correlation.R")
source("cv.model.R")
source("cv.similarity.R")
source("decimals.R")
source("delete.na.R")
source("design.ab.R")
source("design.alpha.R")
source("design.bib.r")
source("design.crd.R")
source("design.graeco.R")
source("design.lsd.R")
source("design.rcbd.R")
source("durbin.test.R")
source("fact.nk.R")
source("friedman.test.R")
source("graph.freq.R")
source("grid3p.R")
source("gxyz.R")
source("hcut.R")
source("hgroups.R")
source("HSD.test.R")
source("index.bio.R")
source("index.smith.R")
source("intervals.freq.R")
source("join.freq.R")
source("kendall.R")
source("kruskal.test.R")
source("kurtosis.R")
source("last.c.R")
source("lattice.simple.R")
source("lineXtester.R")
source("LSD.test.R")
source("mxyz.R")
source("nonadditivity.R")
source("normal.freq.R")
source("ojiva.freq.R")
source("order.group.R")
source("order.stat.R")
source("path.analysis.R")
source("polygon.freq.R")
source("random.ab.R")
source("reg.homog.R")
source("resampling.cv.R")
source("resampling.model.R")
source("similarity.R")
source("simulation.model.R")
source("skewness.R")
source("stability.nonpar.R")
source("stability.par.R")
source("stat.freq.R")
source("strip.plot.R")
source("sturges.freq.R")
source("table.freq.R")
source("tapply.stat.R")
source("VanderWarden.r")
source("vark.R")
source("waller.R")
source("waller.test.R")
source("wxyz.R")

package.skeleton(name="agricolae",list=ls(), path="d:/", force=T)
