% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/BIC_orderconstraints.R
\name{create_matrices_oc}
\alias{create_matrices_oc}
\title{Create an augmented coefficient matrix for a set of order constraints.}
\usage{
create_matrices_oc(object, constraints)
}
\arguments{
\item{object}{A fitted model object, such as a glm-object}

\item{constraints}{A string that specifies a set of order constraints}
}
\value{
An object with the coefficient matrix R (obtained via '$R') and a coefficient matrix of one column r (obtained via '$r') to form the order constraints R %*% effects > r.
}
\description{
The function creates coefficient matrices R and r for the order constraints R %*% effects > r. It is used in the function 'bic_oc'.
}
\details{
The function was written by Anton Olsson Collentine, and slightly modified for the 'bic_oc' function.
}
\examples{
n <- 100
x1 <- rnorm(n)
x2 <- rnorm(n)
y <- 1 + .5 * x1 + 1 * x2 + rnorm(n)
df <- data.frame(y=y,x1=x1,x2=x2)
glm1 <- lm(y ~ 1 + x1 + x2, data=df)
# Coefficient matrices R and r are created for a set of order constraints that state that
# the effect of 'x2' on 'y' is larger than the effect of 'x1' on 'y', and both effects
# are assumed positive.
create_matrices_oc(glm1,"x2 > x1 > 0")
}
