##----CREATE THE DISTRICT CLUSTERS----

#---- Libraries ----
library(tidyverse)
library(random)

#---- Build the Distant Matrix----
DISTR_DIST <- dist(DISTR_METRICS_SCALED, method = "euclidian")

# Kmeans
set.seed(17)
kmeans_output <- tribble(
  ~k, ~w_b_ratio, ~tot.withiness, ~withinss, ~between_ss, ~total_SS, ~b_tot_ratio,
  0,0,0,0,0,0,0
)

kmeans_loop <- function(df, k){
  
  for (i in 1:k) {
    set.seed(17)
    kmeans_results <- kmeans(df, i, nstart = 50)
    w_b_ratio <- kmeans_results$tot.withinss / kmeans_results$betweenss
    b_tot_ratio <- kmeans_results$betweenss / kmeans_results$totss
    kmeans_output[i,"k"] <- i
    kmeans_output[i,"w_b_ratio"] <- as.numeric(w_b_ratio) * 100
    kmeans_output[i,"b_tot_ratio"] <- as.numeric(b_tot_ratio) * 100
    kmeans_output[i,"withinss"] <- as.numeric(kmeans_results$withinss[i])
    kmeans_output[i,"tot.withiness"] <- as.numeric(kmeans_results$tot.withinss)
    kmeans_output[i,"between_ss"] <- as.numeric(kmeans_results$betweenss)
    kmeans_output[i,"total_SS"] <- as.numeric(kmeans_results$totss)
    print(sprintf("Kmeans for %s clusters completed",i))
  } 
  return(kmeans_output)
}

kmeans_output <- kmeans_loop(df = DISTR_DIST, k = 20)
kmeans_output

ggplot(kmeans_output[-1,], aes( x = k , y = w_b_ratio)) +
  geom_line() +
  geom_point(col = "red")

# Optimal k selected

K_CLUST <- kmeans(DISTR_METRICS_SCALED, centers = 10, nstart = 50)

DISTR_METRICS_CLUSTERED <- cbind(K_CLUST$cluster, DISTR_METRICS) %>% rename(CLUSTERS = `K_CLUST$cluster`)

cluster_flag <- DISTR_METRICS_CLUSTERED %>% filter(CLUSTERS == 7)

ggplot(DISTR_METRICS_CLUSTERED, aes(x = Pop_perc_sqmi_1, y = Pop_perc_sqmi_3, color = factor(CLUSTERS))) +
  geom_point() +
  geom_point(data = cluster_flag, aes(x = Pop_perc_sqmi_1, y = Pop_perc_sqmi_3, size = 2))

-----
-----

# Optimal K Code

        kmeans_output <- kmeans_loop(df = getShtgData(), k = 15)
  
        kmeans_output$b_change <- kmeans_output$w_b_ratio - lag(kmeans_output$w_b_ratio)
        kmeans_output$b_change2 <- kmeans_output$b_change - lag(kmeans_output$b_change)
        kmeans_output$b_change_sum <- abs(kmeans_output$b_change + kmeans_output$b_change2)
  
        return(kmeans_output)
    }) 


    # SELECT THE OPTIMAL K FOR CLUSTERING
    optimal <- reactive({kmeans_go() %>% filter(!is.na(b_change_sum)) %>% mutate(rate_rank = rank(- b_change_sum)) %>%
        filter(!rate_rank == 1) %>% mutate(rate_rank = rank(- b_change_sum)) %>% filter(rate_rank == 1)
      
    })
    
    # GRAPH THE ITERATION OF K MEANS
    kmeans_graph <- reactive({
      ggplot(kmeans_go()[-1,], aes( x = k , y = w_b_ratio)) +
        geom_line() +
        geom_point(col = "red") +
        geom_point(data = optimal(), aes(x = k, y=w_b_ratio) , size = 10)
    }) 
    # END OF OPTIMAL K SELECTION AND GRAPH


