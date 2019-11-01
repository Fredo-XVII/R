---
title: "TITLE"
author: Alfredo.G.Marquez@gmail.com
date: November/December 2018
output: 
  github_document: default
  html_notebook: default
params:
  uid: 
    label: "User ID:"
    input: text
    placeholder: "Enter ZID"
    value: ""
  password: 
    label: "Password:"
    input: password
    placeholder: "Enter Password"
    value: ""
---

```{r setup, include=FALSE, message=FALSE}
library(odbc)
db_br_me = dbConnect(odbc::odbc(),
               'haddop',
               uid = params$uid,
               pwd = params$password)

knitr::opts_chunk$set(echo = TRUE)
knitr::opts_chunk$set(connection = "db_br_me")
```
