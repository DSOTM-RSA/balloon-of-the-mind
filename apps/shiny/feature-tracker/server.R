# server side defintion

#load libraries
library(shiny)
library(DBI)
library(pool)
library(keyring)
library(dplyr)
library(openssl)
library(parsedate)


# DATABASE SETUP
tbl_owner <- "users"
tbl_issues <- "issues"


# create pool to handle database connections
pool <- dbPool(drv = RPostgres::Postgres(),dbname = "postgres",
               host = "localhost", 
               user = keyring::key_list("postgresql")[1,2],
               password = keyring::key_get("postgresql","postgres"),
               port=5432)


# FUNCTIONS
# create table to hold users 
create_users_table <- function() {
    
    print("Connecting to App - Checking Prerequisites")
    
    # if table does not exist create it
    if(!tbl_owner %in% dbListTables(pool)){
        print("Creating Initial Tables - Users")
      
      conn <- poolCheckout(pool)
        
        setup_query <-dbSendQuery(conn,
                                  "CREATE TABLE users(
                                      ownerid SERIAL PRIMARY KEY,
                                      name TEXT NOT NULL,
                                      password TEXT NOT NULL,
                                      hash TEXT NOT NULL);"
                                  )
        
        setup_query
        poolReturn(conn)
        
    }
    
}


# create table to hold issues
create_issues_table <- function() {
  
  # if table does not exist create it
  if(!tbl_issues %in% dbListTables(pool)){
    print("Creating Initial Tables - Issues")
    
    conn<-poolCheckout(pool)
    
    setup_query <-dbSendQuery(conn,
                              "CREATE TABLE issues(
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
    
    setup_query
    
    poolReturn(conn)
  }
  
}


# create issue
create_issue <- function(class_in, unit_in, product_in, 
                         severity_in, effort_in, desc_short_in, 
                         desc_long_in, parent_in, child_in, 
                         user_in,assignee_in,date_in){
  

  conn<-poolCheckout(pool)
  query_createissue <-isolate(sqlInterpolate(conn,
                                             "INSERT into issues(
                                             class, unit, product, 
                                             severity, effort, desc_short, 
                                             desc_long, parent, child, 
                                             userid, assignee, date)
                                             VALUES(?value_class, ?value_unit, ?value_product, 
                                             ?value_severity, ?value_effort,?value_short, 
                                             ?value_long, ?value_parent, ?value_child, 
                                             ?value_user, ?value_assignee, ?value_date);",
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
                                             value_assignee=assignee_in,
                                             value_date=date_in
                                             )
                              )
  
  dbSendQuery(conn,query_createissue)
  poolReturn(conn)
  
}


# retrieve issue 
get_issue <- function(class_in, start_in, end_in) {
  
  query_getissue <- isolate(sqlInterpolate(pool, 
                                           "SELECT * from issues WHERE
                                           class = ?value_class AND date BETWEEN ?value_start AND ?value_end;",
                                           value_class=class_in,
                                           value_start=start_in,
                                           value_end=end_in
                                           )
                            )
  
  issue_status <- dbGetQuery(pool,query_getissue)
  
  return(issue_status)
  
}


# create user
create_user <- function(user_in,password_in,hash_in) {
  
  conn<-poolCheckout(pool)
  
  query_createuser <-isolate(sqlInterpolate(conn,
                                            "INSERT into users (name, password, hash)
                                            VALUES(?value_name,?value_password,?value_hash);",
                                            value_name=user_in,
                                            value_password=password_in,
                                            value_hash=hash_in
                                            )
                             )
  
  dbSendQuery(conn,query_createuser)
  poolReturn(conn)
  
  print(paste0("User ",user_in," Created"))
  
}



# check if users exist
get_user <- function(user_check) {
    
    query_getuser <-isolate(sqlInterpolate(pool,
                                           "SELECT * FROM users 
                                           WHERE name = ?value_user;",
                                           value_user=user_check
                                           )
                            )
    
    user_status <-dbGetQuery(pool,query_getuser)
    
    print("Checking if User Exists")
    
    return(user_status)
    
}


## Reporting Section

report_generation <- function(section) {
  
  if (section == "part_a") {
    
    temp_section<-dbGetQuery(pool, "SELECT product, class, count(class) AS n_count 
                     FROM issues GROUP BY product, class;")
    return(temp_section)
    
  } else if (section == "part_b") {
    
    temp_section<-dbGetQuery(pool, "SELECT class, sum(effort) sum_effort_hrs 
                     FROM issues GROUP BY class;")
    return(temp_section)
    
  } else if (section == "part_c") {
    
    temp_section<-dbGetQuery(pool, "SELECT userid, assignee, count(issueid) open_issues 
                     FROM issues GROUP BY userid, assignee;")
    return(temp_section)
    
  } else if (section == "part_d") {
    
    temp_section <-dbGetQuery(pool, "SELECT class, product, assignee, count(issueid) allocated_issues 
                      FROM issues GROUP BY class, product, assignee")
    return(temp_section)
  }
  
  report <- tmp_section
  return(report)
}


# Initial Setup
# Create users and issues tables if they don't alreasdy exist
create_users_table()
create_issues_table()

# Set projects available
data_parent<-c("Mimas", "Enceladus", "Tethys", "Dione", "Rhea", "Titan")
data_child<-c("Pre-Boost", "Launch", "Transit", "Approach", "Orbit", "Landing", "Aquisition", "LTO")


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
    
    
    # tags for reports
    output$report1_status <- renderUI({
      if(input$report_one == 0){
        return(NULL)
      } else {
          return(tags$strong(span("Issues Per Class & Product", style = "color:black")))
      }
    })
    
    output$report2_status <- renderUI({
      if(input$report_two == 0){
        return(NULL)
      } else {
        return(tags$strong(span("Estimated Effort Per Class", style = "color:black")))
      }
    })
    
    output$report3_status <- renderUI({
      if(input$report_three == 0){
        return(NULL)
      } else {
        return(tags$strong(span("Issuer & Assignee Relationship", style = "color:black")))
      }
    })
    
    output$report4_status <- renderUI({
      if(input$report_four == 0){
        return(NULL)
      } else {
        return(tags$strong(span("Assignee Load Per Class & Product", style = "color:black")))
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
    

    
    observe({
        if(loggedIn()){
          
          # update choices available
          updateSelectizeInput(session, 'form_parent', choices = data_parent,
                               options = list(create=TRUE,multiple=TRUE,maxOptions=5), server = TRUE)
          
          updateSelectizeInput(session, 'form_child', choices = data_child,
                               options = list(create=TRUE,multiple=TRUE,maxOptions=5),server = TRUE)
          
          
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
          
            temp_report <-report_generation("part_a")
            
            output$report1_table <- renderDataTable({
              
              temp_report
              
            },options = list(pageLength=10,searching=FALSE))
            
            
          })
          
          # second report
          getReportsEvent2 <- observeEvent(input$report_two, {
            
            temp_report <-report_generation("part_b")
            
            output$report2_table <- renderDataTable({
              
              temp_report
              
            },options = list(pageLength=10,searching=FALSE))
            
            
          })
         
          
          # third report 
          getReportsEvent3 <- observeEvent(input$report_three, {
            
            temp_report <-report_generation("part_c")
            
            output$report3_table <- renderDataTable({
              
              temp_report
              
            },options = list(pageLength=10,searching=FALSE))
            
            
          })
          
          # fourth report
          getReportsEvent4 <- observeEvent(input$report_four, {
            
            temp_report <-report_generation("part_d")
            
            output$report4_table <- renderDataTable({
              
              temp_report
              
            },options = list(pageLength=10,searching=FALSE))
            
            span("print this")
            
          })
          
          
    
          # UI ORGANISATION
          
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
                                            uiOutput("report1_status"),
                                            dataTableOutput("report1_table"),
                                            p(),
                                            uiOutput("report2_status"),
                                            dataTableOutput("report2_table"),
                                            p(),
                                            uiOutput("report3_status"),
                                            dataTableOutput("report3_table"),
                                            p(),
                                            uiOutput("report4_status"),
                                            dataTableOutput("report4_table")
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

