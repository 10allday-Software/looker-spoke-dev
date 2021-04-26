  label: "Numbers that Matter"

connection: "telemetry"

include: "views/*.view.lkml"
include: "dashboards/*.dashboard"

explore: country_buckets {
  hidden: yes
}

explore: releases {
  always_filter: {
    filters: [
      releases.category: "major"
    ]
  }
}

explore: install  {
  sql_always_where: ${submission_timestamp_date} > date(2020, 7 ,1) AND
    ${succeeded} AND
    (${silent} = FALSE OR ${silent} IS NULL) AND
    ${build_channel} = "release" AND
    DATE_DIFF(  -- Only use builds from the last month
        ${submission_timestamp_date},
        SAFE.PARSE_DATE('%Y%m%d', SUBSTR(${build_id}, 0, 8)),
        MONTH
    ) <= 1 AND
    ${attribution} IN ("chrome", "ie", "edge") AND
    ${period_date} <= IF({% parameter install.previous_time_period %}, DATE(DATE_ADD(DATE({% date_end install.date %}), INTERVAL DATE_DIFF(DATE({% date_start install.date %}), DATE({% date_end install.date %}), DAY) DAY)), DATE({% date_end install.date %})) AND
    ${period_date} >= IF({% parameter install.previous_time_period %}, DATE(DATE_ADD(DATE({% date_start install.date %}), INTERVAL DATE_DIFF(DATE({% date_start install.date %}), DATE({% date_end install.date %}), DAY) DAY)), DATE({% date_start install.date %}));;
  join: country_buckets {
    type: cross
    relationship: many_to_one
    sql_where: ${country_buckets.code} = ${install.normalized_country_code} ;;
  }
}

explore: new_profile {
  view_name: new_profile
  sql_always_where: ${submission_timestamp_date} > date(2020, 7 ,1) AND
    ${channel} = "release" AND
    DATE_DIFF(  -- Only use builds from the last month
      ${submission_timestamp_date},
      SAFE.PARSE_DATE('%Y%m%d', SUBSTR(${build_id}, 0, 8)),
      MONTH
    ) <= 1 AND
    ${os} = "Windows" AND
    ${attribution_source} IS NOT NULL AND
    ${distribution_id} IS NULL AND
    ${attribution_ua} != "firefox" AND
    ${startup_profile_selection_reason} = "firstrun-created-default";;
  join: country_buckets {
    type: cross
    relationship: many_to_one
    sql_where: ${country_buckets.code} = ${new_profile.normalized_country_code} ;;
  }
}

explore: session {
  sql_always_where: ${operating_system} = "Windows" and ${browser} != "Mozilla" ;;
  join: country_buckets {
    type: cross
    relationship: many_to_one
    sql_where: (
      (${session.standardized_country_name} = "USA" AND ${country_buckets.code} = "US") OR
      (${country_buckets.code} = "GB" AND ${session.standardized_country_name} = "United Kingdom") OR
      (${country_buckets.code} = "DE" AND ${session.standardized_country_name} = "Germany") OR
      (${country_buckets.code} = "FR" AND ${session.standardized_country_name} = "France") OR
      (${country_buckets.code} = "CA" AND ${session.standardized_country_name} = "Canada") OR
      (${country_buckets.code} = "BR" AND ${session.standardized_country_name} = "Brazil") OR
      (${country_buckets.code} = "MX" AND ${session.standardized_country_name} = "Mexico") OR
      (${country_buckets.code} = "CN" AND ${session.standardized_country_name} = "China") OR
      (${session.standardized_country_name} NOT IN ("USA", "Germany", "United Kingdom", "France", "Canada", "Mexico", "China", "Brazil") AND ${country_buckets.bucket} IN ("non-tier-1", "Overall") AND ${country_buckets.code} = "OTHER" ));;
  }
}

explore: activation {
  sql_always_where: ${submission_timestamp_date} > date(2020, 7 ,1) AND
    ${channel} = "release" AND
    DATE_DIFF(  -- Only use builds from the last month
      ${submission_timestamp_date},
      SAFE.PARSE_DATE('%Y%m%d', SUBSTR(${build_id}, 0, 8)),
      MONTH
    ) <= 1 AND
    ${os} = "Windows" AND
    ${attribution_source} IS NOT NULL AND
    ${distribution_id} IS NULL AND
    ${attribution_ua} != "firefox" AND
    ${startup_profile_selection_reason} = "firstrun-created-default";;
  join: country_buckets {
    type: cross
    relationship: many_to_one
    sql_where: ${country_buckets.code} = ${activation.normalized_country_code} ;;
  }
}
