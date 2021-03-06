### Joris Mulder 2019. Bayes factor for a one sample Student t test
### via adjusted FBFs (Mulder, 2014) using (m)lm-objects using a t.test object.

#' @method BF htest
#' @export
BF.htest <-
  function(x,
           hypothesis,
           prior = NULL,
           parameter = NULL,
           ...) {
    stop("The standard t.test() function from the 'stats' package does not return variance and sample size, which are required to run bain. Please use the function t_test() from the 'bain' package instead. It accepts the same arguments.")
  }


#' @method BF bain_htest
#' @export
BF.bain_htest <- function(x,
                      hypothesis = NULL,
                      prior = NULL,
                      parameter = NULL,
                      ...){

  numpop <- length(x$estimate)

  if(numpop==1){ #one sample t test
    # tvalue <- x$statistic
    # names(tvalue) <- NULL
    # n <- x$parameter + 1
    # names(n) <- NULL
    # mu0 <- x$null.value
    # names(mu0) <- NULL
    # xbar <- x$estimate
    # names(xbar) <- NULL

    #
    #
    tvalue <- x$statistic
    mu0 <- x$null.value
    xbar <- x$estimate
    df <- x$parameter
    n <- df + 1
    stderr <- (xbar - mu0) / tvalue #standard error
    sigmaML <- stderr*sqrt(n-1)
    relfit0 <- dt((xbar-mu0)/stderr,df=df,log=TRUE) - log(stderr)
    relfit1 <- log(1-pt((xbar-mu0)/stderr,df=df))
    relfit2 <- log(pt((xbar-mu0)/stderr,df=df))
    relcomp0 <- dt(0,df=1,log=T) - log(sigmaML)
    relcomp1 <- relcomp2 <- log(.5)

    #exploratory BFs
    hypotheses_exploratory <- c(paste0("mu=",as.character(mu0)),paste0("mu<",as.character(mu0)),paste0("mu>",as.character(mu0)))
    logBFtu <- c(relfit0-relcomp0,relfit1-relcomp1,relfit2-relcomp2)
    names(logBFtu) <- hypotheses_exploratory
    BFtu_exploratory <- matrix(exp(logBFtu),nrow=1)
    colnames(BFtu_exploratory) <- hypotheses_exploratory
    row.names(BFtu_exploratory) <- "BFtu"
    PHP_exploratory <- BFtu_exploratory/sum(BFtu_exploratory)
    colnames(PHP_exploratory) <- c(paste0("Pr(=",as.character(mu0),")"),paste0("Pr(<",as.character(mu0),")"),paste0("Pr(>",as.character(mu0),")"))
    row.names(PHP_exploratory) <- "mu"
#    BFmatrix <- matrix(rep(BFtu,3),ncol=3) / matrix(rep(BFtu,3),ncol=3,byrow=T)
#    logBFmatrix <- matrix(rep(logBFtu,3),ncol=3) - matrix(rep(logBFtu,3),ncol=3,byrow=T)
#    row.names(BFmatrix) <- row.names(logBFmatrix) <- hypotheses
#    colnames(BFmatrix) <- colnames(logBFmatrix) <- hypotheses
    relfit_exploratory <- matrix(c(exp(relfit0),rep(1,3),exp(relfit1),exp(relfit2)),ncol=2)
    relcomp_exploratory <- matrix(c(exp(relcomp0),rep(1,3),rep(.5,2)),ncol=2)
    row.names(relfit_exploratory) <- row.names(relcomp_exploratory) <- hypotheses_exploratory
    colnames(relfit_exploratory) <- c("f=","f>")
    colnames(relcomp_exploratory) <- c("c=","c>")

    if(!is.null(hypothesis)){ #perform confirmatory tests
      #execute via BF.lm
      sd1 <- sqrt(n) * (xbar - mu0) / tvalue
      y1 <- rnorm(n)
      y1 <- y1 - mean(y1)
      y1 <- sd1*y1/sd(y1) + xbar
      lm1 <- lm(y1 ~ 1)
      names(lm1$coefficients) <- "mu"
      BFlm1 <- BF(lm1,hypothesis)
      BFtu_confirmatory <- BFlm1$BFtu_confirmatory
      PHP_confirmatory <- BFlm1$PHP_confirmatory
      BFmatrix_confirmatory <- BFlm1$BFmatrix_confirmatory
      relative_fit <- BFlm1$relative_fit
      relative_complexity <- BFlm1$relative_complexity
    #
    #   if(x$alternative=="two.sided"){
    #     if(!grepl("Paired",x$method)){
    #       hypotheses <- c(paste0("mu=",as.character(mu0)),paste0("mu!=",as.character(mu0)))
    #     }else{
    #       hypotheses <- c("true difference is equal to 0","true difference is not equal to 0")
    #     }
    #     logBFtu <- c(relfit0-relcomp0,0)
    #     names(logBFtu) <- hypotheses
    #     BFtu <- exp(logBFtu)
    #     PHP <- BFtu/sum(BFtu)
    #     BFmatrix <- matrix(rep(BFtu,2),ncol=2) / matrix(rep(BFtu,2),ncol=2,byrow=T)
    #     logBFmatrix <- matrix(rep(logBFtu,2),ncol=2) - matrix(rep(logBFtu,2),ncol=2,byrow=T)
    #     row.names(BFmatrix) <- row.names(logBFmatrix) <- hypotheses
    #     colnames(BFmatrix) <- colnames(logBFmatrix) <- hypotheses
    #     relfit <- matrix(c(exp(relfit0),rep(1,3)),ncol=2)
    #     relcomp <- matrix(c(exp(relcomp0),rep(1,3)),ncol=2)
    #     row.names(relfit) <- row.names(relcomp) <- hypotheses
    #     colnames(relfit) <- c("f=","f>")
    #     colnames(relcomp) <- c("c=","c>")
    #
    #     # BF1 <- BF(lm1,hypothesis=paste0("mu_minus_mu0=",as.character(mu0)),
    #     #           prior=prior)
    #   } else if(x$alternative=="less"){
    #     if(!grepl("Paired",x$method)){
    #       hypotheses <- c(paste0("mu>=",as.character(mu0)),paste0("mu<",as.character(mu0)))
    #     }else{
    #       hypotheses <- c("true difference is greater than or equal to 0","true difference is less than 0")
    #     }
    #     logBFtu <- c(relfit2-relcomp2,relfit1-relcomp1)
    #     names(logBFtu) <- hypotheses
    #     BFtu <- exp(logBFtu)
    #     PHP <- BFtu/sum(BFtu)
    #     BFmatrix <- matrix(rep(BFtu,2),ncol=2) / matrix(rep(BFtu,2),ncol=2,byrow=T)
    #     logBFmatrix <- matrix(rep(logBFtu,2),ncol=2) - matrix(rep(logBFtu,2),ncol=2,byrow=T)
    #     row.names(BFmatrix) <- row.names(logBFmatrix) <- hypotheses
    #     colnames(BFmatrix) <- colnames(logBFmatrix) <- hypotheses
    #     relfit <- matrix(c(rep(1,2),exp(relfit2),exp(relfit1)),ncol=2)
    #     relcomp <- matrix(c(rep(1,2),rep(.5,2)),ncol=2)
    #     row.names(relfit) <- row.names(relcomp) <- hypotheses
    #     colnames(relfit) <- c("f=","f>")
    #     colnames(relcomp) <- c("c=","c>")
    #     # BF1 <- BF(lm1,hypothesis=paste0("mu_minus_mu0>",as.character(mu0)),
    #     #           prior=prior)
    #   } else if(x$alternative=="greater"){
    #     if(!grepl("Paired",x$method)){
    #       hypotheses <- c(paste0("mu<=",as.character(mu0)),paste0("mu>",as.character(mu0)))
    #     }else{
    #       hypotheses <- c("true difference is smaller than or equal to 0","true difference is greater than 0")
    #     }
    #     logBFtu <- c(relfit1-relcomp1,relfit2-relcomp2)
    #     names(logBFtu) <- hypotheses
    #     BFtu <- exp(logBFtu)
    #     PHP <- BFtu/sum(BFtu)
    #     BFmatrix <- matrix(rep(BFtu,2),ncol=2) / matrix(rep(BFtu,2),ncol=2,byrow=T)
    #     logBFmatrix <- matrix(rep(logBFtu,2),ncol=2) - matrix(rep(logBFtu,2),ncol=2,byrow=T)
    #     row.names(BFmatrix) <- row.names(logBFmatrix) <- hypotheses
    #     colnames(BFmatrix) <- colnames(logBFmatrix) <- hypotheses
    #     relfit <- matrix(c(rep(1,2),exp(relfit1),exp(relfit2)),ncol=2)
    #     relcomp <- matrix(c(rep(1,2),rep(.5,2)),ncol=2)
    #     row.names(relfit) <- row.names(relcomp) <- hypotheses
    #     colnames(relfit) <- c("f=","f>")
    #     colnames(relcomp) <- c("c=","c>")
    #     # BF1 <- BF(lm1,hypothesis=paste0("mu_minus_mu0<",as.character(mu0)),
    #     #           prior=prior)
    #   }
    # } else if(hypothesis=="exploratory"){
    #   if(!grepl("Paired",x$method)){
    #     hypotheses <- c(paste0("mu=",as.character(mu0)),paste0("mu<",as.character(mu0)),paste0("mu>",as.character(mu0)))
    #   }else{
    #     hypotheses <- c("difference=0","difference<0","difference>0")
    #   }
    #   logBFtu <- c(relfit0-relcomp0,relfit1-relcomp1,relfit2-relcomp2)
    #   names(logBFtu) <- hypotheses
    #   BFtu <- exp(logBFtu)
    #   PHP <- BFtu/sum(BFtu)
    #   BFmatrix <- matrix(rep(BFtu,3),ncol=3) / matrix(rep(BFtu,3),ncol=3,byrow=T)
    #   logBFmatrix <- matrix(rep(logBFtu,3),ncol=3) - matrix(rep(logBFtu,3),ncol=3,byrow=T)
    #   row.names(BFmatrix) <- row.names(logBFmatrix) <- hypotheses
    #   colnames(BFmatrix) <- colnames(logBFmatrix) <- hypotheses
    #   relfit <- matrix(c(exp(relfit0),rep(1,3),exp(relfit1),exp(relfit2)),ncol=2)
    #   relcomp <- matrix(c(exp(relcomp0),rep(1,3),rep(.5,2)),ncol=2)
    #   row.names(relfit) <- row.names(relcomp) <- hypotheses
    #   colnames(relfit) <- c("f=","f>")
    #   colnames(relcomp) <- c("c=","c>")
    #
    #   # BF1 <- BF(x=lm1,prior=prior)
    # } else {
    #   stop("hypothesis should be NULL or 'exploratory'.")
    # }
    }else{
      BFtu_confirmatory <- PHP_confirmatory <- BFmatrix_confirmatory <- relative_fit <-
        relative_complexity <- NULL
    }

  }else{ # two samples t test

    if(!grepl("Welch",x$method)){ # equal variances assumed
      # compute via a lm-analysis
      x1 <- c(rep(1,x$n[1]),rep(0,x$n[2]))
      y1 <- c(rep(0,x$n[1]),rep(1,x$n[2]))
      matx1y1 <- cbind(x1,y1)
      draw1 <- rnorm(x$n[1])
      out1 <- (draw1 - mean(draw1))/sd(draw1)*sqrt(x$v[1])+x$estimate[1]
      draw2 <- rnorm(x$n[2])
      out2 <- (draw2 - mean(draw2))/sd(draw2)*sqrt(x$v[2])+x$estimate[2]
      out <- c(out1,out2)
      # lm1 <- lm(out ~ -1 + x1 + y1)
      T1 <- matrix(c(1,1,-1,0),ncol=2)
      transx1y1 <- matx1y1%*%solve(T1)
      df1 <- data.frame(out=out,difference=transx1y1[,1],dummy=transx1y1[,2])
      lm1 <- lm(out ~ -1 + difference + dummy,df1)
      BFlm1 <- BF(lm1,hypothesis)

      BFtu_exploratory <- t(as.matrix(BFlm1$BFtu_exploratory[1,]))
      PHP_exploratory <- t(as.matrix(BFlm1$PHP_exploratory[1,]))
      row.names(BFtu_exploratory) <- row.names(PHP_exploratory) <- "difference"
#
#       #exploratory Bayes factor testing
#       hypotheses_exploratory <- c("difference=0","difference<0","difference>0")
#       logBFtu_exploratory <- c(relfit0-relcomp0,relfit1-relcomp1,relfit2-relcomp2)
#       names(logBFtu_exploratory) <- hypotheses_exploratory
#       BFtu_exploratory <- matrix(exp(logBFtu_exploratory),nrow=1)
#       PHP_exploratory <- BFtu_exploratory/sum(BFtu_exploratory)
#       colnames(PHP_exploratory) <- c("Pr(=0)","Pr(<0)","Pr(>0)")
#       row.names(PHP_exploratory) <- "difference"
# #      row.names(PHP_exploratory) <- "mean of x - mean of y"
#
#       # BFmatrix <- matrix(rep(BFtu,3),ncol=3) / matrix(rep(BFtu,3),ncol=3,byrow=T)
#       # logBFmatrix <- matrix(rep(logBFtu,3),ncol=3) - matrix(rep(logBFtu,3),ncol=3,byrow=T)
#       # row.names(BFmatrix) <- row.names(logBFmatrix) <- hypotheses
#       # colnames(BFmatrix) <- colnames(logBFmatrix) <- hypotheses
#       relfit <- matrix(c(exp(relfit0),rep(1,3),exp(relfit1),exp(relfit2)),ncol=2)
#       relcomp <- matrix(c(exp(relcomp0),rep(1,3),rep(.5,2)),ncol=2)
#       row.names(relfit) <- row.names(relcomp) <- hypotheses_exploratory
#       colnames(relfit) <- c("f=","f>")
#       colnames(relcomp) <- c("c=","c>")

      if(!is.null(hypothesis)){
        BFtu_confirmatory <- BFlm1$BFtu_confirmatory
        PHP_confirmatory <- BFlm1$PHP_confirmatory
        BFmatrix_confirmatory <- BFlm1$BFmatrix_confirmatory
        relative_fit <- BFlm1$relative_fit
        relative_complexity <- BFlm1$relative_complexity
      }else{
        BFtu_confirmatory <- PHP_confirmatory <- BFmatrix_confirmatory <- relative_fit <-
          relative_complexity <- NULL
      }
    }else{ #equal variances not assumed. BF.lm cannot be used

      meanN <- x$estimate
      scaleN <- (x$v)/(x$n)
      dfN <- x$n-1
      scale0 <- (x$v)*(x$n-1)/(x$n)
      df0 <- rep(1,2)
      drawsN <- rt(1e6,df=dfN[1])*sqrt(scaleN[1]) + meanN[1] - rt(1e5,df=dfN[2])*sqrt(scaleN[2]) - meanN[2]
      densN <- approxfun(density(drawsN))
      relfit0 <- log(densN(0))
      relfit1 <- log(mean(drawsN<0))
      relfit2 <- log(mean(drawsN>0))
      draws0 <- rt(1e6,df=df0[1])*sqrt(scale0[1])- rt(1e5,df=df0[2])*sqrt(scale0[2])
      relcomp0 <- log((sum((draws0<1)*(draws0> -1))/1e6)/2)
      relcomp1 <- relcomp2 <- log(.5)

      #exploratory Bayes factor test
      hypotheses_exploratory <- c("difference=0","difference<0","difference>0")
      logBFtu_exploratory <- c(relfit0-relcomp0,relfit1-relcomp1,relfit2-relcomp2)
      names(logBFtu_exploratory) <- hypotheses_exploratory
      BFtu_exploratory <- exp(logBFtu_exploratory)
      PHP_exploratory <- matrix(BFtu_exploratory/sum(BFtu_exploratory),nrow=1)
      colnames(PHP_exploratory) <- c("Pr(=0)","Pr(<0)","Pr(>0)")
      row.names(PHP_exploratory) <- "difference"
      # BFmatrix <- matrix(rep(BFtu,3),ncol=3) / matrix(rep(BFtu,3),ncol=3,byrow=T)
      # logBFmatrix <- matrix(rep(logBFtu,3),ncol=3) - matrix(rep(logBFtu,3),ncol=3,byrow=T)
      # row.names(BFmatrix) <- row.names(logBFmatrix) <- hypotheses
      # colnames(BFmatrix) <- colnames(logBFmatrix) <- hypotheses
      relfit <- matrix(c(exp(relfit0),rep(1,3),exp(relfit1),exp(relfit2)),ncol=2)
      relcomp <- matrix(c(exp(relcomp0),rep(1,3),rep(.5,2)),ncol=2)
      row.names(relfit) <- row.names(relcomp) <- hypotheses_exploratory
      colnames(relfit) <- c("f=","f>")
      colnames(relcomp) <- c("c=","c>")

      if(!is.null(hypothesis)){
        name1 <- "difference"
        parse_hyp <- parse_hypothesis(name1,hypothesis)
        RrList <- make_RrList2(parse_hyp)
        RrE <- RrList[[1]]
        RrO <- RrList[[2]]
        if(ncol(do.call(rbind,RrE))>2 || ncol(do.call(rbind,RrO))>2){
          stop("hypothesis should be formulated on the only parameter 'difference'.")
        }
        relfit <- t(matrix(unlist(lapply(1:length(RrE),function(h){
          if(!is.null(RrE[[h]]) & is.null(RrO[[h]])){ #only an equality constraint
            nullvalue <- RrE[[h]][1,2]/RrE[[h]][1,1]
            relfit_h <- c(log(densN(nullvalue)),0)
          }else if(is.null(RrE[[h]]) & !is.null(RrO[[h]])){
            relfit_h <- log(c(1,mean(apply(as.matrix(RrO[[h]][,1])%*%t(drawsN) - as.matrix(RrO[[h]][,2])%*%t(rep(1,1e6)) > 0,2,prod)==1)))
          }else stop("hypothesis should either contain one equality constraint or inequality constraints on 'difference'.")
          return(relfit_h)
        })),nrow=2))
        relcomp <- t(matrix(unlist(lapply(1:length(RrE),function(h){
          if(!is.null(RrE[[h]]) & is.null(RrO[[h]])){ #only an equality constraint
            nullvalue <- RrE[[h]][1,2]/RrE[[h]][1,1]
            relcomp_h <- log(c((sum((draws0<1+nullvalue)*(draws0> -1+nullvalue))/1e6)/2,1))
          }else if(is.null(RrE[[h]]) & !is.null(RrO[[h]])){ #order constraint(s)
            relcomp_h <- log(c(1,mean(apply(as.matrix(RrO[[h]][,1])%*%t(draws0) - as.matrix(RrO[[h]][,2])%*%t(rep(1,1e6)) > 0,2,prod)==1)))
          }else stop("hypothesis should either contain one equality constraint or inequality constraints on 'difference'.")
          return(relcomp_h)
        })),nrow=2))
        row.names(relfit) <- row.names(relcomp) <- parse_hyp$original_hypothesis
        colnames(relfit) <- c("f=","f>")
        colnames(relcomp) <- c("c=","c>")
        #add complement to analysis
        welk <- (relcomp==0)[,2]==F
        if(sum((relcomp==0)[,2])>0){ #then there are order constraints hypotheses
          relcomp_c <- 1-sum(exp(relcomp[welk,2]))
          if(relcomp_c!=0){ # then add complement
            relcomp <- rbind(relcomp,c(0,log(relcomp_c)))
            relfit_c <- 1-sum(exp(relfit[welk,2]))
            relfit <- rbind(relfit,c(0,log(relfit_c)))
            row.names(relfit) <- row.names(relcomp) <- c(parse_hyp$original_hypothesis,"complement")
          }
        }else{ #no order constraints
          relcomp <- rbind(relcomp,c(0,0))
          relfit <- rbind(relfit,c(0,0))
          row.names(relcomp) <- row.names(relfit) <- c(parse_hyp$original_hypothesis,"complement")
        }
        #compute Bayes factors and posterior probabilities for confirmatory test
        if(!(priorprob == "default" || (length(priorprob)==nrow(relfit) && min(priorprob)>0) )){
          stop("'probprob' must be a vector of positive values or set to 'default'.")
        }
        if(priorprob=="default"){
          priorprobs <- rep(1/length(BFtu_confirmatory),length(BFtu_confirmatory))
        }else{
          priorprobs <- priorprobs/sum(priorprobs)
        }
        BFtu_confirmatory <- c(apply(exp(relfit) / exp(relcomp), 1, prod))
        PHP_confirmatory <- BFtu_confirmatory*priorprobs / sum(BFtu_confirmatory*priorprobs)
        BFmatrix_confirmatory <- matrix(rep(BFtu_confirmatory,length(BFtu_confirmatory)),ncol=length(BFtu_confirmatory))/
          t(matrix(rep(BFtu_confirmatory,length(BFtu_confirmatory)),ncol=length(BFtu_confirmatory)))
        row.names(BFmatrix_confirmatory) <- colnames(BFmatrix_confirmatory) <- names(BFtu_confirmatory)
        relative_fit <- relfit
        relative_complexity <- relcomp
#
#         if(x$alternative=="two.sided"){
#           hypotheses <- c("true difference is equal to 0","true difference is not equal to 0")
#           logBFtu <- c(relfit0-relcomp0,0)
#           names(logBFtu) <- hypotheses
#           BFtu <- exp(logBFtu)
#           PHP <- BFtu/sum(BFtu)
#           BFmatrix <- matrix(rep(BFtu,2),ncol=2) / matrix(rep(BFtu,2),ncol=2,byrow=T)
#           logBFmatrix <- matrix(rep(logBFtu,2),ncol=2) - matrix(rep(logBFtu,2),ncol=2,byrow=T)
#           row.names(BFmatrix) <- row.names(logBFmatrix) <- hypotheses
#           colnames(BFmatrix) <- colnames(logBFmatrix) <- hypotheses
#           relfit <- matrix(c(exp(relfit0),rep(1,3)),ncol=2)
#           relcomp <- matrix(c(exp(relcomp0),rep(1,3)),ncol=2)
#           row.names(relfit) <- row.names(relcomp) <- hypotheses
#           colnames(relfit) <- c("f=","f>")
#           colnames(relcomp) <- c("c=","c>")
#
#         }else if(x$alternative=="less"){
#           hypotheses <- c("true difference is greater than or equal to 0","true difference is less than 0")
#           logBFtu <- c(relfit2-relcomp2,relfit1-relcomp1)
#           names(logBFtu) <- hypotheses
#           BFtu <- exp(logBFtu)
#           PHP <- BFtu/sum(BFtu)
#           BFmatrix <- matrix(rep(BFtu,2),ncol=2) / matrix(rep(BFtu,2),ncol=2,byrow=T)
#           logBFmatrix <- matrix(rep(logBFtu,2),ncol=2) - matrix(rep(logBFtu,2),ncol=2,byrow=T)
#           row.names(BFmatrix) <- row.names(logBFmatrix) <- hypotheses
#           colnames(BFmatrix) <- colnames(logBFmatrix) <- hypotheses
#           relfit <- matrix(c(rep(1,2),exp(relfit2),exp(relfit1)),ncol=2)
#           relcomp <- matrix(c(rep(1,2),rep(.5,2)),ncol=2)
#           row.names(relfit) <- row.names(relcomp) <- hypotheses
#           colnames(relfit) <- c("f=","f>")
#           colnames(relcomp) <- c("c=","c>")
#           # BF1 <- BF(lm1,hypothesis=paste0("mu_minus_mu0>",as.character(mu0)),
#           #           prior=prior)
#         } else if(x$alternative=="greater"){
#           hypotheses <- c("true difference is less than or equal to 0","true difference is greater than 0")
#           logBFtu <- c(relfit1-relcomp1,relfit2-relcomp2)
#           names(logBFtu) <- hypotheses
#           BFtu <- exp(logBFtu)
#           PHP <- BFtu/sum(BFtu)
#           BFmatrix <- matrix(rep(BFtu,2),ncol=2) / matrix(rep(BFtu,2),ncol=2,byrow=T)
#           logBFmatrix <- matrix(rep(logBFtu,2),ncol=2) - matrix(rep(logBFtu,2),ncol=2,byrow=T)
#           row.names(BFmatrix) <- row.names(logBFmatrix) <- hypotheses
#           colnames(BFmatrix) <- colnames(logBFmatrix) <- hypotheses
#           relfit <- matrix(c(rep(1,2),exp(relfit1),exp(relfit2)),ncol=2)
#           relcomp <- matrix(c(rep(1,2),rep(.5,2)),ncol=2)
#           row.names(relfit) <- row.names(relcomp) <- hypotheses
#           colnames(relfit) <- c("f=","f>")
#           colnames(relcomp) <- c("c=","c>")
#           # BF1 <- BF(lm1,hypothesis=paste0("mu_minus_mu0<",as.character(mu0)),
#           #           prior=prior)
#         }else if(hypothesis=="exploratory"){
#           hypotheses <- c("true difference is equal to 0","true difference is less than 0",
#                           "true difference is greater than 0")
#           logBFtu <- c(relfit0-relcomp0,relfit1-relcomp1,relfit2-relcomp2)
#           names(logBFtu) <- hypotheses
#           BFtu <- exp(logBFtu)
#           PHP <- BFtu/sum(BFtu)
#           BFmatrix <- matrix(rep(BFtu,3),ncol=3) / matrix(rep(BFtu,3),ncol=3,byrow=T)
#           logBFmatrix <- matrix(rep(logBFtu,3),ncol=3) - matrix(rep(logBFtu,3),ncol=3,byrow=T)
#           row.names(BFmatrix) <- row.names(logBFmatrix) <- hypotheses
#           colnames(BFmatrix) <- colnames(logBFmatrix) <- hypotheses
#           relfit <- matrix(c(exp(relfit0),rep(1,3),exp(relfit1),exp(relfit2)),ncol=2)
#           relcomp <- matrix(c(exp(relcomp0),rep(1,3),rep(.5,2)),ncol=2)
#           row.names(relfit) <- row.names(relcomp) <- hypotheses
#           colnames(relfit) <- c("f=","f>")
#           colnames(relcomp) <- c("c=","c>")
#         }
      }else{
        BFtu_confirmatory <- PHP_confirmatory <- BFmatrix_confirmatory <- relative_fit <-
          relative_complexity <- NULL
      }
    }
  }

  BFlm_out <- list(
    BFtu_exploratory=BFtu_exploratory,
    PHP_exploratory=PHP_exploratory,
    BFtu_confirmatory=BFtu_confirmatory,
    PHP_confirmatory=PHP_confirmatory,
    BFmatrix_confirmatory=BFmatrix_confirmatory,
    relative_fit=relfit,
    relative_complexity=relcomp,
    model=x)

  class(BFlm_out) <- "BF"
  return(BFlm_out)
}


BFupdate.htest <- function(BF1,
                     x,
                     ...){
  stop("REMINDER: Needs to be done.")
}




