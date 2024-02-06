# long polling for R plumber

library(plumber)

#* @apiTitle Long Polling with Plumber

#* Long polling endpoint
#* @get /long_poll
function(req) {
  # Track active connections
  active_connections <<- list()

  # Generate a unique connection ID
  conn_id <- uuid::UUIDgenerate()

  # Store the connection in a list
  active_connections[[conn_id]] <<- req$socket

  # Function to check for updates and respond
  check_for_updates <- function() {
    # Simulate a long-running task
    Sys.sleep(5)  # Replace with your actual task

    # Check if the connection is still active
    if (!is.null(active_connections[[conn_id]])) {
      # Generate a response (replace with your actual data)
      response <- list(message = "Update available!", data = rnorm(10))
      # Send the response and close the connection
      tryCatch(
        plumber::sendResponse(response, req$socket),
        error = function(e) {
          # Handle errors gracefully (e.g., remove connection from list)
          active_connections[[conn_id]] <<- NULL
        }
      )
    }
  }

  # Start a background process for checking updates
  future::future(check_for_updates)

  # Return a placeholder response to keep the connection open
  return("Waiting for updates...")
}
