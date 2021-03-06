
# Add Tip Column, Same dplyr Syntax ---------------------------------------

sample_taxi <-  mutate(taxi, tip_pct = tip_amount/fare_amount)


# Create summary functions ------------------------------------------------

taxi_hood_sum <- function(taxi_data = taxi_df, ...) {
  
  load(url("http://alizaidi.blob.core.windows.net/training/manhattan.RData"))
  
  taxi_data %>% 
    filter(pickup_nhood %in% manhattan_hoods,
           dropoff_nhood %in% manhattan_hoods, ...) %>% 
    group_by(dropoff_nhood, pickup_nhood) %>% 
    summarize(ave_tip = mean(tip_pct), 
              ave_dist = mean(trip_distance)) %>% 
    filter(ave_dist > 3, ave_tip > 0.05) -> sum_df
  
  return(sum_df)
  
}



# Create Plot Function ----------------------------------------------------


tile_plot_hood <- function(df = taxi_hood_sum()) {
  
  library(ggplot2)
  
  ggplot(data = df, aes(x = pickup_nhood, y = dropoff_nhood)) + 
    geom_tile(aes(fill = ave_tip), colour = "white") + 
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          legend.position = 'bottom') +
    scale_fill_gradient(low = "white", high = "steelblue") -> gplot
  
  return(gplot)
}


# Calculate Summary, Collect Results, Plot... Profit ----------------------


taxi_summary <- taxi_hood_sum(sample_taxi)
taxi_df <- taxi_summary %>% collect
tile_plot_hood(taxi_df)

library(plotly)
ggplotly(tile_plot_hood(taxi_df))
