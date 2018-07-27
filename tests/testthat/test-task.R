context("model")

describe("log_model_performance()", {
  it("Creates task record in the meta database correlated to the current job through id", {
    skip_on_travis()
    id <- start_job("test_pipeline")
    log_model_performance(
      dataset = "sessions",
      target = "conversion",
      test = TRUE,
      algorithm = "RandomForest",
      metric = "R-Squared",
      group = "all",
      records = 1000,
      value = 0.5
    )

    performance <- influxdbr::influx_query(
      con = influxConnection(),
      db = influxDatabase(),
      query = paste0("SELECT * FROM model WHERE id = '", id, "'"),
      return_xts = FALSE,
      simplifyList = TRUE
    )
    performance <- performance[[1]]
    expect_equal(performance$records, c(1000))
    expect_equal(performance$value, c(0.5))
    end_job()
  })
})
