#' Metadata for task execution
#'
#' Functions that allow to log and query job executions.
#'
#' @param job name of the data pipeline
#' @param destination name of the table that data is written to
#' @param records number of records processed by the job
#' @param increment the largest value in the increment field of the destination
#'
#' @name log-job
NULL


#' @details
#' `read_job_executions` - reads execution log for a given job
#'
#' @name log-job
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
  res <- data.table::dcast(res, time + job ~ state, value.var = "value", fill = 0L)
}

#' @details
#' `log_job_start` - logs start of the job execution
#'
#' @rdname log-job
#' @export
start_job <- function(job) {
  assertthat::assert_that(!is_set_job(), msg = "Should stop the job before starting a new one.")
  log_job_state(job, "start")
  rmeta_env$job <- job
}


#' @details
#' `log_job_end` - logs end of the job exectuion
#'
#' @rdname log-job
#' @export
end_job <- function() {
  if (is_set_job()) {
    log_job_state(current_job(), "end")
  } else {
    warning("Job was not started")
  }
  reset_job()
}

#' @details
#' `log_job_error` - logs errored job
#'
#' @rdname log-job
#' @export
error_job <- function() {
  if (is_set_job()) {
    log_job_state(current_job(), "error")
  } else {
    warning("Job was not started")
  }
  reset_job()
}

#' Gets value of the current job
current_job <- function() {
  rmeta_env$job
}

#' Removes value of the current job
reset_job <- function() {
  rmeta_env$job <- NULL
}

#' @export
is_set_job <- function() {
  !is.null(current_job())
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

