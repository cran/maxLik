## Akaike (and other) information criteria
AIC <- function( object, ... )
    ## Number of iterations for iterative models
    UseMethod("AIC")

AIC.maxLik <- function(object, ..., k = 2)
    -2*logLik(object) + k*nParam(object, free=TRUE)
