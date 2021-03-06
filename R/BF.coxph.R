#BF method for coxph class objects


#' @method BF coxph
#' @export
BF.coxph <- function(x,
                      hypothesis = NULL,
                      prior = NULL,
                      ...){

  #Extract summary statistics
  n <- x$nevent
  covmN <- vcov(x)
  meanN <- coef(x)

  out <- Gaussian_estimator(meanN, covmN, n, hypothesis, prior)
  out$model <- x
  out
}
