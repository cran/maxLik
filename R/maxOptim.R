maxOptim <- function(fn, grad, hess,
                    start, method, fixed,
                    print.level,
                    iterlim,
                    constraints,
                    tol, reltol,
                    parscale,
                    alpha = NULL, beta = NULL, gamma = NULL,
                    temp = NULL, tmax = NULL, random.seed = NULL, cand = NULL,
                    ...) {

   if( method == "Nelder-Mead" ) {
      maxMethod <- "maxNM"
   } else {
      maxMethod <- paste( "max", method, sep = "" )
   }

   argNames <- c( "fn", "grad", "hess", "start", "print.level", "iterlim",
      "constraints", "tol", "reltol", "parscale", "alpha", "beta", "gamma",
      "temp", "tmax" )
   checkFuncArgs( fn, argNames, "fn", maxMethod )
   if( !is.null( grad ) ) {
      checkFuncArgs( grad, argNames, "grad", maxMethod )
   }
   if( !is.null( hess ) ) {
      checkFuncArgs( hess, argNames, "hess", maxMethod )
   }

   ## check argument 'fixed'
   fixed <- prepareFixed( start = start, activePar = NULL, fixed = fixed )

   message <- function(c) {
      switch(as.character(c),
               "0" = "successful convergence",
               "10" = "degeneracy in Nelder-Mead simplex",
               "51" = "warning from the 'L-BFGS-B' method; see the corresponding component 'message' for details",
               "52" = "error from the 'L-BFGS-B' method; see the corresponding component 'message' for details"
               )
   }

   ## strip possible SUMT parameters and call the function thereafter
   environment( callWithoutSumt ) <- environment()
   maximType <- paste( method, "maximisation" )
   parscale <- rep(parscale, length.out=length(start))
   control <- list(trace=max(print.level, 0),
                    REPORT=1,
                    fnscale=-1,
                   reltol=reltol,
                    maxit=iterlim,
                    parscale=parscale[ !fixed ],
                    alpha=alpha, beta=beta, gamma=gamma,
                    temp=temp, tmax=tmax )
   f1 <- callWithoutSumt( start, "logLikFunc", fnOrig = fn, gradOrig = grad,
      hessOrig = hess, ...)
   if(is.na( f1)) {
      result <- list(code=100, message=maximMessage("100"),
                     iterations=0,
                     type=maximType)
      class(result) <- "maxim"
      return(result)
   }
   if(print.level > 2) {
      cat("Initial function value:", f1, "\n")
   }
   if( method == "BFGS" ) {
      G1 <- callWithoutSumt( start, "logLikGrad", fnOrig = fn, gradOrig = grad,
         hessOrig = hess, ...)
      if(print.level > 2) {
         cat("Initial gradient value:\n")
         print(G1)
      }
      if(any(is.na(G1))) {
         stop("NA in the initial gradient")
      }
      if(any(is.infinite(G1))) {
         stop("Infinite initial gradient")
      }
      if(length(G1) != length(start)) {
         stop( "length of gradient (", length(G1),
            ") not equal to the no. of parameters (", length(start), ")" )
      }
   }

   ## function to return the gradients (BFGS) or the new candidate point (SANN)
   if( method == "BFGS" ) {
      gradOptim <- logLikGrad
   } else if( method == "SANN" ) {
      if( is.null( cand ) ) {
         gradOptim <- NULL
      } else {
         gradOptim <- function( theta, fnOrig, gradOrig, hessOrig,
               start, fixed, ... ) {
            return( cand( theta, ... ) )
         }
      }
   } else if( method == "Nelder-Mead" ) {
      gradOptim <- NULL
   } else {
      stop( "internal error: unknown method '", method, "'" )
   }

   ## A note about return value:
   ## We can the return from 'optim' in a object of class 'maxim'.
   ## However, as 'sumt' already returns such an object, we return the
   ## result of 'sumt' directly, without the canning
   if(is.null(constraints)) {
       result <- optim( par = start[ !fixed ], fn = logLikFunc, control = control,
                      method = method, gr = gradOptim, fnOrig = fn,
                      gradOrig = grad, hessOrig = hess,
                      start = start, fixed = fixed, ... )
       resultConstraints <- NULL
    }
   else {
      ## linear equality and inequality constraints
                           # equality constraints: A %*% beta + B >= 0
      if(identical(names(constraints), c("ineqA", "ineqB"))) {
         ui <- constraints$ineqA
         ci <- -constraints$ineqB
         result <- constrOptim2( theta = start[ !fixed ],
                          f = logLikFunc, grad = gradOptim,
                          ui=ui, ci=ci, control=control,
                          method = method, fnOrig = fn, gradOrig = grad,
                          hessOrig = hess, start = start, fixed = fixed, ...)
         resultConstraints <- list(type="constrOptim",
                                   barrier.value=result$barrier.value,
                                   outer.iterations=result$outer.iterations
                                   )
      }
      else if(identical(names(constraints), c("eqA", "eqB"))) {
                           # equality constraints: A %*% beta + B = 0
         argList <- list(fn=fn, grad=grad, hess=hess,
                        start=start, fixed = fixed,
                        maxRoutine = get( maxMethod ),
                        constraints=constraints,
                        print.level=print.level,
                        iterlim = iterlim,
                        tol = tol, reltol = reltol, parscale = parscale,
                        alpha = alpha, beta= beta, gamma = gamma,
                        temp = temp, tmax = tmax, random.seed = random.seed,
                        cand = cand,
                        ...)
         result <- do.call( sumt, argList[ !sapply( argList, is.null ) ] )
         return(result)
                           # this is already maxim object
      }
      else {
         stop( maxMethod, " only supports the following constraints:\n",
              "constraints=list(ineqA, ineqB)\n",
              "\tfor A %*% beta + B >= 0 linear inequality constraints\n",
              "current constraints:",
              paste(names(constraints), collapse=" "))
      }
   }

   # estimates (including fixed parameters)
   estimate <- start
   estimate[ !fixed ] <- result$par

   # calculate (final) Hessian
   hessian <- logLikHess( estimate, fnOrig = fn,  gradOrig = grad,
      hessOrig = hess, ... )

   result <- list(
                   maximum=result$value,
                   estimate=estimate,
                   gradient=callWithoutSumt( estimate, "logLikGrad",
                     fnOrig = fn, gradOrig = grad, hessOrig = hess, ... ),
                   hessian=hessian,
                   code=result$convergence,
                   message=paste(message(result$convergence), result$message),
                   last.step=NULL,
                   activePar = !fixed,
                   iterations=result$counts[1],
                   type=maximType,
                  constraints=resultConstraints
                  )
   class(result) <- "maxim"
   return(result)
}