view: install_overall {
  derived_table: {
    sql: SELECT
      DATE(submission_timestamp) AS submission_date,
      normalized_country_code,
      COUNTIF(had_old_install = true) AS paveovers,
      COUNTIF(had_old_install = false) AS new_installs
    FROM mozdata.firefox_installer.install
    WHERE
      DATE(submission_timestamp) > date(2020, 7 ,1) AND
      succeeded AND
      (silent = FALSE OR silent IS NULL) AND
      build_channel = "release" AND
      DATE_DIFF(  -- Only use builds from the last month
          DATE(submission_timestamp),
          SAFE.PARSE_DATE('%Y%m%d', SUBSTR(build_id, 0, 8)),
          MONTH
      ) <= 1 AND
      attribution IN ("chrome", "ie", "edge")
    GROUP BY
      submission_date,
      normalized_country_code;;
  }

  dimension: submission_date {
    type: date
    sql: ${TABLE}.submission_date ;;
  }

  dimension: normalized_country_code {
    type: string
    sql: ${TABLE}.normalized_country_code ;;
  }

  dimension: paveovers {
    type: number
    sql: ${TABLE}.paveovers ;;
  }

  dimension: new_installs {
    type: number
    sql: ${TABLE}.new_installs ;;
  }
}
