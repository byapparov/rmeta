% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/connection.R
\name{influxConnection}
\alias{influxConnection}
\title{Connection to the InfluxDb using environtment variables}
\usage{
influxConnection(scheme = c("http", "https"),
  host = Sys.getenv("INFLUX_HOST"), user = Sys.getenv("INFLUX_USERNAME"),
  port = Sys.getenv("INFLUX_PORT", 8086),
  pass = Sys.getenv("INFLUX_PASSWORD"))
}
\arguments{
\item{scheme}{The scheme to use, either http or https. Defaults to http.}

\item{host}{Hostname of the InfluxDB server. Defaults to localhost.}

\item{user}{username The username to use. Defaults to "user".}

\item{port}{numerical. Port number of the InfluxDB server. Defaults to 8086.}

\item{pass}{password The password to use. Defaults to "pass".}
}
\description{
Requires:
 INFLUX_HOST
 INFLUX_USERNAME
 INFLUX_PORT
 INFLUX_PASSWORD
}
\section{structure of configuration file}{


A configuration file may contain several connection settings. Each setting
has the following structure:\cr\preformatted{[group]
scheme=http
host=localhost  
port=8086
user=username
pass=password  
path=/
}

}

\references{
\url{https://influxdb.com/}
}
