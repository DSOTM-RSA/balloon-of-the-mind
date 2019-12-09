# server side defintion

#load libraries
library(shiny)
library(DBI)
library(dplyr)
library(openssl)
library(parsedate)


# set database variables
db_name <- "postgres"
tbl_owner <- "owners"
tbl_issues <- "issues2"




# define functions

# create table to hold users 
create_owners_table <- function() {
    
    db_exists <- dbConnect(RPostgres::Postgres(),dbname=db_name,
                           port=5432,user="postgres",password="monica")
    
    print("Connecting to App - Checking Prerequisites")
    
    # if table does not exist create it
    if(!tbl_owner %in% dbListTables(db_exists)){
        print("Creating Initial Tables - Users")
        
        setup_query <-dbSendQuery(db_exists,
                                  "CREATE TABLE owners(
                                      ownerid SERIAL PRIMARY KEY,
                                      name TEXT NOT NULL,
                                      password TEXT NOT NULL,
                                      hash TEXT NOT NULL
                                  );")
        
        # print message if table already exisits
        print("Table Created - Users")
        
        dbDisconnect(db_exists)
    }
    
}

# create table to hold issues
create_issues_table <- function() {
  
  db_exists <- dbConnect(RPostgres::Postgres(),dbname=db_name,
                         port=5432,user="postgres",password="monica")
  
  # if table does not exist create it
  if(!tbl_issues %in% dbListTables(db_exists)){
    print("Creating Initial Tables - Issues")
    
    setup_query <-dbSendQuery(db_exists,
                              "CREATE TABLE issues2(
                                      issueid SERIAL PRIMARY KEY,
                                      class TEXT,
                                      unit TEXT,
                                      product TEXT,
                                      severity TEXT,
                                      effort NUMERIC,
                                      desc_short TEXT,
                                      desc_long TEXT,
                                      parent TEXT,
                                      child TEXT,
                                      userid TEXT,
                                      assignee TEXT,
                                      date TIMESTAMP);"
                              )
    
    # print message if table already exisits
    print("Table Created - Issues")
    
    dbDisconnect(db_exists)
  }
  
}

# get projects available
data_parent<-c("fruit","basket","chips","coke","fanta","sprite","whiskey")
data_child<-c("hen","hippo","dolphin","rhino","lion","zebra","hyena","giraffe","meerkat")



# create issue
create_issue <- function(class_in,unit_in,product_in,severity_in,effort_in,desc_short_in,desc_long_in,parent_in,child_in,user_in,assignee_in,date_in){#,effort_in,desc_short_in,desc_long_in,parent_in,child_in,user_in,assignee_in) {
  
  conn_createissue <- dbConnect(RPostgres::Postgres(),dbname=db_name,
                                port=5432,user="postgres",password="monica")
  
##, effort, desc_short, desc_long, parent, child, userid, assignee)
  query_createissue <-isolate(sqlInterpolate(conn_createissue,
                                             "INSERT into issues2 (class, unit, product, severity, effort, desc_short, desc_long, parent, child, userid, assignee, date)
                                             
                                              VALUES(?value_class, ?value_unit, ?value_product, ?value_severity, ?value_effort,?value_short, ?value_long, ?value_parent, ?value_child, ?value_user, ?value_assignee, ?value_date);",
                                              #,?value_severity,?value_effort,?value_desc_short,?value_desc_long,?value_parent,?value_child,?value_user,?value_assignee);",
                                             value_class=class_in,
                                             value_unit=unit_in,
                                             value_product=product_in,
                                             value_severity=severity_in,
                                             value_parent=parent_in,
                                             value_effort=effort_in,
                                             value_short=desc_short_in,
                                             value_long=desc_long_in,
                                             value_parent=parent_in,
                                             value_child=child_in,
                                             value_user=user_in,
                                             value_assignee=assignee_in,#),)
                                             value_date=date_in))
  
  dbSendQuery(conn_createissue,query_createissue)
  
  
}


# retrieve issue 
get_issue <- function(class_in, start_in, end_in) {
  
  conn_geteissue <- dbConnect(RPostgres::Postgres(),dbname=db_name,
                                port=5432,user="postgres",password="monica")
  
  query_getissue <- isolate(sqlInterpolate(conn_geteissue, 
                                           "SELECT * from issues2 WHERE
                                           class = ?value_class AND date BETWEEN ?value_start AND ?value_end;",
                                           value_class=class_in,
                                           value_start=start_in,
                                           value_end=end_in
                                           ))
  
  issue_status <- dbGetQuery(conn_geteissue,query_getissue)
  
  return(issue_status)
  
}


## Reporting Section

# create views in PG
# recall and plot
# timer (wait for compute)
# download function

# count issues per product
# workload per class
# issues per user, assignee table
# sum (workload) per assignee by class


report_generation <- function() {
  
  conn_report <- dbConnect(RPostgres::Postgres(),dbname=db_name,
                              port=5432,user="postgres",password="monica")
  
  a<-dbGetQuery(conn_report,"SELECT product, class, count(class) AS n_count
                                      FROM issues2
                                      GROUP BY product, class;")
  
  b<-dbGetQuery(conn_report,"SELECT class, sum(effort) sum_effort_hrs
                                       FROM issues2
                                        GROUP BY class;")
  
  
  c<-dbGetQuery(conn_report,"SELECT userid, assignee, count(issueid) open_issues
                FROM issues2 
                GROUP BY userid, assignee;")
  
  res <- list(a,b,c)
  
  return(res)

  
  
  #query_three <- isolate(sqlInterpolate(conn_report,
  #                                      "SELECT userid, assignee, count(issueid) open_issues
   #                                     FROM issues2
   #                                     GROUP BY userid, assignee;"))
  
  
  #query_four <- isolate(sqlInterpolate(conn_report,
  #                                     "SELECT class, product, assignee, count(issueid) allocated_issues
  #                                     FROM issues2
  #                                     GROUP BY class,product,assignee;"))
  
  #reports1 <-dbSendQuery(conn_report,query_one)
  

  
}


# create user
create_user <- function(user_in,password_in,hash_in) {
  
  #input <- input
  
  conn_createuser <- dbConnect(RPostgres::Postgres(),dbname=db_name,
                               port=5432,user="postgres",password="monica")
  
  query_createuser <-isolate(sqlInterpolate(conn_createuser,
                                            "INSERT into owners (name, password, hash)
                                              VALUES(?value_name,?value_password,?value_hash);",
                                            value_name=user_in,
                                            value_password=password_in,
                                            value_hash=hash_in))
  
  #valPassword=input$new_pw,
  dbSendQuery(conn_createuser,query_createuser)
  
  print(paste0("User ",user_in," Created"))
  
}



# check if users exist
get_user <- function(user_check) {
    
    #input <- input
    
    conn_getuser <- dbConnect(RPostgres::Postgres(),dbname=db_name,
                              port=5432,user="postgres",password="monica")
    
    query_getuser <-isolate(sqlInterpolate(conn_getuser,
                                           "SELECT * FROM owners WHERE name = ?value_user;",
                                           value_user=user_check))
    
    user_status <-dbGetQuery(conn_getuser,query_getuser)
    
    print("Checking if User Exists")
    
    return(user_status)
    
}



# Initial setup
# Create users and issues tables if they don't alreasdy exist
create_owners_table()
create_issues_table()


# server function
shinyServer(function(input, output, session) {
    
    loggedIn <- reactiveVal(value = FALSE)
    user <- reactiveVal(value = NULL)
    
    
    # reactive event used to check user credentials
    login <- eventReactive(input$login, {
        
        # take user input and pass to get_user()
        potential_user <- input$username
        user_data <- get_user(potential_user)
        
        if(nrow(user_data) > 0){ # If the active user is in the DB then logged in
            if(sha256(input$password) == user_data[1, "hash"]){
                
                user(input$username)
                loggedIn(TRUE)
                
                print(paste("- User:", user(), "logged in"))
                
                # set reactive event "login" to TRUE
                return(TRUE)
            }
        }
        
        # otherwise leave reactive event "login" as FALSE
        return(FALSE)
        
        
    })
    
    # reactive event to register new users
    register_user <- eventReactive(input$register_user, {
        
        # take user input and pass to fucntion get_user()
        preexisting_user <- input$new_user
        users_data <-get_user(preexisting_user)
        
        if(nrow(users_data) > 0){
            return(span("User already exists", style = "color:red"))
        }
        
        # map user inputs and then pass to create_user()
        new_user <- input$new_user
        new_password <- input$new_pw
        new_hash <- sha256(input$new_pw)

        create_user(new_user,new_password,new_hash)
    
        return(span("Registeration Successful!", style = "color:green"))
        
    })
    

    
    output$register_status <- renderUI({
      if(input$register_user == 0){
        return(NULL)
        } else {
        register_user()
      }
    })
    
    
    
    output$login_status <- renderUI({
        if(input$login == 0){
            return(NULL)
        } else {
            if(!login()){
              return(span("The Username or Password is Incorrect", style = "color:red"))
            }
        }
    })
    
    observeEvent(input$register_account, {
        showModal(
            modalDialog(title = "Create Login", size = "m", easyClose = FALSE, footer = modalButton("Close"), 
                        textInput(inputId = "new_user", label = "Username"),
                        passwordInput(inputId = "new_pw", label = "Password"),
                        actionButton(inputId = "register_user", label = "Submit"),
                        p(input$register_user),
                        uiOutput("register_status")
                        
                        
                        )
                        
            )
        
        
        register_user()
        
    })

    observeEvent(input$logout, {
        user(NULL)
        loggedIn(FALSE)
        print("- User: logged out")
    })
    
    #updateSelectizeInput(session, 'foo', choices = data_in, server = TRUE)
    
    observe({
        if(loggedIn()){
          
          # update choices available
          updateSelectizeInput(session, 'form_parent', choices = data_parent,
                               options = list(create=TRUE,multiple=TRUE,maxOptions=5), server = TRUE)
          
          updateSelectizeInput(session, 'form_child', choices = data_child,
                               options = list(create=TRUE,multiple=TRUE,maxOptions=3),server = TRUE)
          
          
          # wait on submit to create issues
          issues <- observeEvent(input$form_action_button, {
            
            # map user inputs to arguments
            new_class <- input$form_class
            new_unit <- input$form_unit
            new_product <- input$form_product
            new_severity <- input$form_severity
            new_effort <- input$form_effort
            new_short <- input$form_desc_short
            new_long <- input$form_desc_long
            new_parent <- input$form_parent
            new_child <- input$form_child
            new_user <- "user"
            new_assignee <- input$form_assignee
            new_date <- format_iso_8601(Sys.time())
            
            create_issue(new_class, new_unit, new_product, new_severity, new_effort, new_short, new_long, new_parent, new_child, new_user, new_assignee, new_date)
            
            return(span("Print"))
          
            
          })
          
          
      
          
          
          # wait on submit to get issues
          getIssuesEvent <- observeEvent(input$form_button_get_issues, {

            
            # map user inputs to function
            class_get <- input$form_get_class
            start_get <- format_iso_8601(input$form_get_date[1])
            end_get <- format_iso_8601(input$form_get_date[2]+(24*60*60)) # make dateInput inclusive
            
            
            # make query to database
            temp_submission<-get_issue(class_get, start_get, end_get)
            
          
            # render above query   
            output$renderResults <-renderDataTable({
              
              temp_submission
              
            }, 
            options = list(pageLength=10,searching=FALSE))
            
            
          })
          
        
          
          # first report
          getReportsEvent1 <- observeEvent(input$report_one, {
          
            temp_reports <-report_generation()
            
            output$report1_table <- renderDataTable({
              
              temp_reports[[1]]
              
            },options = list(pageLength=10,searching=FALSE))
            
            
          })
          
          # second report
          getReportsEvent2 <- observeEvent(input$report_two, {
            
            temp_reports <-report_generation()
            
            output$report2_table <- renderDataTable({
              
              temp_reports[[2]]
              
            },options = list(pageLength=10,searching=FALSE))
            
            
          })
         
          
          # third report 
          getReportsEvent3 <- observeEvent(input$report_three, {
            
            temp_reports <-report_generation()
            
            output$report3_table <- renderDataTable({
              
              temp_reports[[3]]
              
            },options = list(pageLength=10,searching=FALSE))
            
            
          })
          
          
    
          
          
          
          
            output$App_Panel <- renderUI({
                fluidPage(
                    fluidRow(
                        strong(paste("Logged in as", toupper(user()), "|")), actionLink(inputId = "logout", "Logout"), align = "right",
                        hr()
                    ),
                    fluidRow(navbarPage("BUG/ISSUE TRACKER",id = "New",
                                        tabPanel("Submission",
                                                 
                                          # tab 1 :: side panel       
                                          sidebarPanel(
                                            selectInput(inputId = "form_class", label = "Class", choices = c("Bug", "Change Request", "Feature")),
                                            selectInput(inputId = "form_unit", label = "Unit", choices = c("UI", "Backend","Security", "Performance", "Functionality","Compliance", "Other")),
                                            selectInput(inputId = "form_product", label = "Product/Service", choices = c("Flight Ops Scheduler (FoS)", "Fuel Optimization Tool (FuOT)", "Crew Planning Tool (CrPT", "Ground Operations Planing Tool (GoPT)", "Ad-Sense Optimization Tool (AsOT)")),
                                            selectInput(inputId = "form_severity", label = "Severity", choices = c("Minor (S0)", "Moderate (S1)", "Critical (S2)")),
                                            sliderInput(inputId = "form_effort", label = "Estimated Effort (Days)", min = 1, max = 28, step = 1,value = 5, animate = TRUE),
                                            textInput(inputId = "form_assignee", label = "Assignee"),
                                            
                                            # action button [submit form to database]
                                            actionButton("form_action_button", "Submit!")
                                          ),
                                          
                                          # tab 1 :: main panel 
                                          mainPanel(
                                            textInput(inputId = "form_desc_short", label = "Summary",width = '500'),
                                            textAreaInput(inputId = "form_desc_long", label = "Description",width = '500px',rows = 6),
                                            selectizeInput('form_parent',label="Parent",choices=NULL,multiple=FALSE),
                                            selectizeInput('form_child',label="Child",choices=NULL,multiple=FALSE)
                                          )
                                          
                                          
                                        ),
                                        tabPanel("Track Issues", 
                                          sidebarPanel(
                                            selectInput(inputId = "form_get_class", label = "Class", choices = c("Bug", "Change Request", "Feature")),
                                            dateRangeInput(inputId = "form_get_date",label="Date Range"),
                                            sliderInput(inputId = "form_get_n",label="Count per Parent",min = 1,max = 10,step = 1,value = 3),
                                            actionButton(inputId = "form_button_get_issues", label = "Request Data")
                                            
                                          ),
                                          
                                          mainPanel(
                                            #tableOutput("renderResults")
                                            dataTableOutput("renderResults")
                                            
                                          )
                                                 ),
                                        
                                        tabPanel("Generate Reports", id="Foo",value="Bar",
                                          sidebarPanel(
                                            actionButton(inputId = "report_one", label = "Report 1"),
                                            p(),
                                            actionButton(inputId = "report_two", label =  "Report 2"),
                                            p(),
                                            actionButton(inputId = "report_three", label = "Report 3"),
                                            p(),
                                            actionButton(inputId = "report_four", label = "Report 4")
                                          ),
                                          
                                          mainPanel(
                                            dataTableOutput("report1_table"),
                                            p(), 
                                            dataTableOutput("report2_table"),
                                            p(),
                                            dataTableOutput("report3_table")
                                          )
                                        )
                                                 
                                                 
                    ))
                        #titlePanel(title = "APP UI GOES Here"), align = "center"
                    #)
                )
                
            })
        } else {
            output$App_Panel <- renderUI({
                fluidPage(
                    fluidRow(
                        hr(),
                        titlePanel(title = "App Name"), align = "center"
                    ),
                    fluidRow(
                        column(4, offset = 4,
                               wellPanel(
                                   h4("Login", align = "center"),
                                   textInput(inputId = "username", label = "Username"),
                                   passwordInput(inputId = "password", label = "Password"),
                                   fluidRow(
                                       column(4, offset = 4, actionButton(inputId = "login", label = "Sign In")),
                                       column(6, offset = 2, actionButton(inputId = "register_account", label = "New User? - Register")),
                                       column(6, offset = 3, uiOutput(outputId = "login_status")
                                       )
                                   )
                               )
                        )
                    )
                )
            })
        }
    })
    
  
    
    
})


