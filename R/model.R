#' Logs performance of the statistical or machine learning model into InfluxDb
#'
#' @export
#' @name log-model
#'
#' @param dataset name of the dataset that was targed by the model, e.g. `sessions`
#' @param target explained variable, e.g. `conversion rate``
#' @param test boolean defines whether validation was done on test or training dataset
#' @param algorithm name of the method that was used to create the model
#' @param group group within the data if data is split into different segments
#' @param metric name of the model performance metric, e.g. rsquared or mape
#' @param records size of the sample that was used to estimate the model
#' @param value value of the model performance metric on a given sample
log_model_performance <- function(dataset, target, test, algorithm, metric, group, records, value){
  job <- current_job()
  dt <- data.frame(
    type = "performance",
    id = job$id,
    job = job$name,
    dataset = dataset,
    target = target,
    test = as.character(test),
    algorithm = algorithm,
    metric = metric,
    group = group,
    records = as.integer(records),
    value = as.numeric(value)
  )
  influxdbr::influx_write(
    x = dt,
    con = influxConnection(),
    db = influxDatabase(),
    tag_cols = c(
      "type",
      "id",
      "job",
      "dataset",
      "target",
      "test",
      "algorithm",
      "metric",
      "group"
    ),
    measurement = "model",
    precision = "ms"
  )
}
