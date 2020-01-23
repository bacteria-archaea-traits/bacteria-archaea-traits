# ProTraits

To download this data do the following: 
1) Go to ProTraits at http://protraits.irb.hr/
2) On the front page, locate the link under the main search buttons where it says "Full set of predictions may be downloaded here"
3) Click the link
4) Download the file ProTraits_binaryIntegratedPr0.95.txt

Publication:
https://doi.org/10.1093/nar/gkw964

We use the ProTraits_binaryIntegratedPr0.95.txt, which is understood as being the most conservative.

Only the following columns are used:

- Organism_name
- Tax_ID
- motility
- mobility
- sporulation
- gram_stain.positive
- All columns containing the words "oxygenreq", "shape" and "metabolism"

For binary columns/traits we use the value "0" as not present (i.e. not motile) and "1" as present (motile). 

For traits spread over multiple columns (such as "oxygen requirement" and "shape" where there is a column for each type of oxygen use - i.e. "oxygenreq.facultative" and "oxygenreq.strictanaero"), we replace the content of any field containing a "1" with the name of the particular column  (i.e. "facultative"), and then merge all columns of the respective trait into one column (i.e. "metabolism"). NA and "0" are ignored in these columns.

In the end, the ProTraits dataset is reduced to 10 columns and 2833 rows with information, covering the triats "sporulation", "gram_stain", "metabolism", "pathways", "cell_shape" and "motility".
