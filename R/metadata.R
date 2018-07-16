library(influxdbr)
library(data.table)

rmeta_env <- new.env(parent = emptyenv())

#' Log job execution
#'
#' @name log-meta
#'
#' @export
#'
#' @param job name of the data pipeline
#' @param destination name of the table that data is written to
#' @param records number of records processed by the job
#' @param increment the largest value in the increment field of the destination
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

#' Gets largest increment for the given destination
#'
#' @rdname log-meta
read_increment <- function(job, destination) {
  res <- influxdbr::influx_select(
    con = influxConnection(),
    db = Sys.getenv("INFLUX_DB"),
    measurement = "task",
    field_keys = "increment",
    where = paste0("type = 'write' AND job = '", job, "' AND datasource = '", destination, "'"),
    limit = 1,
    order_desc = TRUE,
    return_xts = FALSE,
    simplifyList = TRUE
  )
  res[[1]]$increment
}


#' Read all uploads within a given timeperiod
#'
#' @rdname log-meta
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
      "type = 'write' AND job = '", job,
      "' AND datasource = '", destination,
      "' AND time > now() - ", days, "d"),
    order_desc = TRUE,
    return_xts = FALSE,
    simplifyList = TRUE
  )
  res[[1]]
}

#' Reads execution log for a given job
#'
#' @rdname log-meta
#'
#' @export
read_job_executions <- function(job = "", days = 7L) {
  where.clause = paste0("time > now() - ", days, "d")
  if (nchar(job) > 0) {
    where.clause = paste0("job = '", job, "' AND ", where.clause)
  }
  res <- influxdbr::influx_select(
    con = influxConnection(),
    db = Sys.getenv("INFLUX_DB"),
    measurement = "execution",
    field_keys = "job, state, value",
    where = where.clause,
    order_desc = TRUE,
    return_xts = FALSE
  )
  res <- data.table::data.table(res[[1]])
  res <- dcast(res, time + job ~ state, value.var = "value", fill = 0L)
}

#' Logs start of the job execution
#'
#' @rdname log-meta
#' @export
log_job_start <- function(job) {
  log_job_state(job, "start")
}


#' Logs end of the job exectuion
#'
#' @rdname log-meta
#' @export
log_job_end <- function(job) {
  log_job_state(job, "end")
}

#' Logs errored job
#'
#' @rdname log-meta
#' @export
log_job_error <- function(job) {
  log_job_state(job, "error")
}

# Helper function that logs state of the job
log_job_state <- function(job, state) {
  dt <- data.frame(value = 1, job = job, state = state)
  influxdbr::influx_write(
    x = dt,
    con = influxConnection(),
    db = Sys.getenv("INFLUX_DB"),
    tag_cols = c("job", "state"),
    measurement = "execution"
  )
}


influxConnection <- function(scheme = c("http", "https"),
                             host = Sys.getenv("INFLUX_HOST"),
                             user = Sys.getenv("INFLUX_USERNAME"),
                             port = Sys.getenv("INFLUX_PORT", 8086),
                             pwd = Sys.getenv("INFLUX_PASSWORD")) {
  if (!is.null(rmeta_env$influx_conn)) {
    return(rmeta_env$influx_conn)
  }
  # Creates connection to the influxdb in test consul
  rmeta_env$influx_conn <-
    influxdbr::influx_connection(
      scheme = scheme,
      host = host,
      port = port,
      user = user,
      pass = pwd
    )
  rmeta_env$influx_conn
}
