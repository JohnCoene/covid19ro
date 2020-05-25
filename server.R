#################################################
#            SERVER 
#################################################

server <- function(input, output) {
  
  # leitura dos dados
  ibge <- fread('https://raw.githubusercontent.com/caiolif/covid19ro/master/UFs.txt', encoding = 'UTF-8')
  esus <- fread('http://covid19.sesau.ro.gov.br/arquivos/TabelaESus.csv', encoding = 'Latin-1')
  colnames(esus) <- c('Id', 'profissional_saude', 'evolucao_caso',
                      'data', 'Sexo', 'Bairro', 'classificacao_final',
                      'municipio', 'Idade')
  esus <- esus %>% 
    mutate(evolucao_caso = recode(evolucao_caso,
                                  `Óbito` = 'Obito'))
  
  covid_cidades <- fread('https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-cities-time.csv', encoding = 'UTF-8') %>% 
    mutate(date = as.Date(date)) %>% 
    as_tibble()
  
  covid_total <- fread('https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-total.csv') %>% as_tibble()
  
  cores <- c(verde = wes_palette("Darjeeling1")[2],
             vermelho = wes_palette("Royal1")[2],
             laranja = wes_palette("FantasticFox1")[1],
             cinza = wes_palette("Chevalier1")[1])
  
  
  # descriptions blocks
  #-------------------------------------
  # cenário estadual
  #-------------------------------------
  covid_total %>% 
    filter(state == 'RO') %>% 
    select(tests) -> testes
  
  covid_total %>% 
    filter(state == 'RO') %>% 
    select(totalCases) -> casos_confirmados
  
  covid_total %>% 
    filter(state == 'RO') %>% 
    select(deaths) -> obitos
  
  covid_total %>% 
    filter(state == 'RO') %>% 
    select(recovered) -> recuperados
  
  covid_cidades %>% 
    filter(state == 'RO') %>% 
    count(city) %>% 
    summarise(n_cidades = (n()-1)*100/52) %>%  
    pull(n_cidades) -> n_cidades
  
  covid_total %>% 
    filter(state == 'RO') %>% 
    summarise(let = deaths*100/totalCases) -> letalidade
  
  
  output$testes <- renderbs4InfoBox({
    bs4InfoBox(
      title = 'Testes realizados',
      value = testes,
      icon = 'vial',
      status = "primary"
    )
  })
  
  output$casos <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Casos confirmados',
      value = casos_confirmados,
      icon = 'check',
      status = "primary"
    )
  )
  
  output$obitos <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Óbitos',
      value = obitos,
      icon = 'skull',
      status = "danger"
    )
  )
  
  output$recuperados <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Indivíduos recuperados',
      value = paste0(recuperados, ' ', '(',round(recuperados*100/casos_confirmados, 1), '%)'),
      icon = 'ambulance',
      status = "success"
    )
  )
  
  output$municipios <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Municípios atingidos',
      value = paste0(round(n_cidades, 1), '%'),
      icon = 'map-marker-alt',
      status = "primary"
    )
  )
  
  output$letalidade <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Taxa de Letalidade',
      value = paste0(round(letalidade, 1), '%'),
      icon = 'exclamation-circle',
      status = "danger"
    )
  )

   # mapa rondonia
  output$mapa_ro <- renderEcharts4r({
    covid_cidades %>%
      filter(state == 'RO') %>%
      mutate(city = gsub(city, pattern = '/RO', replacement = '')) %>%
      group_by(city) %>%
      summarise(Casos = max(totalCases)) %>%
      e_charts(city) %>%
      # e_map_register("Rondonia", rondonia) %>%
      e_map(Casos, map = "Rondonia", emphasis = list(itemStyle = list(shadowBlur = 3)),
            roam = TRUE, zoom = 1) %>%
      e_visual_map(Casos) %>%
      e_tooltip()
  })
  
  
  # casos acumulados RO
  output$plot_acumulados <- renderEcharts4r(
    covid_cidades %>%
      filter(state == 'RO') %>%
      group_by(date) %>%
      summarise(caso_diario = sum(totalCases),
                caso_log = round(log10(sum(totalCases)), 2)) %>%
      melt('date') %>%
      mutate(variable = recode(variable, caso_diario = 'Confirmados',
                               caso_log = 'Escala logarítmica')) %>%
      group_by(variable) %>%
      filter(variable == 'Confirmados') %>% 
      e_charts(x = date) %>%
      #e_line(value, lineStyle = list(symbol = 'square', width = 2, shadowBlur = 4, shadowOffsetY = 4), areaStyle = TRUE) %>%
      e_bar(value) %>% 
      e_mark_point(data = list(type = 'max')) %>%
      e_tooltip(trigger = 'axis') %>%
      e_x_axis(date, axisPointer = list(show = TRUE)) %>%
      e_y_axis(type = ifelse(input$log, "log", "value")) %>% 
      e_legend(FALSE) %>% 
      e_color(color = cores[[4]]) %>% 
      e_datazoom(
        type = "slider", 
        toolbox = FALSE,
        bottom = -5
      )
  )
  
  
  # óbitos RO
  
  output$plot_obitos <- renderEcharts4r(
    
    covid_cidades %>%
      filter(state == 'RO') %>%
      group_by(date) %>%
      summarise(obitos = sum(deaths),
                casos = sum(totalCases)) %>%
      mutate(let = round(obitos*100/casos, 2)) %>% 
      melt('date') %>%
      mutate(variable = recode(variable, obitos = 'Óbitos',
                               casos = 'casos',
                               let = 'Letalidade')) %>%
      filter(variable == input$plot_obitos_ro) %>% 
      group_by(variable) %>%
      e_charts(x = date) %>%
      #e_line(value, lineStyle = list(symbol = 'square', width = 2, shadowBlur = 4, shadowOffsetY = 4), areaStyle = TRUE) %>%
      e_bar(value) %>% 
      e_mark_point(data = list(type = 'max')) %>%
      e_tooltip(trigger = 'axis') %>%
      e_x_axis(date, axisPointer = list(show = TRUE)) %>% 
      e_y_axis(formatter = ifelse(input$plot_obitos_ro == 'Letalidade', '{value}%', '{value}')) %>% 
      e_legend(FALSE) %>% 
      e_color(color = c(cores[[2]], cores[[2]])) %>% 
      e_datazoom(
        type = "slider", 
        toolbox = FALSE,
        bottom = -5
      )
  )
  
  
  # variação casos totais
  covid_cidades %>%
    filter(state == 'RO') %>%
    group_by(date) %>%
    summarise(caso_diario = sum(totalCases),
              obito_diario = sum(deaths)) -> casos_var
  
  mudanca_casos <- NA
  mudanca_obitos <- NA
  for(i in 2:nrow(casos_var)) {
    mudanca_casos[i] <- round((casos_var$caso_diario[i]/casos_var$caso_diario[i-1] - 1)*100, 2)
    mudanca_obitos[i] <- round((casos_var$obito_diario[i]/casos_var$obito_diario[i-1] - 1)*100, 2)
  }
  
  casos_var['mudanca_casos'] <- mudanca_casos
  casos_var['mudanca_obitos'] <- mudanca_obitos
  
  output$variacao_ro <- renderEcharts4r(
    casos_var %>% 
      select(date, mudanca_casos, mudanca_obitos) %>% 
      melt('date') %>%
      mutate(variable = recode(variable, mudanca_casos = 'Casos',
                               mudanca_obitos = 'Óbitos')) %>%
      group_by(variable) %>%
      filter(value != 0) %>% 
      e_charts(x = date) %>%
      e_line(value, lineStyle = list(symbol = 'square', width = 2, shadowBlur = 4, shadowOffsetY = 4)) %>%
      e_mark_point(data = list(type = 'max')) %>%
      e_tooltip(trigger = 'axis') %>%
      e_x_axis(date, axisPointer = list(show = TRUE)) %>% 
      e_y_axis(formatter = "{value}%") %>% 
      e_mark_point(data = list(type = 'max')) %>%
      e_legend(selectedMode = 'single') %>% 
      e_color(color = c(cores[[1]], cores[[2]])) %>% 
      e_datazoom(
        type = "slider", 
        toolbox = FALSE,
        bottom = -5
      )
  )
  
  
  # casos diários RO
  output$plot_novos_RO <- renderEcharts4r(
    covid_cidades %>% 
      filter(state == 'RO') %>% 
      group_by(date) %>% 
      summarise(caso_diario = sum(newCases),
                obito_diario = sum(newDeaths)) %>%
      melt('date') %>% 
      mutate(variable = recode(variable, caso_diario = 'Confirmados', 
                               obito_diario = 'Óbitos')) %>% 
      filter(value != 0) %>% 
      group_by(variable) %>%
      e_charts(x = date) %>% 
      e_line(value, lineStyle = list(symbol = 'square', width = 2, shadowBlur = 4, shadowOffsetY = 4)) %>% 
      #e_bar(value) %>% 
      e_mark_point(data = list(type = 'max')) %>%
      e_tooltip(trigger = 'axis') %>% 
      e_x_axis(date, axisPointer = list(show = TRUE)) %>% 
      e_color(color = c(cores[[1]], cores[[2]])) %>% 
      e_datazoom(
        type = "slider", 
        toolbox = FALSE,
        bottom = -5
      )
  )
  
  
  
  
  # --------- dados municipais --------------------
  
  top5_ro <- covid_cidades %>% 
    filter(state == 'RO',
           city != 'CASO SEM LOCALIZAÇÃO DEFINIDA/RO') %>% 
    group_by(city) %>% 
    summarise(total = sum(newCases)) %>% 
    top_n(n = 5, wt = total) %>% 
    arrange(desc(total)) %>% 
    pull(city)
  
  
  output$plot_cidades <- renderEcharts4r(
    covid_cidades %>% 
      filter(state == 'RO',
             city %in% top5_ro) %>% 
      group_by(date, city) %>% 
      summarise(casos = sum(totalCases)) %>% 
      group_by(city) %>% 
      e_charts(x = date) %>% 
      e_line(serie = casos, lineStyle = list(symbol = 'square', width = 2, shadowBlur = 4, shadowOffsetY = 4)) %>% 
      e_tooltip(trigger = 'axis') %>% 
      e_x_axis(date, axisPointer = list(show = TRUE)) %>% 
      e_datazoom(
        type = "slider", 
        toolbox = FALSE,
        bottom = -5
      )
  )
  
  
  output$top_obitos <- renderEcharts4r(
    covid_cidades %>% 
      group_by(city) %>% 
      filter(state == 'RO',
             city != 'CASO SEM LOCALIZAÇÃO DEFINIDA/RO') %>% 
      summarise(deaths = sum(newDeaths)) %>% 
      e_charts(x = city) %>% 
      e_treemap(parent = city, child = city, value = deaths) %>% 
      e_tooltip()
  )
  
  
  output$table_municipios <- DT::renderDataTable(
    covid_cidades %>%
      filter(state == 'RO',
             date == max(date)) %>%
      mutate(casos100k = round(totalCases_per_100k_inhabitants, 1),
             deaths_by_totalCases = round(deaths_by_totalCases*100, 1)) %>%
      select(city, totalCases, deaths, casos100k, deaths_by_totalCases) %>% 
      DT::datatable(rownames = FALSE,  # remove rownames
                    #style = "bootstrap",
                    class = "compact",
                    options = list(
                      dom = "tpf"  # specify content (search box, etc)
                    ),
                    colnames = c('Município' = 'city',
                                 'Casos' = 'totalCases',
                                 'Óbitos' = 'deaths',
                                 'Casos por 100 mil hab.' = 'casos100k',
                                 'Letalidade (%)' = 'deaths_by_totalCases'))
  )
  
  
  # perfil
  
  output$plot_idade <- renderEcharts4r(
    
    if(input$pretty_10){
      esus %>%
        filter(evolucao_caso %in% c('Cura', 'Obito')) %>% 
        group_by(evolucao_caso, Idade) %>% 
        summarise(Casos = n()) %>% 
        ungroup() %>% 
        mutate(evolucao_caso = recode(evolucao_caso, Obito = 'Óbito')) %>% 
        group_by(evolucao_caso) %>%
        e_charts(x = Idade, stack = 'grp') %>% 
        e_bar(serie = Casos) %>% 
        e_x_axis(name = 'Idade (em anos)', nameLocation = 'center', nameGap = 25,
                 min = 0, max = 100) %>% 
        e_tooltip(trigger = 'axis', axisPointer = list(type = 'shadow')) %>% 
        e_color(color = c(cores[[1]], cores[[2]])) 
    }
    
    else{
      esus %>%
        group_by(Idade) %>% 
        summarise(Casos = n()) %>% 
        e_charts(x = Idade, stack = 'grp') %>% 
        e_bar(serie = Casos) %>% 
        e_x_axis(name = 'Idade (em anos)', nameLocation = 'center', nameGap = 25) %>% 
        e_tooltip(trigger = 'axis', axisPointer = list(type = 'shadow')) %>% 
        e_color(color = cores[[4]]) %>% 
        e_legend(FALSE)
    }
  )
  
  output$plot_let_idade <- renderEcharts4r(
    merge(
      x = esus %>% 
            mutate(faixa_etaria = factor(findInterval(Idade, c(0, 9, 19, 29, 39, 49, 59, 69, 79, 89, 99)),
                                         labels = c('0-9', '10-19', '20-29', '30-39', '40-49',
                                                    '50-59', '60-69', '70-79', '80-89', '90+'))) %>% 
            group_by(evolucao_caso) %>% 
            count(faixa_etaria) %>% 
            filter(evolucao_caso == 'Obito'),
      y = esus %>% 
            mutate(faixa_etaria = factor(findInterval(Idade, c(0, 9, 19, 29, 39, 49, 59, 69, 79, 89, 99)),
                                         labels = c('0-9', '10-19', '20-29', '30-39', '40-49',
                                                    '50-59', '60-69', '70-79', '80-89', '90+'))) %>% 
            count(faixa_etaria),
          
          by.x = 'faixa_etaria', by.y = 'faixa_etaria') %>% 
      mutate(let = round(n.x*100/n.y, 1)) %>% 
      e_charts(x = faixa_etaria) %>% 
      e_line(serie = let, lineStyle = list(symbol = 'square', width = 3, shadowBlur = 4, shadowOffsetY = 4)) %>% 
      e_tooltip(trigger = 'axis') %>% 
      e_color(color = cores[[2]]) %>% 
      e_legend(FALSE) %>% 
      e_y_axis(formatter = '{value}%') %>% 
      e_labels(formatter = '{@[1]}%', 
               fontSize = 13, 
               backgroundColor = 'white')
  )
  
  # genero DOS INFECTADOS 
  
  esus %>% 
    group_by(Sexo) %>% 
    summarise(n = n()) %>% 
    filter(Sexo == 'Feminino') %>% pull() -> fem

  esus %>% 
    group_by(Sexo) %>% 
    summarise(n = n()) %>% 
    filter(Sexo == 'Masculino') %>% pull() -> masc
  
  # gênero
    output$plot_genero <- renderEcharts4r(
      esus %>%
      group_by(Sexo, evolucao_caso) %>%
      summarise(n = n()) %>% 
      filter(evolucao_caso != '') %>% 
      group_by(evolucao_caso) %>% 
      mutate(prop = round(n*100/sum(n), 1)) %>%
      ungroup() %>% 
      mutate(evolucao_caso = recode(evolucao_caso, Obito = 'Óbito')) %>% 
      group_by(Sexo) %>% 
      e_charts(x = evolucao_caso, stack = 'grp') %>% 
      e_bar(serie = prop, barGap = '1%',
            emphasis = list(itemStyle = list(shadowBlur = 10))) %>% 
      e_mark_line(data = list(xAxis = 50, silent = TRUE), 
                  lineStyle = list(color = 'orange', 
                                   width = 1,
                                   shadowBlur = 2),
                  label = list(formatter = '50%')) %>% 
      e_y_axis(formatter = '{value}%') %>% 
      e_tooltip() %>% 
      e_color(color = c(wes_palette("GrandBudapest1")[2], wes_palette("Darjeeling2")[2])) %>% 
      e_flip_coords() %>% 
      e_grid(left = '30%') %>% 
      # e_rect_g(top = 20, left = 20, shape = list(width = 140, height = 60), 
      #          style = list(stroke = '#555', fill = '#fff')) %>% 
      e_text_g(top = 20, left = 20, style = list(text = paste0('Feminino: ', fem, '\n',
                                                              'Masculino: ', masc),
                                                 font = '14px Microsoft YaHei',
                                                 fill = '#333',
                                                 lineWidth = 2))
      
      )
    
  
    
  
  output$pictorial <- renderEcharts4r(
    esus %>%
      group_by(Sexo, evolucao_caso) %>%
      summarise(n = n()) %>% 
      mutate(prop = round(n*100/sum(n), 1)) %>% 
      filter(evolucao_caso %in% c('Obito', 'Cura')) %>% 
      ungroup() %>% 
      mutate(evolucao_caso = recode(evolucao_caso, Obito = 'Óbito')) %>% 
      group_by(evolucao_caso) %>% 
      e_charts(x = Sexo, stack = 'grp') %>% 
      e_bar(serie = prop, barWidth = 90,
            emphasis = list(itemStyle = list(shadowBlur = 10))) %>% 
      e_labels(position = 'inside', formatter = "{@1}%", fontSize = 13) %>% 
      e_y_axis(formatter = '{value}%') %>% 
      e_grid(left = '20%') %>% 
      e_tooltip() %>% 
      e_color(color = c(cores[[1]], cores[[2]]))
  )
    
    
    
    
  
  
  #-------------------------------------------------------------
  # cenário nacional
  #-------------------------------------------------------------
  
  output$testes_br <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Testes realizados',
      value =   covid_total %>% 
        filter(state == 'TOTAL') %>% 
        select(tests),
      icon = 'vial',
      status = "primary"
    )
  )
  
  output$casos_br <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Casos confirmados',
      value =   covid_total %>% 
        filter(state == 'TOTAL') %>% 
        select(totalCasesMS),
      icon = 'check',
      status = "primary"
    )
  )
  
  output$municipios_br <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Municípios atingidos',
      value = covid_cidades %>% 
        filter(!grepl('CASO|TOTAL', city)) %>% 
        count(city) %>% 
        summarise(n_cidades = n()*100/5570) %>%
        mutate(n_cidades = paste0(round(n_cidades, 1), '%')) %>%
        pull(n_cidades),
      icon = 'map-marker-alt',
      status = 'primary'
    )
  )
  
  output$obitos_br <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Óbitos',
      value = covid_total %>% 
        filter(state == 'TOTAL') %>% 
        select(deathsMS),
      icon = 'skull',
      status = "danger"
    )
  )
  
  output$recuperados_br <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Recuperados',
      value =   covid_total %>% 
        filter(state == 'TOTAL') %>% 
        summarise(rec = paste0(recovered, ' ', '(', round(recovered*100/totalCasesMS, 1), '%)')) %>% 
        select(rec),
      icon = 'ambulance',
      status = "success"
    )
  )
  
  output$letalidade_br <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Taxa de letalidade',
      value = paste0(round( covid_total %>% 
                               filter(state == 'TOTAL') %>% 
                               summarise(let = deathsMS*100/totalCasesMS), 1), '%' ),
      icon = 'exclamation-circle',
      status = "danger"
    )
  )
  
  
  
  # casos por UF - mapa
  output$mapa_UF <- renderEcharts4r({

    brazil <- jsonlite::read_json("https://raw.githubusercontent.com/luizpedone/municipal-brazilian-geodata/master/data/Brasil.json")

    brazil$features <- brazil$features %>%
      purrr::map(function(x){
        x$properties$name <- x$properties$ESTADO # copy ESTADO to name for tooltip
        return(x)
      })

    covid_total %>%
      filter(state != 'TOTAL') %>%
      merge(y = ibge, by.x = 'state', by.y = 'Sigla') %>%
      rename(Casos = 'totalCasesMS') %>%
      e_charts(Estado) %>%
      # e_map_register("Brazil", brazil) %>%
      e_map(Casos, map = "Brazil", emphasis = list(itemStyle = list(shadowBlur = 3)),
            roam = TRUE, zoom = 1) %>%
      e_visual_map(Casos) %>%
      e_tooltip()
  })

  
  # cidades BR - tabela
  output$tabela_cidadesBR <- DT::renderDataTable(
    covid_cidades %>%
      filter(state != 'TOTAL') %>% 
      group_by(city) %>%
      summarise(casos = sum(newCases),
                obitos = sum(newDeaths),
                casos100k = round(max(totalCases_per_100k_inhabitants), 1)) %>%
      #filter(city != 'CASO SEM LOCALIZAÇÃO DEFINIDA/RO') %>% 
      DT::datatable(rownames = FALSE,  # remove rownames
                    #style = "bootstrap",
                    class = "compact",
                    options = list(
                      dom = "tpf",  # specify content (search box, etc)
                      scrollY = 360,
                      scroller = TRUE
                    ),
                    colnames = c('Município' = 'city',
                                 'Casos' = 'casos',
                                 'Óbitos' = 'obitos',
                                 'Casos por 100 mil hab.' = 'casos100k'))
  )
  
  
  # casos acumulados BR
  output$plot_acumulados_br <- renderEcharts4r(
    covid_cidades %>%
      filter(state != 'TOTAL') %>% 
      group_by(date) %>%
      summarise(casosAcumulados = sum(totalCases)) %>% 
      melt('date') %>% 
      mutate(variable = recode(variable, casosAcumulados = 'Casos confirmados')) %>% 
      group_by(variable) %>% 
      #filter(data > '2020-02-25') %>% 
      e_charts(x = date) %>%
      #e_line(value, lineStyle = list(symbol = 'square', width = 3, shadowBlur = 4, shadowOffsetY = 4), areaStyle = TRUE) %>% 
      e_bar(value) %>% 
      e_mark_point(data = list(type = 'max')) %>% 
      e_tooltip(trigger = 'axis') %>% 
      e_x_axis(date, axisPointer = list(show = TRUE)) %>% 
      e_y_axis(type = ifelse(input$log, "log", "value")) %>% 
      e_color(color = cores[[4]]) %>% 
      e_legend(FALSE) %>% 
      e_grid(left = '20%') %>% 
      e_datazoom(
        type = "slider", 
        toolbox = FALSE,
        bottom = -5
      )
    
  )
  
  # óbitos acumulados BR
  output$plot_obitos_br <- renderEcharts4r(
    
    if(input$pretty_obitos_br){
      covid_cidades %>% 
        filter(state == 'TOTAL') %>% 
        select(date, totalCases, deaths) %>%
        group_by(date) %>% 
        summarise(casos_diario = sum(totalCases),
                  obitos_diario = sum(deaths)) %>% 
        mutate(let = round(obitos_diario*100/casos_diario, 2)) %>% 
        filter(let != 0) %>% 
        select(date, let) %>% 
        melt('date') %>% 
        mutate(variable = recode(variable, let = 'Taxa de letalidade')) %>% 
        e_charts(x = date) %>% 
        e_line(serie = value,
               lineStyle = list(width = 3, shadowBlur = 4, shadowOffsetY = 4),
               areaStyle = TRUE) %>%
        e_mark_point(data = list(type = 'max')) %>% 
        e_tooltip(trigger = 'axis') %>% 
        e_x_axis(date, axisPointer = list(show = TRUE)) %>% 
        e_color(color = cores[[2]]) %>% 
        e_legend(FALSE) %>% 
        e_datazoom(
          type = "slider", 
          toolbox = FALSE,
          bottom = -5
        )  
    }
    
    else{
      covid_cidades %>% 
        filter(state == 'TOTAL') %>% 
        select(date, totalCases, deaths) %>%
        group_by(date) %>% 
        summarise(obitos_diario = sum(deaths)) %>% 
        select(date, obitos_diario) %>% 
        melt('date') %>% 
        mutate(variable = recode(variable, obitos_diario = 'Óbitos')) %>% 
        group_by(variable) %>% 
        e_charts(x = date) %>% 
        e_bar(value) %>% 
        e_mark_point(data = list(type = 'max')) %>% 
        e_tooltip(trigger = 'axis') %>% 
        e_x_axis(date, axisPointer = list(show = TRUE)) %>% 
        e_color(color = cores[[2]]) %>% 
        e_legend(FALSE) %>% 
        e_datazoom(
          type = "slider", 
          toolbox = FALSE,
          bottom = -5
        )
    }
    
  )
  
  output$plot_novos_br <- renderEcharts4r(
    covid_cidades %>% 
      filter(state != 'TOTAL') %>% 
      group_by(date) %>% 
      summarise(casos_diarios = sum(newCases),
                obitos_diarios = sum(newDeaths)) %>% 
      melt('date') %>% 
      mutate(variable = recode(variable, casos_diarios = 'Casos novos',
                               obitos_diarios = 'Óbitos novos')) %>% 
      group_by(variable) %>% 
      e_charts(x = date) %>% 
      e_line(serie = value, lineStyle = list(width = 3, shadowBlur = 4, shadowOffsetY = 4),
             areaStyle = TRUE) %>% 
      e_tooltip(trigger = 'axis') %>% 
      e_x_axis(date, axisPointer = list(show = TRUE)) %>% 
      e_color(color = c(cores[[4]], cores[[2]])) %>% 
      e_datazoom(
        type = "slider", 
        toolbox = FALSE,
        bottom = -5
      )
  )
  
  
  # veja as regiões
  norte <- c("AM", "RO", "RR", "PA", "AC", "TO", "AP")
  nordeste <- c("PE", "SE", "PB", "RN", "BA", "CE", "PI", "MA", "AL")
  sul <- c("RS", "SC", "PR")
  centro <- c("DF", "GO", "MS", "MT")
  sudeste <- c("SP", "RJ", "MG", "ES")
  
  covid_total['regiao'] <- 'NULL'
  covid_total$regiao[covid_total$state %in% norte] <- 'Norte'
  covid_total$regiao[covid_total$state %in% nordeste] <- 'Nordeste'
  covid_total$regiao[covid_total$state %in% sul] <- 'Sul'
  covid_total$regiao[covid_total$state %in% sudeste] <- 'Sudeste'
  covid_total$regiao[covid_total$state %in% centro] <- 'Centro-Oeste'
  
  output$barplot_regioes <- renderEcharts4r(
    covid_total %>%
      filter(state != 'TOTAL') %>%
      group_by(regiao) %>%
      summarise(casos = sum(totalCasesMS),
                obitos = sum(deathsMS)) %>%
      melt('regiao') %>%
      mutate(variable = recode(variable, casos = 'Casos confirmados',
                               obitos = 'Óbitos')) %>%
      group_by(variable) %>%
      e_charts(x = regiao) %>%
      e_bar(serie = value, barGap = 0) %>%
      e_labels() %>%
      e_tooltip(trigger = 'axis', axisPointer = list(type = 'shadow')) %>% 
      e_color(color = c(cores[[4]], cores[[2]])) 
  )
  
  covid_cidades['regiao'] <- 'NULL'
  covid_cidades$regiao[covid_cidades$state %in% norte] <- 'Norte'
  covid_cidades$regiao[covid_cidades$state %in% nordeste] <- 'Nordeste'
  covid_cidades$regiao[covid_cidades$state %in% sul] <- 'Sul'
  covid_cidades$regiao[covid_cidades$state %in% sudeste] <- 'Sudeste'
  covid_cidades$regiao[covid_cidades$state %in% centro] <- 'Centro-Oeste'
  
  
  # plot UF regiões
  output$plot_regioes <- renderEcharts4r(
    covid_cidades %>%
      filter(regiao == input$regioes) %>%
      group_by(date, state) %>%
      summarise(Casos = ifelse(input$casosLog, log(sum(totalCases)), sum(totalCases))) %>%
      group_by(state) %>%
      e_charts(x = date) %>%
      e_line(serie = Casos, lineStyle = list(width = 3)) %>%
      e_tooltip(trigger = 'axis') %>%
      e_x_axis(date, axisPointer = list(show = TRUE)) %>%
      e_datazoom(
        type = "slider",
        toolbox = FALSE,
        bottom = -5
      )
  )
  
  # letalidade regiões
  
  output$let_regiao <- renderEcharts4r(
    covid_total %>%
      filter(state != 'TOTAL') %>% 
      group_by(regiao) %>%
      summarise(rec = round(sum(recovered, na.rm = TRUE)*100/sum(totalCasesMS), 1), 
                let = round(sum(deathsMS)*100/sum(totalCasesMS), 1)) %>% 
      melt('regiao') %>% 
      mutate(variable = recode(variable, rec = 'Recuperação', let = 'Letalidade')) %>% 
      group_by(variable) %>% 
      e_charts(x = regiao) %>% 
      e_line(serie = value, lineStyle = list(width = 3, shadowBlur = 2, shadowOffsetY = 2)) %>% 
      e_labels(formatter = '{@[1]}%', 
               fontSize = 13, 
               backgroundColor = 'white') %>% 
      e_color(color = c(cores[[1]], cores[[2]])) %>% 
      e_y_axis(formatter = '{value}%')
  )
  
  
  #--------------------- estudo IBGE --------------------------
  # LEITOS UTI 2019
  estudo_ibge <- fread('https://raw.githubusercontent.com/caiolif/covid19ro/master/estudo_ibge.txt', encoding = 'UTF-8', dec = ',')

  output$n_leitos <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Leitos de UTI',
      value = estudo_ibge %>%
        summarise(total = sum(Leitos_UTI_Total)),
      icon = 'procedures'
    )
  )
  
  output$mapa_leitos <- renderEcharts4r(
    estudo_ibge %>%
      mutate(Leitos = round(Leitos_UTI_100mil_hab_Ind, 1)) %>%
      e_charts(Nome_municipio) %>%
      # e_map_register("Rondonia", rondonia) %>%
      e_map(Leitos, map = "Rondonia", emphasis = list(itemStyle = list(shadowBlur = 3))) %>%
      e_visual_map(Leitos) %>%
      e_tooltip()
  )
  
  
  # RESPIRADORES 2019
  output$n_respiradores <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Respiradores',
      value = estudo_ibge %>% 
                summarise(total = sum(Total_Respiradores)),
      icon = 'medkit'
    )
  )
  output$mapa_respiradores <- renderEcharts4r(
    estudo_ibge %>%
      mutate(Respiradores = round(Respiradores_100mil_hab_Ind, 1)) %>%
      e_charts(Nome_municipio) %>%
      # e_map_register("Rondonia", rondonia) %>%
      e_map(Respiradores, map = "Rondonia", emphasis = list(itemStyle = list(shadowBlur = 3))) %>%
      e_visual_map(Respiradores) %>%
      e_tooltip()
  )

  
  # ENFERMEIROS 2019
  output$n_enfermeiros <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Enfermeiros',
      value = estudo_ibge %>%
        summarise(total = sum(Total_Enfermeiros)),
      icon = 'user-md'
    )
  )
  
  output$mapa_enfermeiros <- renderEcharts4r(
    estudo_ibge %>%
      mutate(Enfermeiros = round(Enfermeiros_100mil_hab_Ind, 1)) %>%
      e_charts(Nome_municipio) %>%
      # e_map_register("Rondonia", rondonia) %>%
      e_map(Enfermeiros, map = "Rondonia", emphasis = list(itemStyle = list(shadowBlur = 3))) %>%
      e_visual_map(Enfermeiros) %>%
      e_tooltip()
  )
  
  # MÉDICOS 2019
  output$n_medicos <- renderbs4InfoBox(
    bs4InfoBox(
      title = 'Médicos',
      value = estudo_ibge %>%
        summarise(total = sum(Total_Medicos)),
      icon = 'user-md'
    )
  )
  
  output$mapa_medicos <- renderEcharts4r(
    estudo_ibge %>%
      mutate(Médicos = round(Medicos_100mil_hab_Ind, 1)) %>%
      e_charts(Nome_municipio) %>%
      # e_map_register("Rondonia", rondonia) %>%
      e_map(Médicos, map = "Rondonia", emphasis = list(itemStyle = list(shadowBlur = 3))) %>%
      e_visual_map(Médicos) %>%
      e_tooltip()
  )
  
  
  output$insumos_ro <- DT::renderDataTable(
    estudo_ibge %>% 
      select(Nome_municipio, Leitos_UTI_Total, Total_Respiradores, Total_Enfermeiros, Total_Medicos) %>%
      DT::datatable(rownames = FALSE,  
                    #style = "bootstrap",
                    class = "compact",
                    options = list(
                      dom = "tpf"  # specify content (search box, etc)
                    ),
                    colnames = c('Município' = 'Nome_municipio',
                                 'Leitos de UTI' = 'Leitos_UTI_Total',
                                 'Respiradores' = 'Total_Respiradores',
                                 'Enfermeiros' = 'Total_Enfermeiros',
                                 'Médicos' = 'Total_Medicos'))
  )

  
  
}

