BB_HISTO_ITEM <- function(data,categ, title_name = "") {

plot_ly(x = data$ITEM_OH_Q , type = 'histogram' , color = as.factor(categ)) %>%
  layout(title = sprintf('BATCH BURN BY %s', title_name) )
}

#test
#BB_HISTO_ITEM(Burn_data,Burn_data$BKRM_LGRP_C, "BKRM_LGRP_C")
