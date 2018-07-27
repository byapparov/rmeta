rmeta_env <- new.env(parent = emptyenv())

#' Connection to the InfluxDb using environtment variables
#'
#' Requires:
#'  INFLUX_HOST
#'  INFLUX_USERNAME
#'  INFLUX_PORT
#'  INFLUX_PASSWORD
#' @export
#' @inherit influxdbr::influx_connection
influxConnection <- function(scheme = c("http", "https"),
                             host = Sys.getenv("INFLUX_HOST"),
                             user = Sys.getenv("INFLUX_USERNAME"),
                             port = Sys.getenv("INFLUX_PORT", 8086),
                             pass = Sys.getenv("INFLUX_PASSWORD")) {
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
      pass = pass
    )
  rmeta_env$influx_conn
}

#' Gets database name from environment variable
#'
#' @export
influxDatabase <- function() {
  Sys.getenv("INFLUX_DB")
}
