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
log_data_write <- function(job, destination, records, increment) {
  dt <- data.frame(
    type = "write",
    job = job,
    datasource = destination,
    records = as.integer(records),
    increment = as.integer(increment)
  )
  influxdbr::influx_write(
    x = dt,
    con = influxConnection(),
    db = Sys.getenv("INFLUX_DB"),
    tag_cols = c("type", "job", "datasource"),
    measurement = "task"
  )
}

#' @details
#' `read_increment` -gets largest increment for the given destination
#'
#' @name log-task
read_increment <- function(job, destination) {
  res <- influxdbr::influx_select(
    con = influxConnection(),
    db = Sys.getenv("INFLUX_DB"),
    measurement = "task",
    field_keys = "increment",
    where = paste0(
      "type = 'write' AND ",
      "job = '", job,"' AND ",
      "datasource = '", destination, "'"
    ),
    limit = 1,
    order_desc = TRUE,
    return_xts = FALSE,
    simplifyList = TRUE
  )
  res[[1]]$increment
}


#' @details
#' `read_data_writes` - reads all uploads within a given timeperiod
#'
#' @rdname log-task
#'
#' @export
#' @param days number of days from now that will be included in the extract
read_data_writes <- function(job, destination, days =7L) {
  res <- influxdbr::influx_select(
    con = influxConnection(),
    db = Sys.getenv("INFLUX_DB"),
    measurement = "task",
    field_keys = "increment, records",
    where = paste0(
      "type = 'write' AND ",
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
