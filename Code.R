# This code automates the process of finding your updated module description and module facilitator. NUSmods only has a brief module description. 
## Run this in R, ensure have Rselenium and tidyverse installed
# adjust Sys.sleep accordingly. 
# Note this only functions as giving you a glance with brief 15 seconds to scroll through the module description page, 
# thereafter it will cycle to the next module you've input

################
library(RSelenium)
library(tidyverse)

eCaps <- list(chromeOptions = list(args = c('--disable-infobars', '--start-maximized')))
driver <- RSelenium::rsDriver(browser = "chrome",
                              chromever =
                                system2(command = "wmic",
                                        args = 'datafile where name="C:\\\\Program Files (x86)\\\\Google\\\\Chrome\\\\Application\\\\chrome.exe" get Version /value',
                                        stdout = TRUE,
                                        stderr = TRUE) %>%
                                stringr::str_extract(pattern = "(?<=Version=)\\d+\\.\\d+\\.\\d+\\.") %>%
                                magrittr::extract(!is.na(.)) %>%
                                stringr::str_replace_all(pattern = "\\.",
                                                         replacement = "\\\\.") %>%
                                paste0("^",  .) %>%
                                stringr::str_subset(string =
                                                      binman::list_versions(appname = "chromedriver") %>%
                                                      dplyr::last()) %>%
                                as.numeric_version() %>%
                                max() %>%
                                as.character(),
                              extraCapabilities = eCaps)

remote_driver <- driver[["client"]] 
remote_driver$navigate("https://luminus.nus.edu.sg/module-search")

module <- function(module_input) {
  
  moduleTextBox <- remote_driver$findElement("xpath", "/html/body/main/ng-component/div[2]/ng-component/aside/form/div[1]/input")
  
  moduleTextBox$clickElement()
  Sys.sleep(3)
  moduleTextBox$sendKeysToElement(list(module_input))
  
  Sys.sleep(2)
  
  button_element <- remote_driver$findElement("xpath", "/html/body/main/ng-component/div[2]/ng-component/aside/form/div[1]/button")
  button_element$clickElement()
  
  Sys.sleep(3)
  
  moduleTitle <- remote_driver$findElement("class", "module-title")
  moduleTitle$clickElement()
  
  Sys.sleep(3)
  
  
  moduleDescription <- remote_driver$findElement("link text","Module Description")
  moduleDescription$clickElement()
  
  Sys.sleep(15)
 ## remote_driver$screenshot(display = TRUE) # note very helpful, still figuring out how to print pdf
  
  reset_button <- remote_driver$findElement("xpath", "/html/body/main/ng-component/div[2]/ng-component/aside/a[2]")
  
  reset_button$clickElement()
  Sys.sleep(2)
  
  }




## Example: searching module code for PL4221. Please type in the entire module code as Rselenium will only take the first result. 
## eg module("PL4221")

## if you want to cycle through more modules, edit this instead
module_input <- c("PL4221", "PL4880T", "PL4880R")

## creating loop for the above vector
for (i in 1:length(module_input)) {
  
  module(module_input[i])
  
}


system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE) ## With help from dtyk