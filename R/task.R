#' Metadata for task execution
#'
#' Functions that allow to log execution of pipeline tasks
#'
#' @param job name of the data pipeline
#' @param destination name of the table that data is written to
#' @param records number of records processed by the job
#' @param increment the largest value in the increment field of the destination
#'
#' @name log-task
NULL

#' @export
#' @rdname log-task
log_load <- function(destination, records, increment) {
  job <- current_job()
  dt <- data.frame(
    type = "load",
    id = job$id,
    job = job$name,
    datasource = destination,
    records = as.integer(records),
    increment = as.integer(increment)
  )
  influxdbr::influx_write(
    x = dt,
    con = influxConnection(),
    db = influxDatabase(),
    tag_cols = c("type", "id", "job", "datasource"),
    measurement = "task",
    precision = "ms"
  )
}

#' @details
#' `read_increment` -gets largest increment for the given destination
#'
#' @export
#' @name log-task
read_increment <- function(destination) {
  res <- influxdbr::influx_select(
    con = influxConnection(),
    db = influxDatabase(),
    measurement = "task",
    field_keys = "increment",
    where = paste0(
      "type = 'load' AND ",
      "job = '", current_job_name(), "' AND ",
      "datasource = '", destination, "'"
    ),
    limit = 1,
    order_desc = TRUE,
    return_xts = FALSE,
    simplifyList = TRUE
  )
  res <- res[[1]]$increment
  if (is.null(res)) {
    0L
  }
  else {
    res
  }
}


#' @details
#' `read_loads` - reads all uploads within a given timeperiod
#'
#' @rdname log-task
#'
#' @export
#' @param days number of days from now that will be included in the extract
read_loads <- function(job, destination, days = 7L) {
  res <- influxdbr::influx_select(
    con = influxConnection(),
    db = influxDatabase(),
    measurement = "task",
    field_keys = "id, job, datasource, increment, records",
    where = paste0(
      "type = 'load' AND ",
      "job = '", job, "' AND ",
      "datasource = '", destination, "' AND ",
      "time > now() - ", days, "d"
    ),
    order_desc = TRUE,
    return_xts = FALSE,
    simplifyList = TRUE
  )
  res[[1]]
}
