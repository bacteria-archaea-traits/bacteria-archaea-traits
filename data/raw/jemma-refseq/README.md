# Jemma-refseq

## Data source:

Data from NCBI refseq database was extracted as described on the following page: 

https://www.ncbi.nlm.nih.gov/genome/doc/ftpfaq/#allcomplete


## Data processing:

To extract specific data points from the full-text obtained from NCBI (above), the text was processed using matlab and the following script: 

# MATLAB START

results = [];

% unzip data
gunzip('*.gbff.gz');

% process each file
files = dir('*.gbff');
for file = {files.name}
  data = genbankread(char(file));

  % process each file entry
  for i = 1:size(data, 2)
    LocusName = '';
    Definition = '';
    Organism = '';
    GenesTotal = NaN;
    GenesCoding = NaN;
    RRNAs = '';
    TRNAs = NaN;
    IsolationSource = '';
    Country = '';
    Host = '';

    % copy fields
    if isfield(data(i), 'LocusName')
      LocusName = data(i).LocusName;
    end
    if isfield(data(i), 'Definition')
      Definition = data(i).Definition;
    end
    if isfield(data(i), 'Source')
      Organism = data(i).Source;
    end

    % parse comments
    if isfield(data(i), 'Comment')
      for j = 1:size(data(i).Comment, 1)
        tokens = regexp(data(i).Comment(j, :), ...
          '^\s*([^\s].*[^\s])\s*::\s*([^\s].*[^\s])\s*$', 'tokens');
        if ~isempty(tokens)
          switch tokens{1}{1}
            case 'Genes'
              GenesTotal = str2double(tokens{1}{2});
            case 'CDS'
              GenesCoding = str2double(tokens{1}{2});
            case 'rRNAs'
              RRNAs = tokens{1}{2};
            case 'tRNAs'
              TRNAs = str2double(tokens{1}{2});
          end
        end
      end
    end

    % parse features
    if isfield(data(i), 'Features')
      Feature = '';
      for j = 1:size(data(i).Features, 1)
        tokens = regexp(data(i).Features(j, :), '^(\w+)', 'tokens');
        if isempty(tokens)
          tokens = regexp(data(i).Features(j, :), ...
            '^\s+/(\w+)="([^"]+)"', 'tokens');
          if ~isempty(tokens)
            switch Feature
              case 'source'
                switch tokens{1}{1}
                  case 'isolation_source'
                    IsolationSource = tokens{1}{2};
                  case 'country'
                    Country = tokens{1}{2};
                  case 'host'
                    Host = tokens{1}{2};
                end
            end
          end
        else
          Feature = tokens{1}{1};
        end
      end
    end

    % append entries to results
    results = [results; struct( ...
      'File', char(file), 'LocusName', LocusName, 'Definition', Definition, ...
      'Organism', Organism, 'GenesTotal', GenesTotal, ...
      'GenesCoding', GenesCoding, 'RRNAs', RRNAs, 'TRNAs', TRNAs, ...
      'IsolationSource', IsolationSource, 'Country', Country, 'Host', Host)];
  end
end

% data is in variable results

writetable(struct2table(results), 'results.xlsx')

# MATLAB END 


The resulting table was subsequently saved as a comma separated file (csv) named "Bacteria_archaea_traits_dataset.csv"