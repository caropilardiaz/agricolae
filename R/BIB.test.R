BIB.test <-
  function (block, trt, y, test = c("lsd","tukey","duncan","waller","snk"), alpha = 0.05, group = TRUE,console=FALSE)
  {
    test<-match.arg(test)
    block.unadj <- as.factor(block)
    trt.adj <- as.factor(trt)
    name.y <- paste(deparse(substitute(y)))
    name.t <- paste(deparse(substitute(trt)))
    modelo <- formula(paste(name.y,"~ block.unadj + trt.adj"))
    model <- lm(modelo)
    DFerror <- df.residual(model)
    MSerror <- deviance(model)/DFerror
    k <- unique(table(block.unadj))
    r <- unique(table(trt.adj))
    b <- nlevels(block.unadj)
    ntr <- nlevels(trt.adj)
    lambda <- r * (k - 1)/(ntr - 1)
    datos <- data.frame(block, trt, y)
    tabla <- by(datos[,3], datos[,1:2], function(x) mean(x,na.rm=TRUE))
    tabla <-as.data.frame(tabla[,])
    AA <- !is.na(tabla)
    BB <- tapply(y, block.unadj, function(x) sum(x, na.rm=TRUE))
    B <- BB %*% AA
    Y <- tapply(y, trt.adj, function(x) sum(x, na.rm=TRUE))
    mi <- tapply(y, trt.adj, function(x) min(x, na.rm=TRUE))
    ma <- tapply(y, trt.adj, function(x) max(x, na.rm=TRUE))
    sds <- tapply(y, trt.adj, function(x) sd(x, na.rm=TRUE))
    medians<-tapply.stat(y,trt.adj,stat="median")
    for(i in c(1,5,2:4)) {
      x <- tapply.stat(y,trt.adj,function(x)quantile(x)[i])
      medians<-cbind(medians,x[,2])
    }
    medians<-medians[,3:7]
    names(medians)<-c("Min","Max","Q25","Q50","Q75")
    Q <- Y - as.numeric(B)/k
    SStrt.adj <- sum(Q^2) * k/(lambda * ntr)
    MStrt.adj <- SStrt.adj/(ntr - 1)
    sdtdif <- sqrt(2 * k * MSerror/(lambda * ntr))
    Fvalue <- MStrt.adj/MSerror
    mean.adj <- mean(y,na.rm=TRUE) + Q * k/(lambda * ntr)
    StdError.adj <- sqrt(MSerror * (1 + k * r * (ntr - 1)/(lambda *
                                                             ntr))/(r * ntr))
    CV<-cv.model(model)
    Mean<-mean(y,na.rm=TRUE)
    if(console){
      cat("\nANALYSIS BIB: ", name.y, "\nClass level information\n")
      cat("\nBlock: ", unique(as.character(block)))
      cat("\nTrt  : ", unique(as.character(trt)))
      cat("\n\nNumber of observations: ", length(y), "\n\n")
      print(anova(model))
      cat("\ncoefficient of variation:", round(CV, 1),
          "%\n")
      cat(name.y, "Means:", Mean, "\n\n")
      cat(paste(name.t,",",sep="")," statistics\n\n")
    }
    nameTrt<-row.names(Y)
    std <- sds
    means <-data.frame( means=Y/r,mean.adj, SE=StdError.adj,r,std,medians)
    rownames(means)<-nameTrt
    names(means)[1]<-name.y
    if(console)print(means[,1:7])
    parameter <- k/(lambda * ntr)
    snk<-0
    if (test == "lsd") {
      Tprob <- qt(1 - alpha/2, DFerror)
      if(console){
        cat("\nLSD test")
        cat("\nStd.diff   :", sdtdif)
        cat("\nAlpha      :", alpha)
        cat("\nLSD        :", Tprob * sdtdif)}
    }
    if (test == "tukey") {
      Tprob <- qtukey(1 - alpha, ntr, DFerror)
      sdtdif<-sdtdif/sqrt(2)
      if(console){
        cat("\nTukey")
        cat("\nAlpha      :", alpha)
        cat("\nStd.err    :", sdtdif)
        cat("\nHSD        :", Tprob * sdtdif)}
      parameter <- parameter/2
    }
    if (test == "waller") {
      K <- 650 - 16000 * alpha + 1e+05 * alpha^2
      Tprob <- waller(K, ntr - 1, DFerror, Fvalue)
      if(console){
        cat("\nWaller-Duncan K-ratio \n")
        cat("This test minimizes the Bayes risk under additive \n")
        cat("loss and certain other assumptions.\n\n")
        cat("k Ratio    : ", K,"\n")
        cat("MSD        :", Tprob * sdtdif)}
    }
    if (test == "snk") {
      snk<-1
      sdtdif<-sdtdif/sqrt(2)
      Tprob <- qtukey(1-alpha,2:ntr, DFerror)
      SNK <- Tprob * sdtdif
      names(SNK)<-2:ntr
      if(console){cat("\nStudent Newman Keuls")
        cat("\nAlpha     :", alpha)
        cat("\nStd.err   :", sdtdif)
        cat("\nCritical Range\n")
        print(SNK)}
    }
    if (test == "duncan") {
      snk<-2
      sdtdif<-sdtdif/sqrt(2)
      Tprob <- qtukey((1-alpha)^(1:(ntr-1)),2:ntr, DFerror)
      duncan <- Tprob * sdtdif
      names(duncan)<-2:ntr
      if(console){
        cat("\nDuncan's new multiple range test")
        cat("\nAlpha     :", alpha)
        cat("\nStd.err   :", sdtdif)
        cat("\n\nCritical Range\n")
        print(duncan)}
    }
    E <- lambda * ntr/(r * k)
    if(console){
      cat("\nParameters BIB")
      cat("\nLambda     :", lambda)
      cat("\ntreatmeans :", ntr)
      cat("\nBlock size :", k)
      cat("\nBlocks     :", b)
      cat("\nReplication:", r, "\n")
      cat("\nEfficiency factor", E, "\n\n<<< Book >>>\n")}
    parameters<-data.frame(lambda= lambda,treatmeans=ntr,blockSize=k,blocks=b,r=r,alpha=alpha,test="BIB")
    statistics<-data.frame(Mean=Mean,Efficiency=E,CV=CV)
    rownames(parameters)<-" "
    rownames(statistics)<-" "
#
      Omeans<-order(mean.adj,decreasing = TRUE)
      Ordindex<-order(Omeans)
      comb <- utils::combn(ntr, 2)
      nn <- ncol(comb)
      dif <- rep(0, nn)
      sig <- rep(" ",nn)
      pvalue <- dif
      odif<-dif
      significant<-NULL
      for (k in 1:nn) {
        i <- comb[1, k]
        j <- comb[2, k]
        dif[k] <- mean.adj[i] - mean.adj[j]
        if (test == "lsd")
          pvalue[k] <- 2 * round(1 - pt(abs(dif[k])/sdtdif,
                                        DFerror), 4)
        if (test == "tukey")
          pvalue[k] <- round(1 - ptukey(abs(dif[k]) /sdtdif,
                                        ntr, DFerror), 4)
        if (test == "snk"){
          odif[k] <- abs(Ordindex[i]- Ordindex[j])+1
          pvalue[k] <- round(1 - ptukey(abs(dif[k]) /sdtdif,
                                        odif[k], DFerror), 4)
        }
        if (test == "duncan"){
          nx<-abs(i-j)+1
          odif[k] <- abs(Ordindex[i]- Ordindex[j])+1
          pvalue[k]<- round(1-(ptukey(abs(dif[k])/sdtdif,odif[k],DFerror))^(1/(odif[k]-1)),4)
        }
        sig[k]<-" "
        if (pvalue[k] <= 0.001) sig[k]<-"***"
        else  if (pvalue[k] <= 0.01) sig[k]<-"**"
        else  if (pvalue[k] <= 0.05) sig[k]<-"*"
        else  if (pvalue[k] <= 0.1) sig[k]<-"."
        if (test == "waller") {
        significant[k] = abs(dif[k]) > Tprob * sdtdif
        pvalue[k]=1
        if(significant[k]) pvalue[k]=0
        }
        }
      
      tr.i <- nameTrt[comb[1, ]]
      tr.j <- nameTrt[comb[2, ]]
      if(console)cat("\nComparison between treatments means\n")
      if (test == "waller") comparison<-data.frame("Difference" = dif, significant)
      else  comparison<-data.frame("Difference" = dif, pvalue=pvalue,"sig."=sig)
      rownames(comparison)<-paste(tr.i,tr.j,sep=" - ")
      if(console)print(comparison)
      groups <- NULL

#Treatment groups with probabilities 

    if (group) {
      # Matriz de probabilidades para segmentar grupos
      Q<-matrix(1,ncol=ntr,nrow=ntr)
      p<-pvalue
      k<-0
      for(i in 1:(ntr-1)){
        for(j in (i+1):ntr){
          k<-k+1
          Q[i,j]<-p[k]
          Q[j,i]<-p[k]
        }
      }
      groups <- orderPvalue(names(mean.adj), as.numeric(mean.adj),alpha, Q,console)
      names(groups)[1]<-name.y
      if(console) {
        cat("\nTreatments with the same letter are not significantly different.\n\n")
        print(groups) 
      } 
      comparison<-NULL
    }   
 output<-list(parameters=parameters,statistics=statistics,comparison=comparison,means=means,groups=groups)
 class(output)<-"group"
 invisible(output)
  }
