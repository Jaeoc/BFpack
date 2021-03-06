


#' @importFrom MCMCpack rinvgamma
#' @method BF hetcor
#' @export
BF.hetcor <- function(x,
                       hypothesis = NULL,
                       prior = NULL,
                       ...){
  if(is.null(hypothesis)){
    constraints <- "exploratory"
  } else {
    constraints <- hypothesis
  }
  if(is.null(prior)){
    priorprob <- "default"
  } else {
    priorprob <- prior
  }

  P <- nrow(x$std.errors)
  numcorr <- P*(P-1)/2
  estimates <- x$correlations[lower.tri(diag(P))]
  stderr <- x$std.errors[lower.tri(diag(P))]
  errcov <- diag(stderr**2)

  corr_names <- names(get_estimates(x$correlations)$estimate)
  matrix_names <- matrix(corr_names,nrow=P)
  # equal correlations are at the opposite side of the vector
  corr_names_lower <- matrix_names[lower.tri(matrix_names)]
  corr_names_all <- c(matrix_names[lower.tri(matrix_names)],
                  t(matrix_names)[lower.tri(matrix_names)])

  #exploratory BF testing
  relfit <- matrix(c(dnorm(0,mean=estimates,sd=sqrt(diag(errcov))),
                     pnorm(0,mean=estimates,sd=sqrt(diag(errcov))),
                     1-pnorm(0,mean=estimates,sd=sqrt(diag(errcov)))),ncol=3)
  relcomp <- matrix(c(dbeta(rep(.5,numcorr),shape1=P/2,shape2=P/2)*.5,
                      rep(.5,2*numcorr)),ncol=3)
  row.names(relfit) <- row.names(relcomp) <- corr_names_lower

  BFtu_exploratory <- relfit / relcomp
  colnames(BFtu_exploratory) <- colnames(BFtu_exploratory) <-  c("Pr(=0)","Pr(<0)","Pr(>0)")
  PHP_exploratory <- BFtu_exploratory / apply(BFtu_exploratory,1,sum)

  #confirmatory BF testing
  if(constraints!="exploratory"){

    parse_hyp <- parse_hypothesis(corr_names_all,constraints)
    #combine equivalent correlations, e.g., cor(Y1,Y2)=corr(Y2,Y1).
    parse_hyp$hyp_mat <- cbind(parse_hyp$hyp_mat[,1:numcorr] + parse_hyp$hyp_mat[,numcorr+1:numcorr],
            parse_hyp$hyp_mat[,numcorr*2+1])
    #create coefficient with equality and order constraints
    RrList <- make_RrList2(parse_hyp)
    RrE <- RrList[[1]]
    RrO <- RrList[[2]]

    numhyp <- length(RrE)
    relcomp <- t(matrix(unlist(lapply(1:numhyp,function(h){
      jointuniform_measures(P,numcorr,1,RrE[[h]],RrO[[h]],Fisher=0)
    })),nrow=2))
    relfit <- t(matrix(unlist(lapply(1:numhyp,function(h){
      Gaussian_measures(estimates,errcov,RrE[[h]],RrO[[h]],names1=corr_names_lower,
                        constraints1=parse_hyp$original_hypothesis[h])
    })),nrow=2))
    row.names(relcomp) <- parse_hyp$original_hypothesis
    row.names(relfit) <- parse_hyp$original_hypothesis
    # evaluation of complement hypothesis
    relfit <- Gaussian_prob_Hc(estimates,errcov,relfit,RrO)
    relcomp <- jointuniform_prob_Hc(P,numcorr,1,relcomp,RrO)

    colnames(relcomp) <- c("c_E","c_O")
    colnames(relfit) <- c("f_E","f_O")
    # computation of exploratory BFs and PHPs
    # the BF for the complement hypothesis vs Hu needs to be computed.
    BFtu_confirmatory <- c(apply(relfit / relcomp, 1, prod))
    # Check input of prior probabilies
    if(!(priorprob == "default" || (length(priorprob)==nrow(relfit) && min(priorprob)>0) )){
      stop("'probprob' must be a vector of positive values or set to 'default'.")
    }
    # Change prior probs in case of default setting
    if(priorprob=="default"){
      priorprobs <- rep(1/length(BFtu_confirmatory),length(BFtu_confirmatory))
    }else{
      priorprobs <- priorprobs/sum(priorprobs)
    }
    names(priorprobs) <- names(BFtu_confirmatory)
    PHP_confirmatory <- BFtu_confirmatory*priorprobs / sum(BFtu_confirmatory*priorprobs)
    # names(PHP_confirmatory) <- unlist(lapply(1:length(parse_hyp$original_hypothesis),function(hyp){
    #   paste0("Pr(",parse_hyp$original_hypothesis,")")
    # }))
    BFmatrix_confirmatory <- matrix(rep(BFtu_confirmatory,length(BFtu_confirmatory)),ncol=length(BFtu_confirmatory))/
      t(matrix(rep(BFtu_confirmatory,length(BFtu_confirmatory)),ncol=length(BFtu_confirmatory)))
    row.names(BFmatrix_confirmatory) <- colnames(BFmatrix_confirmatory) <- names(BFtu_confirmatory)
  }else{
    BFtu_confirmatory <- PHP_confirmatory <- BFmatrix_confirmatory <- relfit <-
      relcomp <- NULL
  }

  # Store in output
  BFlm_out <- list(
    BFtu_exploratory=BFtu_exploratory,
    PHP_exploratory=PHP_exploratory,
    BFtu_confirmatory=BFtu_confirmatory,
    PHP_confirmatory=PHP_confirmatory,
    BFmatrix_confirmatory=BFmatrix_confirmatory,
    relative_fit=relfit,
    relative_complexity=relcomp,
    model=x,
    P=P,
    ngroups=1,
    constraints=constraints,
    priorprob=priorprob)

  class(BFlm_out) <- "BF"

  return(BFlm_out)

}







