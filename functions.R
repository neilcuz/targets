clean_a <- function (a_raw) {
  
  a_raw |> 
    filter(!is.na(sales)) |> 
    mutate(store = str_to_sentence(store))
  
}

clean_b <- function (b_raw) {
  
  b_raw |> 
    mutate(region = str_to_sentence(region))
  
}

join_ab <- function (a_clean, b_clean) {
  
  left_join(a_clean, b_clean, by = "store") |> 
    select(region, store, sales, years_open)
  
}

quality_checks <- function (ab) {
  
  min_sales <- ab |> 
    pull(sales) |> 
    min()
  
  if (min_sales < 0) {
    
    message ("QA CHECK: Error in sales")
    
  }
  
  message ("QA Check: Sales ok")
  
  return (ab)
  
}

summarise_ab <- function (ab) {
  
  ab |> 
    group_by(region) |> 
    summarise(mean_sales = mean(sales)) |> 
    arrange(mean_sales)
  
}
  






