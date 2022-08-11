
##Library##
library(tidyverse)
library(ComplexUpset)
library(tayloRswift)

##this example code contains data linked within this repo (see "data" folder)##
##the data used in the "classes" dataframe is explained within the Readme of this repo##
##all other data used is easily accessible via CeNGEN (https://cengen.shinyapps.io/CengenApp/) and is further explained in the Readme## 

##Read in Neurotransmitter Classification##
classes <- read.csv("data/ModifiedforCeNGEN-Ce_NTtables_Loer&Rand2022.csv") %>% 
  subset(select = c(Neuron.class, Neurotransmitter.1)) %>%
  dplyr::filter(Neuron.class != "") %>%
  dplyr::rename(Cell.type = Neuron.class) %>%
  dplyr::rename(NT1 = Neurotransmitter.1)

##Read in Data from CeNGEN##
DATAglc1thr2 <- read.csv("data/GenesExpressing-glc-1-thrs2.csv") %>% 
  subset(select = -c(Expression.level, X)) %>%
  as.list(DATAglc1)
DATAavr14thr2 <- read.csv("data/GenesExpressing-avr-14-thrs2.csv") %>%
  subset(select = -c(Expression.level, X)) %>%
  as.list(DATAavr14)
DATAavr15thr2 <- read.csv("data/GenesExpressing-avr-15-thrs2.csv") %>%
  subset(select = -c(Expression.level, X)) %>%
  as.list(DATAavr15)
DATAben1thr2 <- read.csv("data/GenesExpressing-ben-1-thrs2.csv") %>% 
  subset(select = -c(Expression.level, X)) %>%
  as.list(DATAben1)

##Create Compatible Dataframe Combining All Data##
compiled <- purrr::reduce(list(data.frame(Cell_Type=c(DATAavr14thr2), avr14=1),
                           data.frame(Cell_Type=c(DATAavr15thr2), avr15=1),
                           data.frame(Cell_Type=c(DATAben1thr2), ben1=1),
                           data.frame(Cell_Type=c(DATAglc1thr2), glc1=1)),
                      dplyr::full_join) %>%
  mutate_all(~replace(., is.na(.),0)) %>%
  merge(classes, by= "Cell.type", all=TRUE) %>%
  dplyr::filter(ben1 != "na") %>%
  dplyr::mutate(NT1 = replace(NT1, str_detect(NT1, "Glu"), "Glutamatergic")) %>%
  dplyr::mutate(NT1 = replace(NT1, str_detect(NT1, "Dop"), "Dopaminergic")) %>%
  dplyr::mutate(NT1 = replace(NT1, str_detect(NT1, "Acet"), "Cholinergic")) %>%
  dplyr::mutate(NT1 = replace(NT1, str_detect(NT1, "ACh"), "Cholinergic")) %>%
  dplyr::mutate(NT1 = replace(NT1, str_detect(NT1, "GABA"), "GABAergic")) %>%
  dplyr::mutate(NT1 = replace(NT1, str_detect(NT1, "Un"), "Unknown")) %>%
  dplyr::mutate(NT1 = replace(NT1, str_detect(NT1, "un"), "Unknown")) %>%
  dplyr::mutate(NT1 = replace(NT1, str_detect(NT1, "Ser"), "Serotonergic")) %>%
  dplyr::mutate(NT1 = replace(NT1, str_detect(NT1, "Oct"), "Octopaminergic")) %>%
  dplyr::mutate(NT1 = replace(NT1, str_detect(NT1, "Tyr"), "Tyraminergic"))

##Create UpSet Plot##
genes = colnames(compiled)[2:5]
ComplexUpset::upset(compiled, genes, name = "gene",
                    base_annotations=list(
                      'Neuronal Cell Subtypes Expressing Genes'=intersection_size(
                        counts=FALSE, 
                        mapping=aes(fill=compiled$NT1),
                      )
                    ),
                    themes=upset_modify_themes(
                      list('default'=list(theme_classic(),
                                          theme(axis.text.x=element_blank(),
                                                axis.title.x=element_blank())
                                          )
                          )
                                              )
                    ) + 
  ggplot2::ggtitle('IVM- and ABZ-Resistance-Associated Gene Combinations') &
  ggplot2::theme(axis.title.x = element_blank()) &
  tayloRswift::scale_fill_taylor(palette = "lover") &
  ggplot2::labs(fill = "Neurotransmitter")

##Create UpSet Plot Without Neurotransmitter Data## 
ComplexUpset::upset(compiled, genes, name = "gene",
                    base_annotations=list(
                      'Neuronal Cell Subtypes Expressing Genes'=intersection_size(
                        counts=FALSE)
                                          ),
                    themes=upset_modify_themes(
                      list('default'=list(theme_classic(),
                                          theme(axis.text.x=element_blank(),
                                                axis.title.x=element_blank())
                                          )
                          )
                                              )
                    ) + 
  ggplot2::ggtitle('IVM- and ABZ-Resistance-Associated Gene Combinations') &
  ggplot2::theme(axis.title.x = element_blank())
