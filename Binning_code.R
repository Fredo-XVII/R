
df$MAPE_BINS <- factor(if_else(df$MAPE_CON_0_1_F_EDS == 1,
                                         as.character(as.character(cut(df$FX_ERROR_MAPE_CON_EDS, breaks = seq(0,1, by = 0.1), include.lowest = TRUE, ordered_result = TRUE))),
                                         as.character(as.character(cut(df$FX_ERROR_MAPE_CON_EDS, breaks = seq(1,200, by = 5), include.lowest = FALSE, ordered_result = TRUE)))
                                         ),
                                      ordered = TRUE
                                  )
