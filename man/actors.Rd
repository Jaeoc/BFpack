% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/actors.R
\docType{data}
\name{actors}
\alias{actors}
\title{Actors from a consultancy firm}
\format{dataframe (25 rows, 4 columns)

\tabular{lll}{
   \strong{actors$id} \tab \code{integer} \tab ID of the employee, corresponding to 
   the sender and receiver IDs in the events dataframe \cr
   \strong{actors$position} \tab \code{numeric} \tab Hierarchical position of the employee,
   ranging from 1-4 \cr
   \strong{actors$division} \tab \code{character} \tab Categorical variable, indicating the 
   division of the employee \cr
   \strong{actors$location} \tab \code{integer} \tab Categorical variable, indicating the location
   of the building the employee works in \cr
}}
\source{
\href{https://doi.org/10.1016/j.chaos.2018.11.027}{
doi:10.1016/j.chaos.2018.11.027}
}
\usage{
data(actors)
}
\description{
Information on 25 actors of a consultancy firm for which a sequence of e-mail
messages is observed (can be accessed through the 'events' data object). 
The actor data is simulated based on information provided in 
Mulder & Leenders (2019). In the original data, 70 actors were involved. The
current data is a random sample of 25 actors.
}
\details{
The related data files 'events', 'same_building', 'same_division' and 
'same_hierarchy' contain information on the event sequence and three event 
statistics respectively.
}
\references{
Mulder, J., & Leenders, R. T. (2019). Modeling the evolution of 
interaction behavior in social networks: A dynamic relational event approach 
for real-time analysis. Chaos, Solitons and Fractal Nonlinear, 119, 73-85,
https://doi.org/10.1016/j.chaos.2018.11.027
\href{https://doi.org/10.1016/j.chaos.2018.11.027}{
doi:10.1016/j.chaos.2018.11.027}
}
\keyword{datasets}
