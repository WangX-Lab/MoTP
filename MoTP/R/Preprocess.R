#' Preprocess Omics Data
#'
#' This function preprocessing a list of omics data frames or matrices.Including impute missing values and [0,1] scaled (maximum=1, minimum=0). 
#' This step is not necessary, you can choose to process the data yourself, as long as the data has no missing values and the range is scaled to [0,1].
#'
#' @param original_list A list of omics data frames or matrices in which each row is a feature and each column is a sample.The list needs to contain at least one of the omics data.
#'
#' @return The list must contain at least one omics datase
#' @export
#'
#' @examples
#' # Example usage:
#' # preprocessed_list <- Preprocess(original_list)
Preprocess <- function(original_list) {
  if (missing(original_list) || !is.list(original_list)|| length(original_list) == 0) {
    stop("It should be a list containing at least one omics data")
  }

  lapply(original_list, function(omics_data) {
    if (!is.data.frame(omics_data) && !is.matrix(omics_data)) {
      stop("Each element in the list should be a data.frame or matrix.")
    }

  if (nrow(omics_data) < 2) {
    stop("Each data matrix or data.frame should have at least 2 samples.")
  }

    row_names <- rownames(omics_data)
    
    #' @importFrom data.table as.data.table
    DT <- data.table::as.data.table(omics_data)

    ## .SD is used in data.table environments
    DT <- DT[, lapply(.SD, function(x) {
      if (any(!is.numeric(x))) stop("All data must be numeric.")
      x[is.na(x)] <- mean(x, na.rm = TRUE)
      x <- (x - min(x)) / (max(x) - min(x))
      x[is.nan(x)] <- 0
      return(x)
    })]

    result <- as.data.frame(DT)
    rownames(result) <- row_names
    if (is.matrix(omics_data)) result <- as.matrix(result)

    return(result)
  })
}