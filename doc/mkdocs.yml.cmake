site_name: exaStamp
repo_url: https://github.com/Collab4exaNBody/exaNBody
repo_name: Collab4exaNBody/exaStamp
use_directory_urls: false
copyright: Copyright &copy; 2025 P. Lafourcade, T. Carrard, R. Prat
generate: true
markdown_extensions:
  - toc:
      toc_depth: 6
      permalink: true
  - attr_list
  - pymdownx.emoji:
      emoji_index: !!python/name:material.extensions.emoji.twemoji
      emoji_generator: !!python/name:material.extensions.emoji.to_svg
  - md_in_html
  - pymdownx.tabbed:
      alternate_style: true
  - admonition
  - pymdownx.details
  - pymdownx.highlight:
      anchor_linenums: true
      line_spans: __span
      pygments_lang_class: true
      use_pygments: true
#      auto_title: true
#      linenums: true
  - pymdownx.inlinehilite
  - pymdownx.snippets:
      base_path: $relative
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format      
  - def_list
  - pymdownx.tasklist:
      custom_checkbox: true
  - pymdownx.arithmatex:
      generic: true
  - footnotes
  - markdown_katex:
      no_inline_svg: True
      insert_fonts_css: False

edit_uri: edit/main/docs/
plugins:
  - search
  - bibtex:
      bib_file: "docs/References/biblio.bib"

extra_css:
  - styles/extra.css
  - https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css

extra_javascript:
  - javascripts/katex.js
  - https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js
  - https://cdn.jsdelivr.net/npm/katex@0.17.11/dist/contrib/auto-render.min.js

theme: 
#  name: readthedocs
  name: material
  logo: img/xsp_logo.png
  icon:
#    repo: fontawesome/brands/github
    repo: fontawesome/brands/git-alt
    previous: fontawesome/solid/angle-left
    next: fontawesome/solid/angle-right
    edit: material/pencil 
    view: material/eye
  features:
    - announce.dismiss
    - content.code.annotate
    - content.code.copy
    - content.code.select
    # - content.footnote.tooltips
    # - content.tabs.link
    - content.tooltips
    # - header.autohide
    # - navigation.expand
#    - navigation.footer
    - navigation.indexes
    # - navigation.instant
    # - navigation.instant.prefetch
    # - navigation.instant.progress
    # - navigation.prune
    #- navigation.sections
    - navigation.tabs
    - navigation.tabs.sticky
    - navigation.top
    - navigation.tracking
    - search.highlight
    # - search.share
    # - search.suggest
    #- toc.follow
  palette:
    primary: black
    accent: black
  # palette:
  #   - media: "(prefers-color-scheme)"
  #     toggle:
  #       icon: material/link
  #       name: Switch to light mode
  #   - media: "(prefers-color-scheme: light)"
  #     scheme: default
  #     primary: red
  #     accent: red
  #     toggle:
  #       icon: material/toggle-switch
  #       name: Switch to dark mode
  #   - media: "(prefers-color-scheme: dark)"
  #     scheme: slate
  #     primary: black
  #     accent: black
  #     toggle:
  #       icon: material/toggle-switch-off
  #       name: Switch to system preference    
########################################
########################################
docs_dir: '@DOCS_DIR@'
########################################
########################################
nav:
  - Home: 
    - index.md
  - Background:
    - Background/index.md
    - Overview:
      - Background/Overview/index.md
    - Distribution:
      - Background/Distribution/index.md
    - Code Versioning:
      - Background/Releases/index.md
      - Background/Releases/Release_3.7.2.md
      - Background/Releases/Release_3.7.3.md
    - Main Features:
      - Background/Features/index.md
  - Build & Install:
    - BuildInstall/index.md
    - BuildInstall/spack_installation.md
    - BuildInstall/cmake_installation.md
    - BuildInstall/running.md
  - User guide:
    - User/index.md
    - Simulation Graph:
      - User/SimulationGraph/index.md
    - Simulation Control:
      - User/SimulationControl/index.md
    - Domain and Spatial Regions:
      - User/DomainRegions/index.md
      - User/DomainRegions/domain.md
      - User/DomainRegions/regions.md
    - Grids:
      - User/Grids/index.md
      - User/Grids/flavors.md
      - User/Grids/input.md
      - User/Grids/analysis.md
      - User/Grids/output.md
    - Particles:
      - User/Particles/index.md
      - User/Particles/species.md
      - User/Particles/input.md
      - User/Particles/analysis.md
      - User/Particles/output.md
    - Force Fields:
      - User/ForceFields/index.md
      - User/ForceFields/pair.md
      - User/ForceFields/eam.md
      - User/ForceFields/meam.md
      - User/ForceFields/reactive.md
      - User/ForceFields/mlips.md
      - User/ForceFields/electrostatic.md
      - User/ForceFields/bonds.md
      - User/ForceFields/torsions.md
      - User/ForceFields/dihedrals.md
      - User/ForceFields/impropers.md
    - Ensembles and Constraints:
      - User/EnsemblesConstraints/index.md
      - User/EnsemblesConstraints/nve_ensemble.md
      - User/EnsemblesConstraints/thermostats.md
      - User/EnsemblesConstraints/nvt_ensemble.md
      - User/EnsemblesConstraints/pistons.md
      - User/EnsemblesConstraints/deformation.md
      - User/EnsemblesConstraints/minimization.md
    # - User/HowToSimulation/GlobalParameters.md      
    # - User/HowToSimulation/DomainGrid.md
    # - User/HowToSimulation/ParticlesCreation.md
    # - User/HowToSimulation/ForceField.md
    # - User/HowToSimulation/Constraints.md
    # - User/HowToSimulation/AnalysisOutput.md
    # - User/HowToSimulation/ExampleInputDeck.md
    # - User/HowToSimulation/DefaultYAML.md      
  - Beginner's guide:
    - Beginner/index.md
    - Tutorials:
      - Beginner/Tutorials/index.md
      - Beginner/Tutorials/Tutorial1.md
      - Beginner/Tutorials/Tutorial2.md
      - Beginner/Tutorials/Tutorial3.md
    - Examples:
      - Beginner/Examples/index.md
      - Beginner/Examples/Example1.md
      - Beginner/Examples/Example2.md
      - Beginner/Examples/Example3.md
  - Getting Started:
    - Started/index.md
    - Installation guide:
      - Started/Installation/index.md
      - Started/Installation/linux.md
      - Started/Installation/sources.md
      - Started/Installation/mac.md
      - Started/Installation/cluster.md
      - Started/Installation/cluster_source.md
      - Started/Installation/libtorch.md
    - HowTo: 
      - Started/HowTo/index.md
      - Basic features:
        - Started/HowTo/Simple/index.md
      - Tutorials:
        - Started/HowTo/Tutorials/index.md
    - Examples:
      - Started/Examples/index.md
      - Cahn-Hilliard: 
        - Started/Examples/CahnHilliard/index.md
        - Example 1:
          - Started/Examples/CahnHilliard/example1/index.md
        - Example 2:
          - Started/Examples/CahnHilliard/example2/index.md
        - Example 3:
          - Started/Examples/CahnHilliard/example3/index.md
        - Example 4:
          - Started/Examples/CahnHilliard/example4/index.md
        - Example 5:
          - Started/Examples/CahnHilliard/example5/index.md
      - Allen-Cahn:
        - Started/Examples/AllenCahn/index.md
      - Mass Diffusion:
        - Started/Examples/MassDiffusion/index.md
      - Thermal Diffusion:
        - Started/Examples/ThermalDiffusion/index.md
      - CALPHAD:
        - Started/Examples/Calphad/index.md
    - Code quality: Started/Quality/quality.md
  # - User Manual: 
  #   - Documentation/User/index.md
  #   - Documentation/User/Parameters/index.md
  #   - Documentation/User/Variables/index.md
  #   - Spatial discretization:
  #     - Documentation/User/SpatialDiscretization/index.md
  #     - Documentation/User/SpatialDiscretization/Meshing/index.md
  #     - Documentation/User/SpatialDiscretization/BoundaryConditions/index.md
  #   - Multiphysics Coupling Scheme:
  #     - Documentation/User/MultiPhysicsCouplingScheme/index.md
  #     - Documentation/User/MultiPhysicsCouplingScheme/Time/index.md
  #     - Documentation/User/MultiPhysicsCouplingScheme/Couplings/index.md
  #     - Problems:
  #       - Documentation/User/MultiPhysicsCouplingScheme/Problems/index.md
  #       - Partial Differential Equations:
  #         - Documentation/User/MultiPhysicsCouplingScheme/Problems/PDEs/index.md
  #       - Documentation/User/MultiPhysicsCouplingScheme/Problems/0D/index.md
  #       - Documentation/User/MultiPhysicsCouplingScheme/Problems/Remainder/index.md
  #     - Documentation/User/MultiPhysicsCouplingScheme/Convergence/index.md
  #   - Documentation/User/PostProcessing/index.md
  # - Modelling Description: 
  #   - Documentation/Physical/index.md
  # - Code Documentation: 
  #   - Documentation/Code/index.md
  # - Applications:
  #   - Applications/index.md
  - References: 
    - References/index.md
  - About: 
    - About/index.md
