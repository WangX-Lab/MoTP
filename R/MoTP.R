#' Multi-Omics Tumor Purity Prediction
#'
#' This function predicts tumor purity from either single-omics or multi-omics data using pre-trained models. 
#' #'
#' @param data_list A list of omics data frames or matrices. Specifically, each element in the list represents a different omics dataset, where each row corresponds to a gene and each column corresponds to a tumor sample. The list must contain at least one omics dataset.
#' @param omics_list A character vector indicating the type of each omics data in data_list. Default is c("mRNA", "miRNA", "lncRNA", "DNA-methylation").
#'
#' @return A data frame containing sample IDs and predicted tumor purity values for each omics type as well as the averaged tumor purity across all provided omics types.
#' @export
#'
#' @examples
#' # Example usage:
#' # data_list <- list(mRNA_data, miRNA_data, lncRNA_data, methylation_data)
#' # result <- MoTP(data_list,c("mRNA", "miRNA", "lncRNA", "DNA-methylation"))
MoTP <- function(data_list, omics_list = c("mRNA", "miRNA", "lncRNA", "DNA-methylation")) {
  if (missing(data_list) || !is.list(data_list) || length(data_list) == 0) {
    stop("The data_list is incorrect. It should be a list of data frames or matrices.")
  }
  if (missing(omics_list) || !is.vector(omics_list) || length(omics_list) != length(data_list)) {
    stop("The omics_list is incorrect. It should be a vector with the same length as data_list.")
  }
  
  # Load all models
  load(system.file("data", "all_models.RData", package = "MoTP"))
  
  config <- list(
    "mRNA" = list(Fit = mrnMoTP_model, neurons = 2, name = "mrnMoTP"),
    "miRNA" = list(Fit = mirMoTP_model, neurons = 5, name = "mirMoTP"),
    "lncRNA" = list(Fit = lncMoTP_model, neurons = 2, name = "lncMoTP"),
    "DNA-methylation" = list(Fit = metMoTP_model, neurons = 6, name = "metMoTP")
  )
  
  if (!all(omics_list %in% names(config))) {
    stop("Unsupported omics type.")
  }
  
  process_data <- function(data, Fit, neurons) {
    training_data <- Fit$trainingData
    features <- intersect(colnames(training_data)[-1], colnames(data))
    
    if (length(features) < length(colnames(training_data)[-1]) / 2) {
      stop("Too many features of the current data are missing!")
    }
    
    if (length(features) < length(colnames(training_data)[-1])) {
      training_data2 <- training_data[, c(".outcome", features), drop = FALSE]
      set.seed(456)
      
      #' @importFrom caret train trainControl 
      tuneGrid <- expand.grid(neurons = neurons)
      ctrl <- caret::trainControl(method = "none")
      
      New_Fit <- caret::train(.outcome ~ ., data = training_data2, 
                              method = "brnn",
                              trControl = ctrl,
                              tuneGrid = tuneGrid,
                              verbose = FALSE,
                              preProc = "zv")
      
      #' @importFrom stats predict 
      predictions <- stats::predict(New_Fit, newdata = data[, features, drop = FALSE])
    } else {
      predictions <- stats::predict(Fit, newdata = data)
    }
    
    predictions <- unlist(predictions)
    predictions <- pmax(pmin(predictions, 1), 0)
    predictions2 <- data.frame(Sample = rownames(data), Prediction = predictions)
    return(predictions2)
  }
  
  results <- lapply(seq_along(data_list), function(i) {
    data <- data_list[[i]]
    type <- omics_list[i]
    config_item <- config[[type]]
    result <- process_data(data, config_item$Fit, config_item$neurons)
    colnames(result)[2] <- config_item$name
    result
  })
  
  if (length(results) == 1) {
    merged_result <- results[[1]]
    merged_result$MoTP <- merged_result[,2]
  } else {
    merged_result <- Reduce(function(x, y) merge(x, y, by = "Sample", all = TRUE), results)
    merged_result[, -1] <- lapply(merged_result[, -1], as.numeric)
    mean_MoTP <- rowMeans(merged_result[, -1], na.rm = TRUE)
    merged_result$MoTP <- mean_MoTP
  }
  
  return(merged_result)
}


