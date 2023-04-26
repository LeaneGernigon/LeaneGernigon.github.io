library(shiny)
library(geoloc)

# Définition de l'interface utilisateur
ui <- fluidPage(
  titlePanel("Mesurer la hauteur d'herbe"),
  sidebarLayout(
    sidebarPanel(
      numericInput("hauteur", "Hauteur d'herbe (en cm) :", min = 0, max = 100, value = 0),
      # Obtenir les coordonnées GPS actuelles
      geoloc::button_geoloc("coord", "Ma position"),
      actionButton("enregistrer", "Enregistrer la mesure")
    ),
    mainPanel(
      textOutput("status")
    )
  )
)

# Définition du serveur
server <- function(input, output) {
  
  # Fonction pour enregistrer la mesure dans un fichier CSV
  enregistrer_mesure <- function(hauteur, latitude, longitude) {
    
    # Vérifier si le fichier CSV existe
    if (!file.exists("mesures.csv")) {
      # Créer le fichier CSV avec un en-tête
      write.csv(as.data.frame(setNames(replicate(5, integer(0), simplify = F), c("hauteur", "latitude", "longitude", "date", "heure"))), "mesures.csv", row.names = FALSE)
    }
    
    # Ajouter une ligne pour la nouvelle mesure
    timestamp <- Sys.time()
    new_row <- data.frame(hauteur = hauteur, latitude = latitude, longitude = longitude, date = format(timestamp, "%Y-%m-%d"), heure = format(timestamp, "%H:%M:%S"))
    write.table(new_row, "mesures.csv", sep = ",", col.names = FALSE, row.names = FALSE, append = TRUE)
    
  }
  
  # Fonction pour enregistrer la mesure et afficher le statut
  enregistrer_et_afficher_statut <- function() {
    
    # Enregistrer la mesure
    enregistrer_mesure(input$hauteur, input$coord_lat, input$coord_lon)
    
    # Afficher le statut de l'enregistrement
    output$status <- renderText("La mesure a été enregistrée avec succès.")
    
    
  }
  
  # Événement de clic sur le bouton "Enregistrer la mesure"
  observeEvent(input$enregistrer, {
    enregistrer_et_afficher_statut()
  })
  
}

# Lancement de l'application Shiny
shinyApp(ui = ui, server = server)
