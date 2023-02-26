# Ideology comments youtube retrieval

Obtaining and storing youtube comments thought HTTP according to ideology.

## Initialize

* Install dependencies:

```bash
bundle install
```
* Create file called "targets.yml" in root directory, add the identifiers of the videos with their classification as follows:

```yml 
- videoId: 'hm7TZCxQ9X8'
  ideology: 'right-wing'
- videoId: 'q3OY0NN3t10'
  ideology: 'left-wing'
```

* Create environment file __.env__ base on __.env.dist__.
* Run [retrieve_from_api.rb](retrieve_from_api.rb) script.
* Run [generate_dataset.rb](generate_dataset.rb) script.