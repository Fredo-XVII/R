# for server web interface

# This is to ensure that commands are starting
# in that home directory before continuing
cd ~

# This will download the latest version of Miniconda3
# and save it locally as Miniconda.sh
curl https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o Miniconda.sh

# This will install Miniconda to $HOME/.anaconda
bash Miniconda.sh -b -p $HOME/.anaconda

# Finally, let's cleanup after the installation
rm Miniconda.sh

# Conda is located at $HOME/.anaconda/bin/conda
# This will install Jupyter-Notebook and -y will have it skip prompts.
$HOME/.anaconda/bin/conda install -y jupyter

## Now you can connect to jupyter with this command but no spark is available
$HOME/.anaconda/bin/jupyter notebook --no-browser --ip='*' --port=5432

# Install one package with this command
$HOME/.anaconda/bin/conda install -y jupyter

# Installing multiple packages can be done by specifying them all at the end of the command.
$HOME/.anaconda/bin/conda install -y pandas numpy scipy scikit-learn nltk matplotlib

# Jupyter-Notebook also has an R Kernel which can be installed with the following
$HOME/.anaconda/bin/conda install -y -c r r-essentials

# create env files - $HOME/.pyspark_jupyter_profile
export PYSPARK_PYTHON="$HOME/.anaconda/bin/python"
export PYSPARK_DRIVER_PYTHON="$HOME/.anaconda/bin/jupyter"
export PYSPARK_DRIVER_PYTHON_OPTS="notebook --no-browser --port=<port_number> --ip='*'"
**NOTE: Ensure the <port_number> above is replaced with a number between 5,000 and 65,000. The port which Jupyter-Notebook needs to not collide with another port already being used by the machine and by having the end user pick the number, it is less likely to conflict.**

# Starting JuptR - GitBash
## not 
source $HOME/.pyspark_jupyter_profile && pyspark-2.3logged in 
ssh -tL <port_number>:localhost:<port_number> ID@edge.co.com 'source $HOME/.pyspark_jupyter_profile && pyspark'

## logged in 
## no Spark
$HOME/.anaconda/bin/jupyter notebook --no-browser --ip='*' --port=<PORT NUMBER>
## w/ Spark
source $HOME/.pyspark_jupyter_profile && pyspark
source $HOME/.pyspark_jupyter_profile && pyspark-2.3

# Putty
## Remote command: SSH -> source $HOME/.pyspark_jupyter_profile && pyspark

## if failing
source $HOME/.pyspark_jupyter_profile && pyspark --conf spark.port.maxRetries=100
## Specific version
source $HOME/.pyspark_jupyter_profile && pyspark-2.3


