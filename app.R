library(shiny)
library(ggplot2)

# Define UI for application
ui <- fluidPage(

    # Application title
    titlePanel("House purchase cost calculation"),

    # Sidebar with inputs for comparison 
    sidebarLayout(
        sidebarPanel(
            h3("Income"),
            numericInput("initial_deposit",
                        "Initial Deposit",
                        value=18500,
                        step=100),
            numericInput("equity",
                         "Equity",
                         value=5000,
                         step=500),
            numericInput("savings_Joe",
                         "Joe's Savings",
                         value=22800,
                         step=100),
            numericInput("savings_loz",
                         "Loz's Savings",
                         value=3000,
                         step=100),
            numericInput("purchase_price",
                         "Purchase Price of Flat",
                         value=185500),
            numericInput("sale_price",
                         "Sale Price of Flat",
                         value=196000,
                         step=500),
            h3("Costs"),
            numericInput("solicitor_fees",
                         "Solicitor Fees",
                         value=2500,
                         step=100),
            numericInput("estate_agent_fees",
                         "Estate Agent Fees",
                         value=1960,
                         step=100),
            numericInput("survey_cost",
                         "Survey Cost",
                         value=1000,
                         step=100),
        ),
        

        # Show a plot of total funds
        mainPanel(
           plotOutput("affordability_plot"),
           sliderInput("purchase_range", "Purchase Price Range (1000's)", min=200, max=400, value=c(250,350)),
           numericInput("max_lending_amount", "Maximum lending amount", value=295000, step=1000),
           numericInput("deposit_1", "Deposit (%)", value=10, min=0, max=100),
           checkboxInput("compare_check", "Add second deposit for comparison?"),
           uiOutput("second_deposit_ui")
        )
    )
)

# Define server logic
server <- function(input, output) {
    
    # conditionally add a second comparison deposit value
    observeEvent(input$compare_check,{
        print(input$deposit_2)
        if(input$compare_check){
            output$second_deposit_ui <- renderUI({
                numericInput("deposit_2", "Deposit 2 (%)", value=15, min=0, max=100)
            })
        }
        else{
            output$second_deposit_ui <- NULL
        }
    })

    output$affordability_plot <- renderPlot({
        cost <- c(input$solicitor_fees, input$estate_agent_fees, input$survey_cost)
        income <- c(input$initial_deposit, input$equity, input$savings_Joe, input$savings_Loz, input$sale_price - input$purchase_price)
        x <- seq(input$purchase_range[1]*1000, input$purchase_range[2]*1000, 500)
        y1 <- sapply(x, calculate_balance, income=income, costs=cost, deposit_percentage=input$deposit_1, max_lending_amount=input$max_lending_amount)
        y2 <- NULL
        data <- data.frame(x,y1)
        
        if(input$compare_check){
            y2 <- sapply(x, calculate_balance, income=income, costs=cost, deposit_percentage=input$deposit_2, max_lending_amount=input$max_lending_amount)
            data <- data.frame(x,y1,y2)
        }
        
        # draw the histogram with the specified number of bins
        plot <- ggplot(data=data) + 
            geom_smooth(aes(x/1000,y1, colour=paste0(input$deposit_1,"% deposit"))) + 
            geom_hline(yintercept = 0) + 
            ggtitle("Available funds after purchase vs purchase cost") + 
            xlab("Purchase Cost (£)") + 
            ylab("Avaliable funds after purchase (£)") +
            scale_x_continuous(breaks = scales::pretty_breaks(n = 10)) +
            theme(plot.title = element_text(hjust = 0.5, face = "bold", size=16)) +
            scale_colour_manual(name="legend", values=c("blue", "red"))
        
        if(input$compare_check){
            plot <- plot + geom_smooth(aes(x/1000,y2, colour=paste0(input$deposit_2,"% deposit")))
        }
        return(plot)
    })
}

calculate_balance <- function(purchase_price, income, costs, deposit_percentage, max_lending_amount) {
    deposit <- NULL
    
    #assume the cost is between 125000 and 925000
    stamp_duty <- 0.02 * 125000 + (purchase_price-250000)*0.05
    
    max_mortgage <- max_lending_amount/(1-0.01*deposit_percentage)
    
    if(max_mortgage > purchase_price){
        # full cost of house is covered by mortgage
        deposit <- deposit_percentage * 0.01 * purchase_price
        balance <- sum(income) - sum(costs) - deposit - stamp_duty
        return(balance)
    }
    else{
        # need to include difference between lending amount and cost of house
        deposit <- deposit_percentage * 0.01 * max_mortgage
        balance <- sum(income) - sum(costs) - deposit - stamp_duty - (purchase_price - max_mortgage)
        return(balance)
    }
}

# Run the application 
shinyApp(ui = ui, server = server)
