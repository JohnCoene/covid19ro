# Downloads and preprocesses GeoJSon
# mapa RO
rondonia <- jsonlite::read_json("https://raw.githubusercontent.com/luizpedone/municipal-brazilian-geodata/master/data/RO.json")

rondonia$features <- rondonia$features %>%
  purrr::map(function(x){
    x$properties$name <- x$properties$NOME # copy NOME to name for tooltip
    return(x)
  })

if(!dir.exists("www"))
  dir.create("www")

jsonlite::write_json(rondonia, "./www/rondonia.json")
