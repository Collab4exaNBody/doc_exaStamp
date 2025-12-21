## Combining YAML files

As discussed before, it is possible to include files using the `includes` key. The included files are merged with - and overriden by - the file that includes them, ultimately forming a single YAML document.

Each time an **exaStamp** input file **includes** another (for example, **base.yaml**), the included file is first loaded to form a YAML document. Then, the including file is also loaded to form a second YAML document. The two documents are then merged using the algorithm that specifically designed for **exaNbody** and **exaStamp**.

!!! note "file_A.yaml"

    ```yaml
    configuration:
      debug: false
      profiling: true
    ```

!!! note "file_B.yaml"

    ```yaml
    includes:
      - file_A.yaml

    configuration:
      debug: true

    compute_force:
      - lennard_jones
      - langevin_thermostat
    ```

!!! note "file_C.yaml"

    ```yaml
    includes:
      - file_B.yaml

    +compute_force:
      - repulsive_wall
    ```
Usage example of files inclusion and operators overload:

- From basic definitions in **file_A.yaml**, **file_B.yaml** overleads `debug` in `configuration` and adds the aggregate component `compute_force`.
- From **file_B.yaml**, **file_C.yaml** adds at the end of `compute_force` the component `repulsive_wall`.
- This enables the construction of the final document **final.yaml** defined below:

!!! note "final.yaml"

    ```yaml
    configuration:
      debug: true
      profiling: true

    compute_force:
      - lennard_jones
      - langevin_thermostat
      - repulsive_wall
    ```

----------------------------------------------------------------  