context("job")

describe("job_start()", {
  it("Creates excecution start record in the meta database", {
    skip_on_travis()
    start_job("test")
    expect_true(is_set_job())
    end_job()
  })
  it("Errors if called second time before end_job", {
    skip_on_travis()
    start_job("test")
    expect_error(start_job("test"))
    end_job()
  })
})

describe("job_error()", {
  it("Creates execution error record in the meta database and resets the job", {
    skip_on_travis()
    start_job("test")
    error_job()
    expect_false(is_set_job())
  })
})
