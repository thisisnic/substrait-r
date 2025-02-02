
test_that("duckdb_substrait_compiler() works", {
  skip_if_not(has_duckdb_with_substrait())

  df <- data.frame(a = 1, b = "two", stringsAsFactors = FALSE)
  compiler <- duckdb_substrait_compiler(df)

  expect_s3_class(compiler, "DuckDBSubstraitCompiler")
  result <- as.data.frame(compiler$evaluate())
  expect_identical(as.data.frame(result), df)
})

test_that("duckdb translation for == and != works", {
  skip_if_not(has_duckdb_with_substrait())
  tbl <- tibble::tibble(col = c(1, 2, NA))

  expect_identical(
     tbl %>%
      duckdb_substrait_compiler() %>%
      dplyr::transmute(eq2 = col == 2, neq2 = col != 2) %>%
      dplyr::collect(),
    tibble::tibble(
      eq2 = c(FALSE, TRUE, NA),
      neq2 = c(TRUE, FALSE, NA)
    )
  )
})

test_that("duckdb translation for & and |", {
  skip_if_not(has_duckdb_with_substrait())
  tbl <- tibble::tibble(col = c(TRUE, FALSE, NA))

  expect_identical(
    tbl %>%
      duckdb_substrait_compiler() %>%
      dplyr::transmute(
        and_true = col & TRUE,
        and_false = col & FALSE,
        or_true = col | TRUE,
        or_false = col | FALSE
      ) %>%
      dplyr::collect(),
    tibble::tibble(
      and_true = c(TRUE, FALSE, NA),
      and_false = c(FALSE, FALSE, FALSE),
      or_true = c(TRUE, TRUE, TRUE),
      or_false = c(TRUE, FALSE, NA)
    )
  )
})

test_that("duckdb translation for ! works", {
  skip_if_not(has_duckdb_with_substrait())

  tbl <- tibble::tibble(col = c(TRUE, FALSE))
  expect_identical(
    tbl %>%
      duckdb_substrait_compiler() %>%
      dplyr::transmute(
        not = !col
      ) %>%
      dplyr::collect(),
    tibble::tibble(
      not = c(FALSE, TRUE)
    )
  )
})

test_that("duckdb translation for ! handles NULL", {
  skip_if_not(has_duckdb_with_substrait())
  skip("duckdb translation for ! doesn't handle NULLs")

  tbl <- tibble::tibble(col = c(TRUE, FALSE, NA))
  expect_identical(
    tbl %>%
      duckdb_substrait_compiler() %>%
      dplyr::transmute(
        not = !col
      ) %>%
      dplyr::collect(),
    tibble::tibble(
      not = c(FALSE, TRUE, NA)
    )
  )
})

test_that("duckdb translation for comparisons works", {
  skip_if_not(has_duckdb_with_substrait())
  tbl <- tibble::tibble(col = c(0, 1, 2, 3, NA))

  expect_identical(
    tbl %>%
      duckdb_substrait_compiler() %>%
      dplyr::transmute(
        gt2 = col > 2,
        gte2 = col >= 2,
        lt2 = col < 2,
        lte2 = col <= 2,
        between_12 = dplyr::between(col, 1, 2)
      ) %>%
      dplyr::collect(),
    tibble::tibble(
      gt2 = c(FALSE, FALSE, FALSE, TRUE, NA),
      gte2 = c(FALSE, FALSE, TRUE, TRUE, NA),
      lt2 = c(TRUE, TRUE, FALSE, FALSE, NA),
      lte2 = c(TRUE, TRUE, TRUE, FALSE, NA),
      between_12 = c(FALSE, TRUE, TRUE, FALSE, NA)
    )
  )
})

test_that("duckdb translation for arithmetic functions works", {
  skip_if_not(has_duckdb_with_substrait())
  tbl <- tibble::tibble(col = c(1, 2, NA))

  expect_identical(
    tbl %>%
      duckdb_substrait_compiler() %>%
      dplyr::transmute(
        times2 = col * 2,
        div2 = col / 2,
        add2 = col + 2,
        sub2 = col - 2,
        pow2 = col ^ 2
      ) %>%
      dplyr::collect(),
    tibble::tibble(
      times2 = c(2, 4, NA),
      div2 = c(1 / 2, 2 / 2, NA),
      add2 = c(1 + 2, 2 + 2, NA),
      sub2 = c(1 - 2, 2 - 2, NA),
      pow2 = c(1 ^ 2, 2 ^ 2, NA)
    )
  )
})

test_that("duckdb translation for is.na() works", {
  skip_if_not(has_duckdb_with_substrait())

  expect_identical(
    tibble::tibble(col = c(1, 2, NA)) %>%
      duckdb_substrait_compiler() %>%
      dplyr::filter(is.na(col)) %>%
      dplyr::collect(),
    tibble::tibble(col = NA_real_)
  )
})

test_that("duckdb can roundtrip a substrait plan", {
  skip_if_not(has_duckdb_with_substrait())

  plan <- duckdb_get_substrait(
    "SELECT * from mtcars",
    tables = list(mtcars = mtcars)
  )

  # not sure why the table name doesn't come through here
  plan <- rel_tree_modify(plan, "substrait_ReadRel_NamedTable", function(x) {
    x$names <- "mtcars"
    x
  })

  expect_equal(
    duckdb_from_substrait(plan, tables = list(mtcars = mtcars)),
    mtcars,
    ignore_attr = TRUE
  )
})

test_that("blob encoder works", {
  expect_identical(
    duckdb_encode_blob(as.raw(1:5)),
    "'\\x01\\x02\\x03\\x04\\x05'::BLOB"
  )

  skip_if_not(has_duckdb_with_substrait())
  tbl <- query_duckdb_with_substrait(
    paste0("SELECT ", duckdb_encode_blob(as.raw(1:5)), " as col")
  )
  expect_identical(tbl$col[[1]], as.raw(1:5))
})
