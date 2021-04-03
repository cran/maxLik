\name{tidy.maxLik}
\alias{tidy.maxLik}
\alias{glance.maxLik}
\title{tidy and glance methods for maxLik objects}
\description{
  These methods return information about an estimation. They require the
  "tibble" package to be installed.
}
\usage{
\method{tidy}{maxLik}(x,  ...)
\method{glance}{maxLik}(x, ...)
}

\arguments{
  \item{x}{
    object of class 'maxLik'.
  }
  \item{\ldots}{Not used.}
}
\value{
  For \code{tidy()}, a tibble with columns:
  \describe{
    \item{term}{The name or number of the estimated parameter.}
    \item{estimate}{The estimated parameter.}
    \item{std.error}{The standard error of the estimate.}
    \item{statistic}{The t statistic of the estimate.}
    \item{p.value}{The p-value.}
  }
    
    For \code{glance()}, a one-row tibble with columns:
    \describe{
      \item{df}{The degrees of freedom of the model.}
      \item{logLik}{The log-likelihood of the model.}
      \item{AIC}{Akaike's Information Criterion for the model.}
      \item{nobs}{The number of observations, if this is available, otherwise \code{NA}.}
    }
}

\author{David Hugh-Jones}
\examples{
## ML estimation of exponential distribution:
t <- rexp(100, 2)
loglik <- function(theta) log(theta) - theta*t
gradlik <- function(theta) 1/theta - t
hesslik <- function(theta) -100/theta^2
## Estimate with numeric gradient and hessian
a <- maxLik(loglik, start=1, control=list(printLevel=2))
tidy(a)
glance(a)
}
