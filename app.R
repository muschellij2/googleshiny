library(shiny)
library(googleAuthR)
opts = list()

# had to have localhost and 127.0.0.1 enabled
# both http and https
hn = system2("hostname", stdout = TRUE)
local = grepl("macbook", hn)
if (local) {
  port = 1221
  opts$port = port
  options(googleAuthR.redirect = paste0("http://localhost:", port))
}
# options(googleAuthR.redirect = "https://jhubiostatistics.shinyapps.io/googleshiny/")
gar_set_client(
  json = "RClass-GoogleDrive.json",
  web_json = "RClass-GoogleDrive-web.json",
  scopes = "https://www.googleapis.com/auth/drive")

fileSearch <- function(query) {
  gar_api_generator("https://www.googleapis.com/drive/v3/files/",
                    "GET",
                    pars_args=list(q=query),
                    data_parse_function = function(x) x$files)()
}

## ui.R
ui <- fluidPage(title = "googleAuthR Shiny Demo",
                textInput("query", 
                          label = "Google Drive query", 
                          value = "mimeType != 'application/vnd.google-apps.folder'"),
                tableOutput("gdrive")
)

## server.R
server <- function(input, output, session){
  
  # create a non-reactive access_token as we should never get past this if not authenticated
  gar_shiny_auth(session)
  
  
  output$gdrive <- renderTable({
    req(input$query)
    
    # no need for with_shiny()
    fileSearch(input$query)
    
  })
}

shinyApp(gar_shiny_ui(ui, login_ui = gar_shiny_login_ui), 
         server,
         options = opts
)
