## Introduction

`rmeta` package allows to log data pipeline exectution to InfluxDb.


## Schema

Scheduled batch executions are logged into `exectuion` measurement

### Execution

| field         |   type        | sample values        | 
|:-------------:|:-------------:|:---------------------|
| time          | timestamp     | 2015-08-18T00:06:00Z |
| job           | tag           | customer_pipeline    |
| state         | tag           | start, end, error    |
| value         | field         | 1                    |

Individual tasks can be logged into `task` measurement

### Task

| field         |   type        | sample values        | 
|:-------------:|:-------------:|:---------------------|
| time          | timestamp     | 2015-08-18T00:06:00Z |
| job           | tag           | customer_pipeline    |
| type          | tag           | write                |
| datasource    | tag           | events_table         |
| records       | field (int)   | 1000                 |
| increment     | field (int)   | 100001               |


## Examples

Logging scheduled pipeline execution and increments inside the pipeline code

```R

# .Renviron
# INFLUX_HOST=localhost
# INFLUX_USERNAME=user
# INFLUX_PASSWORD=pass
# INFLUX_DB=metadata

job_start("my_pipeline")

# find where we finished last time
target_data.increment <- read_increment("my_pipeline", "target_table")

# use increment to load delta (new data since last execution)
dt <- loadDataFunction(target_data.increment)

# pre-processes data and get (dt)
dt <- prepareDataFunction(dt)

target_data.new_increment <- max(dt$increment_integer_field)
target_data.records <- nrow(dt)

# save new increment for the next delta load
log_data_write(
  job = "my_pipeline", 
  destination = "target_table",
  records = target_data.records, 
  increment = target_data.new_increment
)
job_end("my_pipeline")
```
