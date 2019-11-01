# Installing and using from Binaries

# R home directory - in miniconda
/home_dir/FREDO/.anaconda/lib/R/library/
# EPEL  
curlhttp://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/r/R-3.5.0-1.el7.x86_64.rpm -o R3.5.0.rpm 
mv R3.5.0.rpm  $HOME/R/
sudo yum install R
# Binaries
curl https://cran.r-project.org/src/base/R-3/R-3.5.1.tar.gz -o R3.5.0.tar.gz
mv R3.5.0.tar.gz  $HOME/R/
tar -zxf R3.5.0.tar.gz
  
