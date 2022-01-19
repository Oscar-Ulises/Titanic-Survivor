# Libraries ---------------------------------------------------------------
library(shiny)
library(shinythemes)
# Import Data -------------------------------------------------------------
#setwd("C:/Users/52473/Desktop/Diseño Web/Shiny/Titanic/Titanic_app")
train<- read.csv(".data/clean_data.csv",header = TRUE)
train <- subset(train,select = c(2,3,4,5,6,7,8,9))
# Factors -----------------------------------------------------------------
train$Survived<- as.factor(train$Survived)
train$Pclass<- as.factor(train$Pclass)
train$Sex<- as.factor(train$Sex)
train$SibSp<- as.factor(train$SibSp)
train$Parch<- as.factor(train$Parch)
train$Embarked<- as.factor(train$Embarked)
attach(train)
# Model -------------------------------------------------------------------
model<- glm(Survived~.,family = binomial(link = 'logit'),data=train)
# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("superhero"),
    tags$head(
        tags$style(HTML("@import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Inter&family=Rajdhani:wght@300&display=swap');
                        body { font-family: 'Rajdhani', sans-serif;}
                        h2 {font-family: 'Rajdhani', sans-serif;}
                        h3 {font-family: 'Rajdhani', sans-serif;}
                        p {font-size: 20px;}
                        "))),
    #titlePanel("¿Sobrevivirías en el Titanic."),
    h2("Would you survive on the Titanic?", id = "title"),
    p("The sinking of the Titanic was one of the most remembered maritime catastrophes in history, it occurred on the night of April 14 to 15, 1912, in which 1,496 people of the 2,208 who were on board died."),
    p("Have you ever wondered if you had been on the famous ship, would you arrive in New York with the rest of the survivors or would you have the same Jack Dawson from the movie with the same name.
       Well, this question will be answered below thanks to kaggle's 'Titanic' database, in which there are 891 passengers, each with different characteristics that allow us to find patterns, in this case, of survival."),
    
    sidebarPanel( h3("Parameters"),
    #HTML("<h3>Parámetros</h3>"),
    selectInput(inputId = "pclass", label = "How much money do you earn monthly?", 
                choices = list("Less than $42,000.00" = 3,"From $42,000.00 to $400,000.00" = 2, "More than $400,000.00" = 1)),
    selectInput(inputId = "sex", label = "Sex:", 
                choices = list("Male" = "male", "Female" = "female")),
    sliderInput(inputId = "age", label = "Age:",
                min = 0, max = 80, value = 30),
    sliderInput(inputId = "fare", "How much would you pay to be in a historical event?",
                min = 0, max = 550, value = 50),
    sliderInput(inputId = "sibSp", label = "Are you traveling with a partner or siblings? (If the answer is NO, leave 0).", 
                min = 0, max = 8, value = 0),
    sliderInput(inputId = "parch", label = "Are you traveling with your children? (If the answer is NO, leave 0).", 
                min = 0, max = 6, value = 0),
    selectInput(inputId = "embarked", label = "Which country is easiest for you to travel to?", 
                choices = list("England" =  "S","Ireland" = "Q",'France' = "C")),
    actionButton("submitbutton", "Submit", class = "btn btn-primary")),
mainPanel(
    tags$label(h3('Result')), # Status/Output Text Box
    verbatimTextOutput('contents'),
    tableOutput('tabledata') # Prediction results table
) 
)

# Define server logic required to draw a histogram
server <- function(input, output,session) {
    datasetInput <- reactive({  
        
        df <- data.frame("Pclass" = input$pclass,
                         "Sex" = input$sex,
                         "Age" = input$age,
                         "SibSp" = input$sibSp,
                         "Parch" =  input$parch,
                         "Fare" = input$fare,
                         "Embarked" = input$embarked)
        
        df$Pclass<- factor(df$Pclass, levels = c(3,2,1))
        df$Sex<- factor(df$Sex, levels = c("male","female"))
        df$SibSp<- factor(df$SibSp, levels = c(0,1,2,3,4,5,6,7,8))
        df$Parch<- factor(df$Parch, levels = c(0,1,2,3,4,5,6))
        df$Embarked<- factor(df$Embarked, levels = c("C","Q","S"))
        
        if (predict(model,df,type="response") > 0.5){
            print("Congratulations, you will survive the sinking of the Titanic.")
        }else{
            print("You wouldn't survive. :(")
        }
        
    })
    
    # Status/Output Text Box
    output$contents <- renderPrint({
        if (input$submitbutton>0) { 
            isolate("The calculation is complete.") 
        } else {
            return("The server is ready to do the calculations.")
        }
    })
    
    # Prediction results table
    output$tabledata <- renderTable({
        if (input$submitbutton>0) { 
            isolate(datasetInput()) 
        } 
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
