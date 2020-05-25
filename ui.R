
#################################################
#            UI 
#################################################

addResourcePath("www", "www")


navbar <- bs4DashNavbar(column(12, div(img(src = 'brasao.png', width = 55, height = 65), 
                            "Painel de Monitoramento COVID-19", 
                            img(src = 'alero_icone.png', width = 75, height = 55),
                            style = 'margin: 0 5em 0 10em')),
                        skin = 'dark')

sidebar <- bs4DashSidebar(
  
  skin = 'dark',
  status = 'primary',
  title = 'Bem-vindo ao painel!',
  brandColor = "primary",
  #url = "https://www.google.fr",
  src = "https://image.flaticon.com/icons/svg/1149/1149168.svg",
  # bs4SidebarUserPanel(
  #   img = "https://image.flaticon.com/icons/svg/1149/1149168.svg", 
  #   text = "Bem-vindo ao painel!" )
  
  
  bs4SidebarMenu(
    
    bs4SidebarHeader(title = "Menu"),
    
    bs4SidebarMenuItem(text = 'Página Inicial', tabName = 'sobre', icon = 'home'),
    
    bs4SidebarMenuItem(text = 'Sobre a COVID-19', tabName = 'covid19', icon = 'vial'), 
    
    bs4SidebarMenuItem(text = 'Cenário Estadual', tabName = 'estadual_geral', icon = 'chart-bar',
             bs4SidebarMenuSubItem('Dados Gerais', tabName = 'dados_gerais', icon = 'angle-right'),
             bs4SidebarMenuSubItem('Compare os municípios', tabName = 'dados_municipios', icon = 'angle-right'),
             bs4SidebarMenuSubItem('Perfil dos infectados', tabName = 'dados_perfil', icon = 'angle-right')),
             #bs4SidebarMenuItem('Ocupação de leitos', tabName = 'leitos', icon = 'angle-right')),
    
    bs4SidebarMenuItem(text = 'Cenário Nacional', tabName = 'nacional', icon = 'chart-bar',
                       bs4SidebarMenuSubItem('Dados Gerais', tabName = 'dados_gerais_BR', icon = 'angle-right'),
                       bs4SidebarMenuSubItem('Compare as regiões', tabName = 'regioes', icon = 'angle-right')),
    
    bs4SidebarMenuItem(text = 'Estudo de Apoio - IBGE',
                       tabName = 'recursos_ibge',
                       icon = 'hospital'),
    
    #bs4SidebarMenuItem(text = 'Mobilidade Pública', tabName = 'mobilidade', icon = 'hospital'),
    
    bs4SidebarMenuItem(text = 'Ações de Combate/ALE-RO',
                       tabName = 'combate',
                       icon = 'hands'),
    
    bs4SidebarMenuItem(text = 'Links Úteis', tabName = 'link', icon = 'link')
    
    
  )
)

body <- bs4DashBody(
    
    bs4TabItems(
      bs4TabItem('sobre',
                 tagList(
                   # asynchronously register the map of Rondonia _once_
                   e_map_register_ui("Rondonia", "www/rondonia.json", async = TRUE),
                   tags$img(src = 'home-banner.jpg', height = 200, width = 1040, align = 'center'),
                   
                   #bs4Box(
                    # width = 12,
                     tags$p(
                       h4('Apresentação'),
                       style="text-align: justify;",
                       'A proposta deste painel é apresentar um monitoramento dos casos da COVID-19, diariamente, sendo um veículo alternativo de divulgação de casos e auxílio nas ações de enfrentamento de combate à doença. O painel está sujeito a alterações, podendo apresentar informações adicionais ou modificação nas mesmas.',
                       br(), br(),
                       
                       h4('Fontes de dados'),
                       style="text-align: justify;",
                       'É importante ressaltar que os dados apresentados no painel são extraídos de fontes externas, portanto, a atualização das informações depende das fontes citadas a seguir:',
                       br(), br(),
                       
                       tags$ul(
                         style="text-align: justify;",
                         tags$li(style="text-align: justify;", HTML(paste('Os dados dos níveis municipal e nacional são provenientes do',
                                                                          tags$a(href = 'https://brasil.io/dataset/covid19/caso/', 'Brasil.io'),
                                                                          'e',
                                                                          tags$a(href = 'https://covid.saude.gov.br/', 'Ministério da Saúde'),
                                                                          ', respectivamente, organizados pelo pesquisador Wesley Cota e equipe, com acesso 
                                                                          disponível',
                                                                          tags$a(href = 'https://github.com/wcota/covid19br', 'aqui'),
                                                                          '.',
                                                                          br(),
                                                                          'Os casos de indivíduos recuperados foram obtidos através da',
                                                                          tags$a(href = 'https://docs.google.com/spreadsheets/d/1MWQE3s4ef6dxJosyqvsFaV4fDyElxnBUB6gMGvs3rEc/edit#gid=1503196283', 'planilha'),
                                                                          'atualizada pelo',
                                                                          tags$a(href = 'https://twitter.com/CoronavirusBra1', '@CoronavirusBra1'),
                                                                          'por meio de boletins de cada estado. Não há informações para SC, GO e MG.
                                    Novos números de SP não foram divulgados recentemente pela secretaria da saúde.'))),
                         
                         br(),
                         
                         tags$li(HTML(paste('Os dados relacionados ao gênero e faixa etária dos indivíduos infectados foram obtidos através do Painel COVID-19 da', 
                                            tags$a(href = 'http://covid19.sesau.ro.gov.br/', 'AGEVISA/SESAU'), 'do estado de Rondônia.
                                    Conforme a AGEVISA, os dados não são lidos e atualizados imediatamente pelo Centro de Informações Estratégicas em Vigilância em Saúde (Cievs), por isso há atraso (delay) no registro de casos que estão sendo acompanhados diariamente por equipes de saúde nos municípios.'))),
                         
                         br(),
                         
                         tags$li(HTML(paste(
                           'Os dados do estudo da distribuição de leitos de UTI, respiradores, enfermeiros e médicos no ano de 2019, realizado pelo IBGE, está disponível neste',
                           tags$a(href = 'https://mapasinterativos.ibge.gov.br/covid/saude/', 'link'),
                           '.'
                         )))
                       ),
                       
                       h4('Limitações'),
                       style="text-align: justify;",
                       'O grande desafio das diversas fontes de dados é obter informações atualizadas e fidedignas diariamente.
                Diante da complexidade em divulgar os dados atualizados, optou-se por utilizar o respositório
                disponibilizado pelo pesquisador Wesley Cota e sua equipe.
                       Tal repositório é atualizado diariamente pela equipe, que
                buscam dados divulgados pelas Secretarias de Saúde de cada estado através dos seus respectivos boletins diários.',
                       br(), br(),
                       'Até o momento do desenvolvimento deste painel, o Ministério da Saúde não tem divulgado os casos
              diários a nível municipal.',
                       br(), br(),
                       'Para acompanhar a ocupação de leitos no estado,  acesse o',
                       HTML(paste0(tags$a(href = 'http://covid19.sesau.ro.gov.br/', 'Painel da SESAU'))), '.')
                   )
                 ),
      #),
      
      bs4TabItem('covid19',
                 #bs4Box(
                   width = 12,
                   h4('Definição'),
                   tags$p(
                     style = "text-align: justify;",
                     'COVID-19 é a doença infecciosa causada pelo novo coronavírus, identificado pela primeira vez em dezembro de 2019, em Wuhan, na China.'),
                   
                   br(),
                   
                   h4('Surgimento'),
                   tags$p(
                     style="text-align: justify;",
                     'Em 31 de dezembro de 2019, a Organização Mundial da Saúde (OMS) foi alertada sobre vários casos de pneumonia na cidade de Wuhan, província de Hubei, na República Popular da China. Tratava-se de uma nova cepa (tipo) de coronavírus que não havia sido identificada antes em seres humanos.',
                     br(), br(),
                     'Em 30 de janeiro de 2020, a OMS declarou que o surto do novo coronavírus constitui uma Emergência de Saúde Pública de Importância Internacional (ESPII) - 
                     o mais alto nível de alerta da Organização, conforme previsto no Regulamento Sanitário Internacional. Essa decisão buscou aprimorar a coordenação, a cooperação e a solidariedade global para interromper a propagação do vírus. 
                     Essa decisão aprimora a coordenação, a cooperação e a solidariedade global para interromper a propagação do vírus.'),
                   
                   br(),
                   
                   h4('Sintomas'),
                   tags$p(style="text-align: justify;", 'Se uma pessoa tiver sintomas menores, como tosse leve ou febre leve, geralmente não há necessidade de procurar atendimento médico. O ideal é ficar em casa, fazer autoisolamento (conforme as orientações das autoridades nacionais) e monitorar os sintomas. Procure atendimento médico imediato se tiver dificuldade de respirar ou dor/pressão no peito.'),
                   
                   br(),
                   
                   h4('Prevenção'),
                   tags$p(style="text-align: justify;", 'Lavar as mãos frequentemente com água e sabão ou álcool em gel e cobrir a boca com o antebraço quando tossir ou espirrar (ou utilize um lenço descartável e, após tossir/espirrar, jogue-o no lixo e lave as mãos).'),
                   
                   tags$p('Fonte:', HTML(paste0(tags$a(href = 'https://www.paho.org/bra/index.php?option=com_content&view=article&id=6101:covid19&Itemid=875', 'Organização Pan-Americana da Saúde (OPAS)')))),
                   
                   h4('Entenda mais sobre o vírus'),
                   HTML('<iframe width="970" height="600" src="https://www.youtube.com/embed/9Z70QF8OMZQ" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>')
                  
                 #)
      ),
    
    bs4TabItem('dados_gerais', 
            tagList(
              p('Última atualização em:', format(Sys.time(), '%d/%m/%Y')),
              fluidRow(
                        bs4Box(
                          title = 'Sumário Geral',
                          background = NULL,
                          width = 12,
                          fluidRow(
                            bs4InfoBoxOutput(
                              outputId = 'testes'
                            ),
                            bs4InfoBoxOutput(
                              outputId = 'casos'
                            ),
                            bs4InfoBoxOutput(
                              outputId = 'municipios'
                            ), 
                            bs4InfoBoxOutput(
                              outputId = 'recuperados'
                            ),
                            bs4InfoBoxOutput(
                              outputId = 'obitos'
                            ),
                            bs4InfoBoxOutput(
                              outputId = 'letalidade'
                            ) 
                          )
                        )
                      ),
                      fluidRow(
                      bs4Box(
                        title = 'Casos confirmados por município',
                        width = 6,
                        height = 550,
                        closable = FALSE,
                        collapsible = TRUE,
                        withSpinner(echarts4rOutput('mapa_ro'), type = 6)
                      ),
                      bs4Box(
                        title = 'Casos acumulados',
                        width = 6,
                        height = 550,
                        closable = FALSE,
                        collapsible = TRUE,
                        materialSwitch(inputId = "log", label = "Escala logarítmica", 
                                       status = "danger"),
                        withSpinner(echarts4rOutput('plot_acumulados'), type = 6)
                      )),
              
                      fluidRow(
                      bs4Box(
                        title = 'Casos novos',
                        width = 6,
                        closable = FALSE,
                        collapsible = TRUE,
                        withSpinner(echarts4rOutput('plot_novos_RO'), type = 6)
                      ),
                      
                      bs4Box(
                        title = 'Variação dos casos acumulados (%)',
                        width = 6,
                        closable = FALSE,
                        withSpinner(echarts4rOutput('variacao_ro'), type = 6)
                      )),

                      fluidRow(
                        bs4Box(
                          width = 2,
                          prettyRadioButtons(inputId = "plot_obitos_ro", label = '',
                                             choices = list("Óbitos acumulados" = 'Óbitos',
                                                            "Taxa de Letalidade" = 'Letalidade'),
                                             icon = icon("check"),
                                             animation = 'jelly',
                                             selected = 'Óbitos')
                        ),
                      bs4Box(
                        title = 'Monitoramento dos óbitos',
                        width = 10,
                        closable = FALSE,
                        collapsible = TRUE,
                        solidHeader = FALSE,
                        withSpinner(echarts4rOutput('plot_obitos'), type = 6),
                        enable_sidebar = TRUE,
                        sidebar_width = 25,
                        sidebar_content = tagList(
                          prettyRadioButtons(inputId = "plot_obitos_ro", label = '',
                                             choices = list("Óbitos acumulados" = 'Óbitos',
                                                            "Taxa de Letalidade" = 'Letalidade'),
                                             icon = icon("check"),
                                             animation = 'jelly',
                                             selected = 'Óbitos')
                        )
                      )
              )
            )), #fim subitem1
    
    bs4TabItem('dados_municipios',
            tagList(fluidRow( 
                        bs4Box(
                          title = 'Top 5 dos municípios com mais casos confirmados',
                          withSpinner(echarts4rOutput('plot_cidades'), type = 6)
                        ),
                        bs4Box(
                          title = 'Óbitos por município',
                          withSpinner(echarts4rOutput('top_obitos'), type = 6)
                        )
            ),
                      fluidRow(
                        bs4Box(
                          width = 12,
                          withSpinner(DT::dataTableOutput('table_municipios'), type = 6)
                        )
            ))
    ), # fim municipios
          
    bs4TabItem('dados_perfil',
               tagList(
                 fluidRow(
                        bs4Box(
                          width = 8,
                          title = 'Casos por gênero',
                          withSpinner(echarts4rOutput('plot_genero'), type = 6)
                        ),
                        
                        bs4Box(
                          width = 4,
                          title = 'Cura e Letalidade por gênero',
                          withSpinner(echarts4rOutput('pictorial'), type = 6)
                        )),
                        
                        fluidRow(
                          bs4Box(
                            height = 550,
                            title = 'Casos por Idade',
                            prettyCheckbox(inputId = "pretty_10", label = "Cura e Óbitos",
                                           status = "info", shape = 'curve', animation = 'jelly'),
                            withSpinner(echarts4rOutput('plot_idade'), type = 6)
                          ),
                        
                          bs4Box(
                            height = 550,
                            title = 'Letalidade por faixa etária',
                            withSpinner(echarts4rOutput('plot_let_idade'), type = 6)
                          )
                      )
            )
    ), # fecha dados_perfil
    
    bs4TabItem('leitos',
               blockQuote('Em atualização...')),
    
    
    bs4TabItem('dados_gerais_BR',
            tagList(fluidRow(
                        bs4Box(
                          title = 'Sumário Geral',
                          background = NULL,
                          width = 12,
                          fluidRow(
                            bs4InfoBoxOutput(
                              outputId = 'testes_br'
                            ),
                            bs4InfoBoxOutput(
                              outputId = 'casos_br'
                            ),
                            bs4InfoBoxOutput(
                              outputId = 'municipios_br'
                            ),
                            bs4InfoBoxOutput(
                              outputId = 'recuperados_br'
                            ),
                            bs4InfoBoxOutput(
                              outputId = 'obitos_br'
                            ),
                            bs4InfoBoxOutput(
                              outputId = 'letalidade_br'
                            )
                          )
                        )),
                      
                      fluidRow(
                        bs4Box(
                          width = 6,
                          height = 550,
                          title = 'Casos por Unidade de Federação',
                          withSpinner(echarts4rOutput('mapa_UF'), type = 6)
                        ),
                        bs4Box(
                          title = 'Casos acumulados',
                          width = 6,
                          height = 550,
                          materialSwitch(inputId = "log", label = "Escala logarítmica", 
                                         status = "danger"),
                          withSpinner(echarts4rOutput('plot_acumulados_br'), type = 6)
                        )),
                      
                      fluidRow(
                        bs4Box(
                          title = 'Casos novos',
                          width = 12,
                          withSpinner(echarts4rOutput('plot_novos_br'), type = 6)
                        )

                      ),
                      
                      fluidRow(
                        bs4Box(
                          title = 'Monitoramento dos óbitos',
                          width = 12,
                          prettyCheckbox(inputId = "pretty_obitos_br", label = "Taxa de letalidade", 
                                         status = "danger", shape = 'curve', animation = 'jelly'),
                          withSpinner(echarts4rOutput('plot_obitos_br'), type = 6)
                        ),
                      ),
                      
                      fluidRow(
                        bs4Box(
                          width = 12,
                          withSpinner(DT::dataTableOutput('tabela_cidadesBR'), type = 6)
                        )
                      )

            )
    ), # fecha item 'nacional'
    
    bs4TabItem('regioes',
            tagList(fluidRow(
                bs4Box(
                  title = 'Casos por região',
                  width = 12,
                  withSpinner(echarts4rOutput('barplot_regioes'), type = 6)
                )
              ),
              fluidRow(
                bs4Box(
                  width = 2,
                  height = 550,
                  prettyRadioButtons("regioes", label = 'Região:',
                               choices = list("Norte" = 'Norte', 
                                              "Nordeste" = 'Nordeste',
                                              "Centro-Oeste" = 'Centro-Oeste',
                                              'Sudeste' = 'Sudeste',
                                              'Sul' = 'Sul'),
                               icon = icon("check"),
                               animation = 'jelly',
                               selected = 'Norte'),
                  #width = 2,
                  prettyRadioButtons('casosLog', label = 'Escala:',
                               choices = list('Linear' = FALSE,
                                              'Logarítmica' = TRUE),
                               selected = FALSE,
                               animation = 'jelly',
                               icon = icon('check'))
                ),
                bs4Box(
                  height = 550,
                  title = 'Casos acumulados por UF',
                  width = 10,
                  closable = FALSE,  
                  withSpinner(echarts4rOutput('plot_regioes'), type = 6)
                ),
                bs4Box(
                  title = 'Letalidade por região',
                  width = 12,
                  closable = FALSE,
                  withSpinner(echarts4rOutput('let_regiao'), type = 6)
                )
              )
            )
    ),
    
    bs4TabItem('recursos_ibge',
               tagList(
                 fluidRow(
                        bs4Box(
                          width = 12,
                          tags$p('O Instituto Brasileiro de Geografia e Estatística (IBGE), em parceria com a Fundação Oswaldo Cruz (FIOCRUZ),
                            divulgou no dia 07 de maio de 2020 um estudo sobre a distribuição de leitos de UTIs, respiradores, enfermeiros e médicos
                            por unidade de federação no ano de 2019, a fim de contribuir com as ações de enfrentamento à COVID-19. 
                            Para mais informações acesse', HTML(paste0(tags$a(href = 'https://mapasinterativos.ibge.gov.br/covid/saude/', 'https://mapasinterativos.ibge.gov.br/covid/saude/'), '.')))
                        )),
                 
                 bs4Box(
                   title = 'Números gerais de Rondônia em 2019',
                   width = 12,
                   fluidRow(
                      bs4InfoBoxOutput(outputId = 'n_leitos', width = 3),
                      bs4InfoBoxOutput(outputId = 'n_respiradores', width = 3),
                      bs4InfoBoxOutput(outputId = 'n_enfermeiros', width = 3),
                      bs4InfoBoxOutput(outputId = 'n_medicos', width = 3)
                   )
                 ),
                 
                 fluidRow(
                 bs4Box(
                   #title = 'Rondônia no rank nacional',
                   width = 6,
                   status = 'primary',
                   cardProfile(
                     src = 'https://www.pinpng.com/pngs/m/269-2696301_mapa-brasil-png-brazil-flag-map-transparent-png.png',
                     title = 'Rondônia no rank nacional',
                     subtitle = 'Número de leitos de UTIs, respiradores, enfermeiros e médicos por 100 mil habitantes (2019) entre as unidades de federação do país',
                     cardProfileItemList(
                       bordered = TRUE,
                       cardProfileItem(
                         title = 'Leitos de UTI',
                         description = '12º'
                       ),
                       cardProfileItem(
                         title = 'Respiradores',
                         description = '12º'
                       ),
                       cardProfileItem(
                         title = 'Enfermeiros',
                         description = '21º'
                       ),
                       cardProfileItem(
                         title = 'Médicos',
                         description = '17º'
                       )
                     )
                   )
                 ),
                 
                 bs4Box(
                   #title = 'Rondônia no rank regional',
                   width = 6,
                   status = 'primary',
                   cardProfile(
                     src = 'data:image/png;base64,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',
                     title = 'Rondônia no rank regional',
                     subtitle = 'Número de leitos de UTIs, respiradores, enfermeiros e médicos por 100 mil habitantes (2019) entre as unidades de federação da região norte',
                     cardProfileItemList(
                       bordered = TRUE,
                       cardProfileItem(
                         title = 'Leitos de UTI',
                         description = '1º'
                       ),
                       cardProfileItem(
                         title = 'Respiradores',
                         description = '1º'
                       ),
                       cardProfileItem(
                         title = 'Enfermeiros',
                         description = '5º'
                       ),
                       cardProfileItem(
                         title = 'Médicos',
                         description = '2º'
                       )
                     )
                   )
                 )
                 
               ),
               
               fluidRow(
                 bs4Box(
                   width = 6,
                   title = 'Mapa de Leitos de UTI por 100 mil habitantes',
                   closable = FALSE,  
                   withSpinner(echarts4rOutput('mapa_leitos'), type = 6)
                 ),
                 
                 bs4Box(
                   width = 6,
                   title = 'Mapa de respiradores por 100 mil habitantes',
                   closable = FALSE,  
                   withSpinner(echarts4rOutput('mapa_respiradores'), type = 6)
                 )),
               
               fluidRow(
               bs4Box(
                 width = 6,
                 title = 'Mapa de enfermeiros por 100 mil habitantes',
                 closable = FALSE,  
                 withSpinner(echarts4rOutput('mapa_enfermeiros'), type = 6)
               ),
               bs4Box(
                 width = 6,
                 title = 'Mapa de médicos por 100 mil habitantes',
                 closable = FALSE,  
                 withSpinner(echarts4rOutput('mapa_medicos'), type = 6)
               )
               ),
               
               fluidRow(
                 bs4Box(
                   width = 12,
                   closable = FALSE,
                   withSpinner(DT::dataTableOutput('insumos_ro'), type = 6)
                 )
               )
               )),
    
    bs4TabItem('combate',
              tagList(
                bs4Box(
                 title = 'Ações de Combate ao COVID-19',
                 width = 12,
                 tags$ul(
                   tags$li(
                     HTML(paste0(tags$a(href = 'http://transparencia.al.ro.leg.br/LicitacoesContratos/Licitacoes/detalhes/223',
                                 'Chamamento Público Nº 001/2020/ALE-RO - Processo Adminstrativo Nº 0005570/2020-45')))
                   ),
                   
                   tags$li(
                     HTML(paste0(tags$a(href = 'http://transparencia.al.ro.leg.br/LicitacoesContratos/Licitacoes/detalhes/224',
                                 'Chamamento Público Nº 002/2020/ALE-RO - Processo Adminstrativo Nº 0005646/2020-45')))
                   )
                 )
                )
              )         
      
    ),
    
    bs4TabItem('link',
               tagList(
                blockQuote(
                  tags$p('Acesse a', HTML(paste0(tags$a(href = 'https://www.paho.org/bra/index.php?option=com_content&view=article&id=6101:covid19&Itemid=875',
                                                        'Folha Informativa'))),
                         'da Organização Pan-Americana da Saúde/Organização Mundial da Saúde (OPAS/OMS) 
                         para obter informações a respeito da origem, sintomas e prevenção da COVID-19, e esclarecer dúvidas.')
                ),
                
                blockQuote(
                  tags$p('Para acompanhar a ocupação dos leitos e outras informações do cenário estadual acesse o',
                         HTML(paste0(tags$a(href = 'http://covid19.sesau.ro.gov.br/',
                                            'Painel da SESAU'), '.')))
                ),
                blockQuote(
                  tags$p('Para mais informações do cenário nacional acesse o',
                         HTML(paste0(tags$a(href = 'https://covid.saude.gov.br/',
                                            'Painel do Ministério da Saúde'), '.')))
                ),
                blockQuote(
                  tags$p('Acompanhe cenário mundial através da página',
                         HTML(paste0(tags$a(href = 'https://www.worldometers.info/coronavirus/', 'worldometers.info'), '.')))
                  
                )
                
               )
    )
    
  ) # fecha tabItems
  
) # fecha o body

footer <- bs4DashFooter(
   '© Divisão das Comissões/Secretaria Legislativa'
 )

ui <- bs4DashPage(navbar, 
                  tags$style(type = 'text/css', 
                             '.navbar { background-color: #144c96;
                           font-family: Source Sans Pro;
                           font-size: 23px;
                           font-weight: bold;
                           color: white;}'),
                  sidebar, 
                  body,
                  footer = footer)



