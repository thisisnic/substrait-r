library(dplyr, warn.conflicts = FALSE)
library(stringr)
skip_if_not(has_arrow_with_substrait())

test_that("filter() on is.na()", {
  skip("is.na() not implemented yet https://github.com/voltrondata/substrait-r/issues/72")
  compare_arrow_dplyr_binding(
    .input %>%
      filter(is.na(lgl)) %>%
      select(chr, int, lgl) %>%
      collect(),
    example_data
  )
})

test_that("filter() with NAs in selection", {
  compare_arrow_dplyr_binding(
    .input %>%
      filter(lgl) %>%
      select(chr, int, lgl) %>%
      collect(),
    example_data
  )
})

test_that("Filter should be able to return an empty table", {
  compare_arrow_dplyr_binding(
    .input %>%
      filter(false) %>%
      select(chr, int, lgl) %>%
      collect(),
    example_data
  )
})

test_that("filtering with expression", {
  skip("== not implemented yet: https://github.com/voltrondata/substrait-r/issues/73")
  char_sym <- "b"
  compare_arrow_dplyr_binding(
    .input %>%
      filter(chr == char_sym) %>%
      select(string = chr, int) %>%
      collect(),
    example_data
  )
})

test_that("filtering with arithmetic", {

  skip("arithmetic functions not yet implemented: https://github.com/voltrondata/substrait-r/issues/20")

  compare_arrow_dplyr_binding(
    .input %>%
      filter(dbl + 1 > 3) %>%
      select(string = chr, int, dbl) %>%
      collect(),
    example_data
  )

  compare_arrow_dplyr_binding(
    .input %>%
      filter(dbl / 2 > 3) %>%
      select(string = chr, int, dbl) %>%
      collect(),
    example_data
  )

  compare_arrow_dplyr_binding(
    .input %>%
      filter(dbl / 2L > 3) %>%
      select(string = chr, int, dbl) %>%
      collect(),
    example_data
  )

  compare_arrow_dplyr_binding(
    .input %>%
      filter(int / 2 > 3) %>%
      select(string = chr, int, dbl) %>%
      collect(),
    example_data
  )

  compare_arrow_dplyr_binding(
    .input %>%
      filter(int / 2L > 3) %>%
      select(string = chr, int, dbl) %>%
      collect(),
    example_data
  )

  compare_arrow_dplyr_binding(
    .input %>%
      filter(dbl %/% 2 > 3) %>%
      select(string = chr, int, dbl) %>%
      collect(),
    example_data
  )

  compare_arrow_dplyr_binding(
    .input %>%
      filter(dbl^2 > 3) %>%
      select(string = chr, int, dbl) %>%
      collect(),
    example_data
  )
})

test_that("filtering with expression + autocasting", {

  skip("arithmetic functions not yet implemented: https://github.com/voltrondata/substrait-r/issues/20")

  compare_arrow_dplyr_binding(
    .input %>%
      filter(dbl + 1 > 3L) %>% # test autocasting with comparison to 3L
      select(string = chr, int, dbl) %>%
      collect(),
    example_data
  )

  compare_arrow_dplyr_binding(
    .input %>%
      filter(int + 1 > 3) %>%
      select(string = chr, int, dbl) %>%
      collect(),
    example_data
  )

  compare_arrow_dplyr_binding(
    .input %>%
      filter(int^2 > 3) %>%
      select(string = chr, int, dbl) %>%
      collect(),
    example_data
  )
})

test_that("More complex select/filter", {
  skip("== not yet implemented: https://github.com/voltrondata/substrait-r/issues/73")
  compare_arrow_dplyr_binding(
    .input %>%
      filter(dbl > 2, chr == "d" | chr == "f") %>%
      select(chr, int, lgl) %>%
      filter(int < 5) %>%
      select(int, chr) %>%
      collect(),
    example_data
  )
})

test_that("filter() with %in%", {
  skip("%in% not yet implemented: https://github.com/voltrondata/substrait-r/issues/74")
  compare_arrow_dplyr_binding(
    .input %>%
      filter(dbl > 2, chr %in% c("d", "f")) %>%
      collect(),
    example_data
  )
})

test_that("Negative scalar values", {
  skip("arithmetic functions not yet implemented: https://github.com/voltrondata/substrait-r/issues/20")
  compare_arrow_dplyr_binding(
    .input %>%
      filter(some_negative > -2) %>%
      collect(),
    example_data
  )
  compare_arrow_dplyr_binding(
    .input %>%
      filter(some_negative %in% -1) %>%
      collect(),
    example_data
  )
  compare_arrow_dplyr_binding(
    .input %>%
      filter(int == -some_negative) %>%
      collect(),
    example_data
  )
})

test_that("filter() with between()", {

  skip("between not yet implemented: https://github.com/voltrondata/substrait-r/issues/75")

  compare_arrow_dplyr_binding(
    .input %>%
      filter(between(dbl, 1, 2)) %>%
      collect(),
    example_data
  )

  compare_arrow_dplyr_binding(
    .input %>%
      filter(between(dbl, 0.5, 2)) %>%
      collect(),
    example_data
  )

  expect_identical(
    example_data %>%
      arrow_substrait_compiler() %>%
      filter(between(dbl, int, dbl2)) %>%
      collect(),
    example_data %>%
      filter(dbl >= int, dbl <= dbl2)
  )

  expect_error(
    example_data %>%
      arrow_substrait_compiler() %>%
      filter(between(dbl, 1, "2")) %>%
      collect()
  )

  expect_error(
    example_data %>%
      arrow_substrait_compiler() %>%
      filter(between(dbl, 1, NA)) %>%
      collect()
  )

  expect_error(
    example_data %>%
      arrow_substrait_compiler() %>%
      filter(between(chr, 1, 2)) %>%
      collect()
  )
})

test_that("filter() with string ops", {
  # skip_if_not_available("utf8proc")
  skip("string functions not yet implemented: https://github.com/voltrondata/substrait-r/issues/18")
  compare_arrow_dplyr_binding(
    .input %>%
      filter(dbl > 2, str_length(verses) > 25) %>%
      collect(),
    example_data
  )

  compare_arrow_dplyr_binding(
    .input %>%
      filter(dbl > 2, str_length(str_trim(padded_strings, "left")) > 5) %>%
      collect(),
    example_data
  )
})

test_that("filter environment scope", {
  skip("== not yet implemented: https://github.com/voltrondata/substrait-r/issues/73")
  # "object 'b_var' not found"
  compare_arrow_dplyr_error(.input %>% filter(chr == b_var), example_data)

  b_var <- "b"
  compare_arrow_dplyr_binding(
    .input %>%
      filter(chr == b_var) %>%
      collect(),
    example_data
  )
  # Also for functions
  # 'could not find function "isEqualTo"' because we haven't defined it yet
  skip("https://github.com/voltrondata/substrait-r/issues/76")
  compare_arrow_dplyr_error(.input %>% filter(isEqualTo(int, 4)), example_data)

  # This works but only because there are S3 methods for those operations
  isEqualTo <- function(x, y) x == y & !is.na(x)
  compare_arrow_dplyr_binding(
    .input %>%
      select(-lgl) %>% # factor levels aren't identical
      filter(isEqualTo(int, 4)) %>%
      collect(),
    example_data
  )
  # Try something that needs to call another nse_func
  compare_arrow_dplyr_binding(
    .input %>%
      select(-lgl) %>%
      filter(nchar(padded_strings) < 10) %>%
      collect(),
    example_data
  )
  isShortString <- function(x) nchar(x) < 10
  skip("TODO: 14071")
  compare_arrow_dplyr_binding(
    .input %>%
      select(-lgl) %>%
      filter(isShortString(padded_strings)) %>%
      collect(),
    example_data
  )
})

test_that("Filtering on a column that doesn't exist errors correctly", {
  with_language("fr", {
    # expect_warning(., NA) because the usual behavior when it hits a filter
    # that it can't evaluate is to raise a warning, collect() to R, and retry
    # the filter. But we want this to error the first time because it's
    # a user error, not solvable by retrying in R
    expect_warning(
      expect_error(
        example_data %>% arrow_substrait_compiler() %>% filter(not_a_col == 42) %>% collect(),
        "objet 'not_a_col' introuvable"
      ),
      NA
    )
  })
  with_language("en", {
    expect_warning(
      expect_error(
        example_data %>% arrow_substrait_compiler() %>% filter(not_a_col == 42) %>% collect(),
        "object 'not_a_col' not found"
      ),
      NA
    )
  })
})

test_that("Filtering with unsupported functions", {
  skip("arithmetic functions not yet implemented: https://github.com/voltrondata/substrait-r/issues/20")
  compare_arrow_dplyr_binding(
    .input %>%
      filter(int > 2, pnorm(dbl) > .99) %>%
      collect(),
    example_data#,
    # this needs updating to refer to Substrait and not Arrow
    # warning = "Expression pnorm\\(dbl\\) > 0.99 not supported in Arrow; pulling data into R"
  )
  compare_arrow_dplyr_binding(
    .input %>%
      filter(
        nchar(chr, type = "bytes", allowNA = TRUE) == 1, # bad, Arrow msg
        int > 2, # good
        pnorm(dbl) > .99 # bad, opaque
      ) %>%
      collect(),
    example_data#,
#     warning = '\\* In nchar\\(chr, type = "bytes", allowNA = TRUE\\) == 1, allowNA = TRUE not supported in Arrow
# \\* Expression pnorm\\(dbl\\) > 0.99 not supported in Arrow
# pulling data into R'
  )
})

test_that("Calling Arrow compute functions 'directly'", {
  skip("can't call Arrow compute functions directly yet: https://github.com/voltrondata/substrait-r/issues/77")
  expect_equal(
    example_data %>%
      arrow_substrait_compiler() %>%
      filter(arrow_add(dbl, 1) > 3L) %>%
      select(string = chr, int, dbl) %>%
      collect(),
    example_data %>%
      filter(dbl + 1 > 3L) %>%
      select(string = chr, int, dbl)
  )

  compare_arrow_dplyr_binding(
    example_data %>%
      arrow_substrait_compiler() %>%
      filter(arrow_greater(arrow_add(dbl, 1), 3L)) %>%
      select(string = chr, int, dbl) %>%
      collect(),
    example_data %>%
      filter(dbl + 1 > 3L) %>%
      select(string = chr, int, dbl)
  )
})

test_that("filter() with .data pronoun", {
  skip("arithmetic functions not yet implemented: https://github.com/voltrondata/substrait-r/issues/20")
  compare_arrow_dplyr_binding(
    .input %>%
      filter(.data$dbl > 4) %>%
      select(.data$chr, .data$int, .data$lgl) %>%
      collect(),
    example_data
  )

  compare_arrow_dplyr_binding(
    .input %>%
      filter(is.na(.data$lgl)) %>%
      select(.data$chr, .data$int, .data$lgl) %>%
      collect(),
    example_data
  )

  # and the .env pronoun too!
  chr <- 4
  compare_arrow_dplyr_binding(
    .input %>%
      filter(.data$dbl > .env$chr) %>%
      select(.data$chr, .data$int, .data$lgl) %>%
      collect(),
    example_data
  )

  skip("test now faulty - code no longer gives error & outputs a empty tibble")
  # but there is an error if we don't override the masking with `.env`
  compare_arrow_dplyr_error(
    .input %>%
      filter(.data$dbl > chr) %>%
      select(.data$chr, .data$int, .data$lgl) %>%
      collect(),
    example_data
  )
})
