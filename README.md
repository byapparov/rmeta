## Introduction

`rmeta` package allows to log data pipeline exectution to InfluxDb.


## Schema

Scheduled batch executions are logged into `exectuion` measurement

### Execution

| field         |   type        | sample values                        | 
|:-------------:|:-------------:|:-------------------------------------|
| time          | timestamp     | 2015-08-18T00:06:00Z                 |
| id            | tag           | d1b5ece8-075d-4448-a0a4-465e9e89644c |
| job           | tag           | customer_pipeline                    |
| state         | tag           | start, end, error                    |
| value         | field         | 1                                    |

Individual tasks can be logged into `task` measurement

### Task

| field         |   type        | sample values        | 
|:-------------:|:-------------:|:---------------------|
| time          | timestamp     | 2015-08-18T00:06:00Z |
| id            | tag           | d1b5ece8-075d-4448-a0a4-465e9e89644c |
| job           | tag           | customer_pipeline    |
| type          | tag           | load                 |
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

start_job("my_pipeline")

# find where we finished the last time
target_data.increment <- read_increment("target_table")

# use increment to load delta (new data since the last execution)
dt <- loadDataFunction(target_data.increment)

# pre-processes data and get (dt)
dt <- prepareDataFunction(dt)

target_data.new_increment <- max(dt$increment_integer_field)
target_data.records <- nrow(dt)

# save new increment for the next delta load
log_load(
  destination = "target_table",
  records = target_data.records, 
  increment = target_data.new_increment
)
end_job()
```

## Testing

To test the package locally:

* Install and start influx - `brew install influxdb`
* Set environment variables in `.Renviron` file to:

```bash
INFLUX_HOST=localhost
INFLUX_USERNAME=user
INFLUX_PASSWORD=pass
INFLUX_DB=metadata
```
* Run tests. If `metadata` database is missing, it will be created by the tests.
