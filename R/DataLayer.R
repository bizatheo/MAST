##' @details \code{addlayer(x)}: add a new layer with name \code{name}.  Returns a modified object.
##' @rdname addlayer
##' @export
setMethod('addlayer', signature(x='DataLayer', name='character'), function(x, name){
  newLayer <- array(NA, dim=c(nrow(x), ncol(x), 1), dimnames=c(dimnames(x)[-3], name))
  x@.Data <- abind(x@.Data, newLayer)
  x
})

##' @rdname addlayer
##' @details \code{layername(x)}: Return name of current layer, equivalent to \code{layer(x)}.
##' @export
setMethod('layername', signature(x='DataLayer'), function(x){
  if(length(dimnames(x)[[3]])>0) return(dimnames(x)[[3]][layer(x)])
  return(NULL)
})

##' @rdname addlayer
##' @details \code{layername(x)<-value}: Rename current layer to \code{character} \code{value}
##' @param value replacement
##' @export
setReplaceMethod('layername', signature(x='DataLayer', 'character'), function(x, value){
  dimnames(x)[[3]][layer(x)] <- value
  x
})

##' Get or set a matrix of measurement values in a \code{SingleCellAssay}
##'
##' Return or set a matrix of the measurement: cells by primerids.  \strong{Note this is the transpose of ExpressionSets}.
##' @param object \code{SingleCellAssay} or inheriting class
##' @return a \code{matrix} of measurement values with wells on the rows and features on the columns of the default layer
##' @rdname exprs
##' @aliases exprs,DataLayer-method
##' @export
setMethod("exprs",signature(object="DataLayer"),function(object){
  o <- object@.Data[,,layer(object), drop=FALSE]
  dn <- dimnames(o)
  dim(o) <- dim(o)[-3]
  dimnames(o) <- dn[-3]
  o
})


setMethod('initialize', 'DataLayer',
          function(.Object, ...){
            ## message('init DataLayer') #DEBUG
              ## This is (was?) necessary initialize since we inherit from 'array'
              ## But is rather mysterious, nonetheless.
            .Object <- getMethod('initialize', 'ANY')(.Object, ...)
            dn <- dimnames(.Object@.Data)
            dimnames(.Object@.Data) <-if(is.null(dn)) list(wells=NULL, features=NULL, layers=NULL) else dn            
            .Object
          })

##' @import Biobase
##' @describeIn exprs
##' @exportMethod "exprs<-"
##' @aliases exprs<-,DataLayer,ANY-method
setReplaceMethod('exprs', c('DataLayer', 'ANY'),
                 function(object, value){
                   if(!is.null(dim(value)) && !conform(object, value)) stop('Replacement must be same dimension as target')
                   object[[,]] <- value
                   object@valid <- FALSE
                   object
                 })


setMethod('conform', c('DataLayer', 'ANY'),
          function(dl, other){
            if(!(is(other, 'matrix') || is(other, 'array'))) return(FALSE)
            (nrow(dl) == nrow(other))*1 + (ncol(dl) == ncol(other))*2 +
              ifelse(is(other, 'DataLayer'),(nlayer(dl)==nlayer(other))*4, 0)
          })

setMethod('ncol', 'DataLayer',
          function(x){
            #if(length(x)==0) return(0)
            ncol(x@.Data[,,x@layer,drop=FALSE])
          })

try({setMethod('nrow', 'DataLayer',
          function(x){
            #if(length(x)==0) return(0)
            nrow(x@.Data[,,x@layer,drop=FALSE])
          })})                          #for some reason this errors out

##' @rdname addlayer
##' @details \code{nlayer(x)}: Return the number of layers.
##' @export
setMethod('nlayer', 'DataLayer',
          function(x){
            dim(x@.Data)[3]
          })

##' Subset a DataLayer
##'
##' Returns a subsetted DataLayer
##' @param x DataLayer
##' @param i boolean or integer index
##' @param j boolean or integer index
##' @param ... providing an extra index is an error
##' @param drop ignored
##' @return DataLayer
##' @export
##' @aliases [,DataLayer-method
setMethod('[', 'DataLayer', function(x, i, j, ..., drop=FALSE){
  if(!missing(i) && is.matrix(i)) stop('Only rectangular selections permitted')
 out <- .subsetHelper(x, i, j, ..., drop=drop)
  new('DataLayer', out, valid=x@valid, layer=x@layer)
})

.subsetHelper <- function(x, i, j, ..., drop=FALSE){
 vargs <- list(...)
  if(length(vargs)>0 || (!missing(i) && is.matrix(i) && ncol(i)>2)) stop('incorrect number of dimensions')
  #if(length(x)==0) return(numeric(0))
  out <- x@.Data[i,j,,drop=FALSE]
}


##' Extract from a DataLayer
##'
##' Returns the matrix representation (of the current layer) of the \code{DataLayer}
##' @return \code{matrix}
##' @export
##' @aliases [[,DataLayer,ANY-method
##' @aliases [[,DataLayer-method
##' @param x DataLayer
##' @param i integer index(s)
##' @param j integer index(s)
##' @param ... ignored
##' @param drop ignored
setMethod('[[', 'DataLayer', function(x, i, j, ..., drop=FALSE){
    if(!missing(i) && is.matrix(i) && ncol(i)==2){                        #matrix indexing
    ## i <- cbind(i[rep(1:nrow(i), times=nlayer(x)),], #make nlayer copies of i, appending 1...nlayer onto it
    ##            rep(seq_len(nlayer(x)), each=nrow(i)))
    i <- cbind(i, layer(x))
    out <- x@.Data[i,drop=FALSE]
  } else{
  out <- .subsetHelper(x, i, j, ..., drop=drop)
  out <- out[,,layer(x), drop=drop]
}
  if(!drop) dim(out) <- dim(out)[-length(dim(out))] #kill layer dimension
  out
})



##' Replace a section of a DataLayer
##'
##' @return DataLayer
##' @export
##' @aliases [[<-,DataLayer,ANY-method
##' @aliases [[<-,DataLayer-method
##' @param x DataLayer
##' @param i integer index(s)
##' @param j integer index(s)
##' @param value a numeric to replace the selected indices
##' @param ... ignored
setMethod('[[<-', 'DataLayer', function(x, i, j, ..., value){
   vargs <- list(...)
  if(length(vargs)>0 || (!missing(i) && is.matrix(i) && ncol(i)>2)) stop('incorrect number of dimensions')
  if(!missing(i) && is.matrix(i) && ncol(i)==2){                        #matrix indexing
    i <- cbind(i, layer(x))
    x@.Data[i] <- value
  } else{
   x@.Data[i,j,layer(x)] <- value
}
  x@valid <- FALSE
  x
})





##' Show methods
##' @export
##' @param object whose human-readable form is desired.
##' @rdname show
setMethod("show","DataLayer",function(object){
  cat(class(object), ' on layer ', layername(object), '\n', nlayer(object), " Layers; ", nrow(object), " wells; ", ncol(object), " features\n")
  invisible(NULL)
})

##' @rdname addlayer
##' @details code{layer(x)}: Return the current layer.
##' @export
setMethod('layer', c('DataLayer'), function(x){
  x@layer
})

##' @rdname addlayer
##' @details code{layer(x)<-value}: Change the current layer (by \code{integer} or \code{character} value)
##' @export
setReplaceMethod('layer', c('DataLayer', 'numeric'), function(x, value){
  if(round(value)!=value) stop('Index must be integer')
  if(value < 1 || value > nlayer(x)) stop('Index out of range')
  x@layer <- value
  x
})

##' @rdname addlayer
##' @export
setReplaceMethod('layer', c('DataLayer', 'character'), function(x, value){
  if(length(intersect(value, dimnames(x)[[3]]))!=1) stop('Bad index ', value)
  x@layer <- match(value, dimnames(x)[[3]])
  x
})


##' @export
setMethod('combine', signature(x='DataLayer', y='DataLayer'), function(x, y, ...) {
   if(!conform(x, y)>=6){
     stop('Objects must have same number of features and layers; x has dim ', paste(dim(x), ' '), '; y has dim ', paste(dim(y),' '))
   }
   .Data <- abind(x@.Data, y@.Data, along=1)
   proto <- new(class(x), .Data=.Data, valid=x@valid&y@valid)
     for( sl in setdiff(names(getSlots(class(x))), c('valid', '.Data'))){
        slot(proto, sl) <- slot(x, sl)
    }
   proto
 })


#'Split a DataLayer correctly
#'
#'split.default doesn't seem to do the right thing for an array
setMethod("split",signature(x="DataLayer"),function(x,f,drop=FALSE,...){
  if (!missing(...)) 
    .NotYetUsed(deparse(...), error = FALSE)
  if (is.list(f)) 
    f <- interaction(f)
  else if (!is.factor(f)) 
    f <- as.factor(f)
  else if (drop) 
    f <- factor(f)
  storage.mode(f) <- "integer"
  lf <- levels(f)
  y <- vector("list", length(lf))
  names(y) <- lf
  ind<-split(seq_len(nrow(x)),f) #Here we are only splitting on the ROWS!
  for (k in lf) y[[k]] <- x[ind[[k]]]
  y
})

