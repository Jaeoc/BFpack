#' Wason task perormance and morality
#'
#' Data from an experimental study, using the Wason selection task (Wason 1968)
#' to examine whether humans have cognitive adaptations for detecting violations
#' of rules in multiple moral domains. Moral domains are operationalized in
#' terms of the five domains of the Moral Foundations Questionnaire
#' (Graham et al. 2011).
#' These data were simulated using the
#' R-package \code{synthpop}, based on the characteristics of the original data.
#'
#' \tabular{lll}{
#'    \strong{sex} \tab \code{factor} \tab Participant sex\cr
#'    \strong{age} \tab \code{integer} \tab Participant age\cr
#'    \strong{nationality} \tab \code{factor} \tab Participant nationality\cr
#'    \strong{politics} \tab \code{integer} \tab How would you define your political opinions? Likert type scale, from 1 (Liberal) to 6 (Conservative)\cr
#'    \strong{WasonOrder} \tab \code{factor} \tab Was the Wason task presented before, or after the MFQ? \cr
#'    \strong{Harm} \tab \code{numeric} \tab MFQ harm domain.\cr
#'    \strong{Fairness} \tab \code{numeric} \tab MFQ fairness domain.\cr
#'    \strong{Loyalty} \tab \code{numeric} \tab MFQ loyalty domain.\cr
#'    \strong{Purity} \tab \code{numeric} \tab MFQ purity domain.\cr
#'    \strong{Tasktype} \tab \code{ordered} \tab How was the Wason task framed?\cr
#'    \strong{GotRight} \tab \code{factor} \tab Did the participant give the correct answer to the Wason task?
#' }
#' @docType data
#' @keywords datasets
#' @name sivan
#' @usage data(sivan)
#' @references Sivan, J., Curry, O. S., & Van Lissa, C. J. (2018). Excavating the Foundations: Cognitive Adaptations for Multiple Moral Domains. Evolutionary Psychological Science, 4(4), 408–419. https://doi.org/10.1007/s40806-018-0154-8
#' \href{https://doi.org/10.1007/s40806-018-0154-8}{
#' doi:10.1007/s40806-018-0154-8}
#' @source \href{https://doi.org/10.1007/s40806-018-0154-8}{
#' doi:10.1007/s40806-018-0154-8}
#' @format A data.frame with 887 rows and 12 columns.
NULL
