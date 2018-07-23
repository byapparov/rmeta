#' Metadata for job execution
#'
#' Functions that allow to log and query job executions.
#'
#' @param job name of the data pipeline
#'
#' @name log-job
NULL

#' @details
#' `log_job_start` - logs start of the job execution
#'
#' @rdname log-job
#' @export
start_job <- function(job) {
  assertthat::assert_that(!is_set_job(), msg = "Should stop the job before starting a new one.")
  job <- structure(
    list(
      id = uuid(),
      name = job
    )
  )
  log_job_state(job, "start")
  rmeta_env$job <- job
  job$id
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
  }
  else {
    warning("Job was not started")
  }
  reset_job()
}

#' Gets value of the current job
current_job <- function() {
  rmeta_env$job
}

current_job_name <- function() {
  if (is_set_job()) {
    job <- current_job()
    job$name
  }
  else {
    stop("Job was not started")
  }
}

#' Removes value of the current job
reset_job <- function() {
  rmeta_env$job <- NULL
}

#' Checks if execution job was set
#'
#' @export
is_set_job <- function() {
  !is.null(current_job())
}

# Helper function that logs state of the job
log_job_state <- function(job, state) {
  dt <- data.frame(value = 1, id = job$id, job = job$name, state = state)
  influxdbr::influx_write(
    x = dt,
    con = influxConnection(),
    db = influxDatabase(),
    tag_cols = c("id", "job", "state"),
    measurement = "execution",
    precision = "ms"
  )
}

#' @details
#' `read_job_executions` - reads execution log for a given job
#'
#' @name log-job
#'
#' @export
#' @param days number of days to select
read_job_executions <- function(job = "", days = 7L) {
  id <- time <- NULL
  where.clause = paste0("time > now() - ", days, "d")
  if (nchar(job) > 0) {
    where.clause = paste0("job = '", job, "' AND ", where.clause)
  }
  res <- influxdbr::influx_select(
    con = influxConnection(),
    db = influxDatabase(),
    measurement = "execution",
    field_keys = "id, job, state, value",
    where = where.clause,
    order_desc = TRUE,
    return_xts = FALSE
  )
  res <- data.table::data.table(res[[1]])
  res <- res[!is.na(id)]
  times <- res[, list(time = min(time, na.rm = T)), by = id]
  executions <- data.table::dcast(
    res,
    id + job ~ state,
    fun = list(min),
    value.var = list("value"),
    fill = 0L
  )
  res <- merge(executions, times, by = "id", all.x = T)
}

