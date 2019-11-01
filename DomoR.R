install.packages("devtools")
library("devtools")
has_devel() # check to make sure devtools is working

install_github(repo="domoinc-r/DomoR") # ignore this part of the code -> , auth_token="")
library(DomoR)
DomoR::init('CompanyName.domo.com' , token = 'Your Domo API Key' ) # API Key from Domo HipChat
DomoR::list_ds() # list the datasets available for you to download

# for more help go to the DomoR package in your packages, help() is not useful in this case.
-----

# DOMO CONNECTION ON LAN/HQ-WIRELESS (NOT TMHS)

-----
# NOTE: Steps 1 & 2 Only need to be completed once.
# NOTE: Steps 3 - 5 are need every time you connect to DOMO
-----

# Step 1 Download CA BUNDLE
# Step 2 Place Certificate into Generic Folder or RCurl folder in your current R library 

# Step 3 create the path to the certificate for referencing 
### Generic Folder for CA Certificate:
gen_folder <- gsub( '\\\\',"/" , file.path("C:\\Apps\\R", "CAbundle.crt" ) )

#### For Mac just do this:
file.path("/Users/z084105/Target_Cert", "ca-bundle.crt" )

### RCurl Folder for CA Certificate:
rcurl_folder <- system.file("CurlSSL", "ca-bundle.crt" , package = "RCurl")

# Step 4 Tell R where the certificate is located, save in environmental variable CURL_CA_BUNDLE
Sys.setenv(CURL_CA_BUNDLE= gen_folder )
Sys.getenv("CURL_CA_BUNDLE") # checks to ensure the file path is correct, not needed to connect

# Step 5 Connect to Domo. DOMO_KEY is an environmental variable for my key. You can place your key in quotes, token = 'DOMO KEY'
library(DomoR)
DomoR::init('target.domo.com' , token = 'DOMO TOKEN') # if you use environmental variable use: Sys.getenv("DOMO_KEY")
DomoR::list_ds()  # test connection. Will give you a list of tables you have access to.

# To learn what functions are available in DomoR
# Type < ?DomoR > in the Console, or go to packages in Rstudio and search Domo

## Error handling
 - if error, try close down RStudio, then install.packages(c("curl","httr"))
