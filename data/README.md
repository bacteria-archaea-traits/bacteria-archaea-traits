---
output:
  pdf_document: default
  html_document: default
  word_document: default
---
#### What kind of attributes – biology – BacDive, BV-BRC, bugphyzz to understand different attributes and their possible values/distributions

- `gram_stain`:**categorical** 

      - positive, negative and variable
      - variable -> NA { in data transformation }

- `metabolism`:**categorical** (rename to oxygen_tolerance)

    - microaerophilic, anaerobic, aerobic, facultative (ambiguous), obligate aerobic, obligate anaerobic.
    - faculative aerobe/anaerobe --> (Note: facultative is both label for aerobe and anaerobe. )
    
- `pathways`: **string** example: nitrogen_oxidation

    - 810 unique string
    - subgroup with only 1 pathways: come to 100 groups
        * nitrate_reduction, fermentation, aerobic_chemo_heterotrophy, nitrogen_fixation
        
- `carbon_substrates`: **string** example: methanol
- `sporulation`: *categorized*: (Yes, No) { Original source: Nonsporulating, sporulating, Yes, No }
- `motility`: *categorized* 

    Example of translations
    * motile, but unspecified structure : yes
    * variable                          : yes
    
    - can be binarized to 'Yes', or 'No'

- `range_temp`: **categorical**
    
    * bacDive has 4 categorize { hyperthermophilic, psychrophilic, thermophilic, mesophilic }
    * dataset has: {
                    thermophilic, mesophilic, psychrophilic,extreme thermophilic, 
                    facultative psychrophilic,psychrotolerant,thermotolerant 
                  } can be condensed to bacDive 4 categories.
    * ONLY obtained from **PATRIC** dataset
        - Potentially incorporate bugphyzz and BacDive.
        
- `range_salinity`: **categorical**

    * ONLY obtained from **PATRIC** dataset
        - Potentially incorporate bugphyzz and BacDive.
    
- `cell_shape`: 

- `isolation_source`:

    - Translated to 4 levels ( 73 unique combinations ): 
    - can be categorized into: 
          - environment
          - plant host
          - human host
          - fungus/algae host
          - animal host
    - human host only: 415 data set.

`Translations issues and follow-ups`

- **cell-shape**

    - Irregular cocci -> coccobacillus/coccus
    - Oval-(Ovoid)-shaped/Oval -> coccobacillus/coccus
    - Rod or Coccus or V-shaped  -> NA
    
- **Gram-stain** 

    - variable -> NA; 2 -> NA; _ -> NA

- **metabolism** 

    - A -> aerobic; AN -> anaerobic; FA -> facultative; Preferably anaerobic -> NA; microA -> microaerophilic
    
- **isolation_source**

    - free living -> unclassified
    - campeelli (Lactobaciluss sp.)
        - No data loss
        - Translation issues: 
            * feces -> host_animal_endotherm_feces; 
            * intestine of adult-> host_animal_endotherm_intestinal
    -fierer: 
        - plant endophytes -> host_plant (endophytes are animals symbiotic to plants)
        - other, natural cave -> (unclassified) -> NA
        - other, hoof keratin -> host_animal_endotherm
        - other, small stone -> unclassifierd
        - other, small stone from agricultural field -> soil_agricultural
        - sediment adjacent to sperm whale carcasses -> (unclassified)
    
    -gold: 
        - engineered, biotransformation, free living -> unclassified
      
    -jemma-refseq:
        - pus -> host_animal_endotherm
        - caulobacter fwc20 culture -> unclassified
        - clinical specimen -> host_animal_endotherm
        - colon -> host_animal_endotherm_intestinal
        - curette -> unclassified (engineered surface).
        - food-packaging paperboard -> unclassified (engineered surface)
        
    - kegg
        - Isolated from leg wound -> host_animal_endotherm_surface
    
    - kremer: (543 -> 31)
        - environment ? isolation source

    - pasteur: (ApR)
        - Interesting columns: Phenotype, Pathogenicity
    - prochlorococcus
        - No issue: all cyanos are from seawater translated to water_marine.
                                  
                                  
`Other findings`
- https://bacdive.dsmz.de/help/isolation-source-search.htm
- `methanogens`: for methanogens bacterias only. 


**Potential pathogenicies pattern**
- biopsies|infection|sputum|clinical|fibrosis|cyst|abscess
- gold data: pathogenicity column

**human/non-human isolated**
-human|colon

**Non-pathogenic**
- free living

## Missing values – are they missing to resolve conflicts from strains → species OR are the missing in the original source

- Contradicting labels; where a species has more that two categories for gram-stain:  positive: 1, negative: 2
- The labels species receive NA for that trait.
-  Phylogenic classification

 1. Acetivibrio cellulolyticus  NA         engqvist 
 2. Acetivibrio cellulolyticus  NA         faprotax         
 3. Acetivibrio cellulolyticus  NA         faprotax         
 4. Acetivibrio cellulolyticus  NA         faprotax         
 5. Acetivibrio cellulolyticus  NA         faprotax         
 6. Acetivibrio cellulolyticus  negative   gold             
 7. Acetivibrio cellulolyticus  positive   gold             
 8. Acetivibrio cellulolyticus  positive   microbe-directory
 9. Acetivibrio cellulolyticus  negative   patric           
10. Acetivibrio cellulolyticus  NA         protraits 

MAX-priority: 
species                              metabolism             n total prop  Priority Category
Acidicapsa ligni                     aerobic                1     2 50.0         1        1
Acidicapsa ligni                     obligate aerobic       1     2 50.0         2        1

Reduces to: (Like for min )
Acidicapsa ligni                     obligate aerobic       1     2 50.0         2        1

## Metabolism: Acidithiobacillus ferrooxidans: some of the levels are missing.

- Multiple categories with the same priority.

species                       metabolism            n total prop  Priority Category
Acidithiobacillus ferrooxidans facultative          2     8 25.0         2        1
Acidithiobacillus ferrooxidans obligate aerobic     3     8 37.5         2        1

- Labels are assigned to less category { more general category }

                New Priority Category
             **aerobic    1        1
           anaerobic      1        2
        facultative       2        1
    microaerophilic       2        1
               <NA>       0        0
   obligate aerobic       2        1
 obligate anaerobic       2        2

  - Assigned to label aerobic
  
**Example 2** (Lowered to a more general label. )
species                       metabolism            n total prop  Priority Category
Gordonia araii microaerophilic      1     2 50.0         2        1 Gordonia araii    
Gordonia araii obligate aerobic     1     2 50.0         2        1 Gordonia araii

reduced to: 
Gordonia araii aerobic       NA     2 NA           2        1 Gordonia araii     2

- **inconsistent**
                     species gram_stain       data_source
1 Acetivibrio cellulolyticus   negative              gold
2 Acetivibrio cellulolyticus   positive              gold
3 Acetivibrio cellulolyticus   positive microbe-directory
4 Acetivibrio cellulolyticus   negative            patric


## Useful columns from other dataset: 

- `Pasteur`: 

    - phenotype: example **Rifampicin and nalidixic acid resistant**
    - pathogenicity: example **2, NA, 3** (No clear definition what is what.)

- `patric`: The dataset contains other potentially useful columns for this project. 

    - Examples of the columns: antimicrobial_resistance, isolation_comments, isolation_site, antimicrobial_resistance_evidence, disease
    - SAGs, and MAGs
     
- `protraits`: 426 columns

    - habitat.multiple, contains `pathogen`, mobility, motility, contains `host`, habitat.hostassociated, knownhabitats, 

- `gold`: 
    - SYMBIOTIC_RELATIONSHIP: Example **mutualistic, commensal**
        - Syntrophic: organism lives of the waste products of the other animal
        - Mutualistic: 
    - BIOTIC_RELATIONSHIP: Example **Free living, Symbiotic**
- 

### Merging liamp_shaw dataset, with condensed_species: getting aggreement/disagreement between the dataset.

-  Merge results: 
    - 15 host groups: Example `Carnivora, Rodentia,Ungulates, Human `
    - Human host-specific
        - No. 1257

        | Association | Apathogenic   | Pathogenic    | Pathogenic?    | na
        | :---:   | :---: | :---: | :---: | :---: |
        | No. | 14   | 992   | 101 | 150

- `Stats for SYMBIOTIC_RELATIONSHIP btwn LIAMP-shaw`
    - Segmented by host specificity and compared the labels. 
        - 123 data points with human host; compared to 1257 in condensed dataset.
    - Mostly states E.coli to be commensual (make sense for strain level): liamp_shaw stated being pathogenic, as result of generalization. 
    - Examples of mismatch: 
        `Mycoplasma pneumoniae`, `Bifidobacterium longum`, `Escherichia coli`, `Brevibacterium casei`, `Staphylococcus aureus`, `Bifidobacterium *`

- Gram stain, and sporulation high aggreement: `95%`
- gc_content: close to each other: `rmse of 1.01857567293194`
- motility, and metabolism have agreement of `81% and 64.5%` respectively
    - potential issue is categorization of the variables. 


## Imputing dataset;

- `BacDive`: (The dataset is used only for getting oxygen tolerance trait.)
    
    * Potential columns can be included
    * Only selected oxygen tolerance == microaerophile (get all the dataset) 
    * Contains isolation source and grouping
    * Look at BacDiveApi

**Bug**

## investigates:

- Corynebacterium lactis, Enterococcus silesiacus, 

- Duplicated omits the first dataframe: { check if that brings inconsistency with the dataset }
- Remove { elements with more than 2 species will not be condensed, thus it marked unresolved }

- Example: 

    species      metabolism     n total prop  Priority Category by           count
    Rothia aeria aerobic       NA     5 NA           2        1 Rothia aeria     3
    Rothia aeria aerobic       NA     5 NA           2        1 Rothia aeria     3
    Rothia aeria aerobic       NA     5 NA           2        1 Rothia aeria     3

    - Label
    Rothia aeria       <NA>
    - instead of 
    Rothia aeria       aerobic
    
    - 10 missing values were corrected. { initially mislabelled as NA }
    
    - Fix: use distinct before rbind. 






          
