# Checking if different columns in R have the same labels

check_trait_label_consistency_with_madin_condensed_species <- function(df, trait) {
  
  print(sprintf("Checking stats for %s", trait))
  cols <- c("species")
  patterns <- c(
    "gram_stain"="[S|s]tain$", 
    "motility"="[M|m]otility$"
  )
  if (trait == "metabolism") {
    cols <- append(cols, c("metabolism", "Oxygen"))
  } else if(trait == "sporulation") {
    cols <- append(cols, c("Spore", "sporulation"))
  } else if (trait== "gc_content") {
    cols <- append(cols, c("gc_content", "Genome.GC"))
  } else {
    cols<- append(cols, get_cols_by_regx_pattern(df, patterns[trait]))
  }
  return(df[cols])
}

get_cols_by_regx_pattern <-function(df,pattern) {
  df_cols_names<- names(df)
  return(df_cols_names[grepl(pattern,df_cols_names)])
}

check_gram_stain <- function(df) {
  df <- df %>% filter(!is.na(gram_stain)) %>% filter(!is.na(GramStain)) %>%
          replace(.=="Gram-negative", "negative") %>% 
          replace(.=="Gram-positive", "positive")
  return(.check_agree_stats(df))
}

check_motility <- function(df) {
  df <- df %>% 
        mutate(
            motility=gsub("gliding|flagella|axial filament", "yes",motility), 
            Motility=gsub("Motile", "yes",Motility),
            Motility=gsub("Non-motile", "no",Motility)) %>%
        filter(!is.na(motility)) %>% filter(!is.na(Motility))
  return(.check_agree_stats(df))
}

check_metabolism <- function(df){
  # condensing to Aerobic, Anaerobic, and Microaerophilic
  # didnot compare faculatative { it can either be aerobe or anaerobe }
  df <- df %>% mutate( 
              metabolism=gsub("^aerobic$|^obligate aerobic$", "Aerobic",metabolism), 
              metabolism=gsub("^anaerobic$|^obligate anaerobic$", "Anaerobic",metabolism), 
              metabolism=gsub("microaerophilic", "Microaerophilic",metabolism)) %>% 
          filter(metabolism != "facultative") %>% 
          filter(!is.na(Oxygen)) %>%
          filter(!is.na(metabolism))
  return(.check_agree_stats(df))
}

check_sporulation <- function(df){
  df <- df %>% mutate( 
      Spore=gsub("No", "no",Spore),
      Spore=gsub("Yes", "yes",Spore)) %>% 
    filter(!is.na(Spore)) %>%
    filter(!is.na(sporulation))
  return(.check_agree_stats(df))
}

check_gc_content <- function(df) {
  df <- df %>% select(c("gc_content", "Genome.GC")) %>% 
      filter(!is.na(gc_content)) %>% 
      filter(!is.na(Genome.GC))
  rmse <- sum((df["gc_content"] - df["Genome.GC"])^2)/nrow(df)
  return(sprintf("The rmse for gc_content is %s", rmse))
}

.check_agree_stats <- function(df){
  full_labels_len <- nrow(df)
  same_df_len <- nrow(df[df[, 2] == df[, 3],])
  return(c(full_labels_len, same_df_len, same_df_len/full_labels_len))
}

run_stats <- function(traits) {
  t <- c()
  for (trait in traits) {
    df <- check_trait_label_consistency_with_madin_condensed_species(condensed_liamp_shaw, trait)
    if (trait == "gram_stain"){
      print(check_gram_stain(df))
    } else if (trait == 'motility') {
      print(check_motility(df))
    } else if (trait =="sporulation") {
      print(check_sporulation(df))
    } else if (trait == "metabolism"){
      print(check_metabolism(df))
    } 
    else {
      print(check_gc_content(df))
    }
  }
}







