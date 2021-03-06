#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(MPAtools)

# Define UI for application that draws a histogram
ui = navbarPage("A tool to evaluate the effectiveness of no-take Marine Reserves",
                # p(),
                # img(src="cobi.jpg", width="60px"),
                # img(src="turf.jpg", width="60px"),
                # First tab starts here
                tabPanel("Introduccion",
                         sidebarLayout(
                           sidebarPanel(
                             h1("Recursos"),
                             p("Link al ", a("Manual", href="www.turfeffect.org", target="_blank")),
                             p("Link a la ", a("Guía de usuario", href="www.turfeffect.org", target="_blank")),
                             p("Página de ", a("TURFeffect", href="www.turfeffect.org", target="_blank")),
                             p("Enviar comentarios a", a("Juan Carlos Villaseñor-Derbez", href="juancarlos@turfeffect.org", target="_blank"))),
                           mainPanel(
                             h1("Introducción"),
                             p("Bienvenido a la aplicación TURFeffect. Esta es una herramienta que te permitirá evaluar la efectividad de tu zonas de no pesca. La evaluación se basa en el desempeño de una serie de indicadores ", tags$b("Biofísicos, Socioeconómicos y de Gobernanza"), ". Los indicadores son seleccionados con base en los objetivos indicados, pero la aplicación permite que el usuario (tu!) selecciones indicadores que creas más convenientes o sean de tu mayor interés."),
                             p("Antes de seguir, asegúrate de leer la guía de usuario de la aplicación, así como el manual de evaluación de zonas de no pesca en México Podrás encontrar los recursos en el menú de la derecha.")
                           ),
                           position = c("right"))
                ),
                #Second tab starts here
                tabPanel("Objetivos e Indicadores",
                         sidebarLayout(
                           sidebarPanel(
                             h1("Objetivos"),
                             checkboxGroupInput("obj",
                                                "Selecciona tus objetivos",
                                                choices = c("Recuperar especies de interés comercial" = "A",
                                                            "Conservar especies en régimen de protección especial" = "B",
                                                            "Mejorar la productividad pesquera en aguas adyacentes" = "C",
                                                            "Evitar que se llegue a la sobreexplotación" = "D",
                                                            "Recuperar especies sobreexplotadas" = "E",
                                                            "Contribuir al mantenimiento de los procesos biológicos" = "E",
                                                            "Preservar el hábitat de las especies pesqueras" = "F",
                                                            "More objectives" = "G",
                                                            "More Objectives" = "H",
                                                            "More objectives" = "I"),
                                                selected = c("A"))
                           ),
                           mainPanel(
                             wellPanel(
                               fluidRow(
                                 h1("Indicadores"),
                                 
                                 p("Basandonos en los objetivos seleccionados, nuestra propuesta de indicadores es la siguiente"),
                                 
                                 column(4, wellPanel(
                                   uiOutput("indB"))),
                                 
                                 column(3, wellPanel(
                                   uiOutput("indS")
                                 )),
                                 
                                 column(5, wellPanel(
                                   uiOutput("indG")
                                 ))
                               ))
                           ))
                ),
                
                #Third tab starts here
                tabPanel("Datos",
                         sidebarLayout(
                           sidebarPanel(
                             fileInput(inputId ="biophys",
                                       label = "Base biofis",
                                       accept = ".csv"),
                             
                             fileInput(inputId ="socioeco",
                                       label = "Base socioeco",
                                       accept = ".csv"),
                             
                             fileInput(inputId ="govern",
                                       label = "Base gobernanza",
                                       accept = ".csv")
                           ),
                           mainPanel(
                             "More Stuff",
                             tableOutput("contents")
                           ))
                ),
                
                # Fourth tab starts here
                tabPanel("Seleccionar Reserva",
                         fluidRow(
                           column(3, wellPanel(
                             h1("Comunidad"),
                             uiOutput("comunidad")
                           )),
                           
                           column(3, wellPanel(
                             h1("Reserva-Control"),
                             uiOutput("rc")
                           ))
                         )
                         
                ),
                
                #Fifth tab starts here
                tabPanel("Confirmar",
                         fluidPage(
                           fluidRow(
                             column(2, wellPanel(
                               tableOutput("objss")
                             )),
                             
                             column(2, wellPanel(
                               tableOutput("indBs")
                             )),
                             
                             column(2, wellPanel(
                               tableOutput("indSs")
                             )),
                             
                             column(2, wellPanel(
                               tableOutput("indGs")
                             )),
                             
                             column(2, wellPanel(
                               tableOutput("comss")
                             )),
                             
                             column(2, wellPanel(
                               tableOutput("rcpss")
                             ))
                           )
                         )
                ),
                
                #Sixth tab starts here
                tabPanel("Resultados",
                         sidebarLayout(
                           sidebarPanel(
                             "Nothing yet"),
                           mainPanel(
                             plotOutput("results")
                           ))
                )
)

######
# Define server logic
server <- function(input, output) {
  
  options(shiny.maxRequestSize = 200*1024^2)
  
  
  # Definir datos biofisicos
  datasetInput <- reactive({
    
    inFile <- input$biophys
    
    if (is.null(inFile)){
      # data.frame(Comunidad = c("El Rosario", "Maria Elena", "Puerto Libertad"),
      #            Reserva = c("La Caracolera", "El Gallinero", "Cerro Bola"),
      #            Control = c("Lazaro", "El Callienro Control", "Cerro Bola control")) %>%
      #   mutate(RC = paste(Reserva, Control, sep = "-"))
      return(NULL)
      
    } else {
      
      data <- read.csv(inFile$datapath) %>%
        filter(!is.na(Comunidad))
      
      return(data)
    }
  })
  
  output$contents <- renderTable({
    head(datasetInput())
  })
  
  # Definir datos pesqueros
  
  # Definir datos de gobernananza
  
  ##### Definir indicadores reactivos a los objetivos####

  # Definir Indicadores Biofisicos
  output$indB <- renderUI({
    
    if (any(input$obj == "A")){
      
      checkboxGroupInput("indB",
                         "Biofísicos",
                         choices = c("Densidad",
                                     "Riqueza",
                                     "Índice de diversidad de Shannon",
                                     "Biomasa",
                                     "Organismos > LT_50",
                                     "Nivel trófico"),
                         selected = c ("Densidad"))
    } else {
      checkboxGroupInput("indB",
                         "Biofísicos",
                         choices = c("Densidad",
                                     "Riqueza",
                                     "Índice de diversidad de Shannon",
                                     "Biomasa",
                                     "Organismos > LT_50",
                                     "Nivel trófico"),
                         selected = c("Riqueza"))
    }
  })
  
  # Definir idnciadores Socioeconomicos
  output$indS <- renderUI({
    
    if (any(input$obj == "A")){
      
      checkboxGroupInput("indS",
                         "Socioeconómicos",
                         choices = c("Arribos",
                                     "Ingresos por arribos"),
                         selected = c("Arribos"))
    } else {
      checkboxGroupInput("indS",
                         "Socioeconómicos",
                         choices = c("Arribos",
                                     "Ingresos por arribos"),
                         selected = c("Ingresos por arribos"))
    }
  })
  
  # Definir indicadores de gobernanza
  output$indG <- renderUI({
    
    if (!any(input$obj == "G")){
      
      checkboxGroupInput("indG",
                         "Gobernanza",
                         choices = c("Acceso a la pesquería",
                                     "Número de pescadores",
                                     "Reconocimiento legal de la reserva", 
                                     "Grado de pesca ilegal",
                                     "Plan de manejo",
                                     "Tamaño de la reserva",
                                     "Razonamiento para el diseño de la reserva",
                                     "Pertenencia a oragnizaciones pesqueras",
                                     "Tipo de organización pesquera",
                                     "Representación"),
                         selected = c("Acceso a la pesquería",
                                      "Número de pescadores",
                                      "Reconocimiento legal de la reserva", 
                                      "Grado de pesca ilegal",
                                      "Plan de manejo",
                                      "Tamaño de la reserva",
                                      "Razonamiento para el diseño de la reserva",
                                      "Pertenencia a oragnizaciones pesqueras",
                                      "Tipo de organización pesquera",
                                      "Representación"))
    } else {
      
      checkboxGroupInput("indG",
                         "Gobernanza",
                         choices = c("Acceso a la pesquería",
                                     "Número de pescadores",
                                     "Reconocimiento legal de la reserva", 
                                     "Grado de pesca ilegal",
                                     "Plan de manejo",
                                     "Tamaño de la reserva",
                                     "Razonamiento para el diseño de la reserva",
                                     "Pertenencia a oragnizaciones pesqueras",
                                     "Tipo de organización pesquera",
                                     "Representación"),
                         selected = c("Acceso a la pesquería",
                                      "Plan de manejo",
                                      "Tamaño de la reserva",
                                      "Razonamiento para el diseño de la reserva",
                                      "Representación"))
      
    }
  })
  
  
  #######
  ### Definir Comunidades y Reservas-Control reactivas a los datos ingresados
  
  output$comunidad <- renderUI({
    
    datos <- datasetInput()
    
    comunidades <- unique(datos$Comunidad)
    
    radioButtons("comunidad",
                 "Selecciona tus comunidades",
                 choices = comunidades,
                 selected = "El Rosario")
  })
  
  RC <- function(){
    datos <- datasetInput()
    
    return(unique(datos$RC[datos$Comunidad == input$comunidad]))
  }
  
  output$rc <- renderUI({
    
    RCopts <- RC()
    
    checkboxGroupInput("rc",
                       "Selecciona tus pares Reserva-Control",
                       choices = RCopts)
    
  })
  
  output$objss <- renderTable({
    input$obj
  })
  
  output$indBs <- renderTable({
    input$indB
  })
  
  output$indSs <- renderTable({
    input$indS
  })
  
  output$indGs <- renderTable({
    input$indG
  })
  
  output$comss <- renderTable({
    input$comunidad
  })
  
  output$rcpss <- renderTable({
    input$rc
  })
  
  ### Analisis comienza aqui
  
  # peces <- reactive({datasetInput()})
  # comunidad <- com.fun()
  # reserva <- res.fun()
  # control <- con.fun()
  # 
  # Dp <- summary(turfeffect(density(peces, comunidad), reserva, control))
  # Sp <- summary(turfeffect(richness(peces, comunidad), reserva, control))
  # Bp <- summary(turfeffect(fish_biomass(peces, comunidad), reserva, control))
  # NT <- summary(turfeffect(trophic(peces, comunidad), reserva, control))

  output$results <- renderPlot({
    
    datasetInput() %>%
      group_by(Comunidad, Sitio, Zonificacion, Ano) %>%
      summarize(N = sum(Abundancia, na.rm = T)) %>%
      ggplot(aes(x = Ano, y = N, color = Zonificacion)) +
      geom_point() +
      geom_line() +
      theme_bw()
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

