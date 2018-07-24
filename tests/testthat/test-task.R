context("task")

describe("log_load()", {
  it("Creates task record in the meat database correlated to the current job through id", {
    skip_on_travis()
    id <- start_job("test_pipeline")
    log_load("test_dataset", 100, 1001)
    log_load("test_dataset", 100, 1101)

    tasks <- influxdbr::influx_query(
      con = influxConnection(),
      db = influxDatabase(),
      query = paste0("SELECT * FROM task WHERE id = '", id, "'"),
      return_xts = FALSE,
      simplifyList = TRUE
    )
    tasks <- tasks[[1]]
    expect_equal(tasks$records, c(100, 100))
    expect_equal(tasks$increment, c(1001, 1101))
    end_job()
  })
})

describe("read_increment", {
  it("Gets last increment value for a given destination within job execution", {
    skip_on_travis()
    start_job("test_pipeline")
    expect_equal(read_increment("test_dataset"), 1101)
    end_job()
  })
  it("Gets zero as increment value for destination without previous loads", {
    start_job("test_pipeline")
    expect_equal(read_increment("test_dataset_new"), 0)
    end_job()
  })
})
