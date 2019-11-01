library(ssh)

br_ssh <- ssh_connect("knox.hadoop.co.com")

ssh_info(br_ssh)


command <- 'source $HOME/.pyspark_jupyter_profile && pyspark && exit'

run_spark <- '/usr/.../bin/Rscript $HOME/.../file.R'

ssh_exec_wait(br_ssh, 
              command = run_spark)

