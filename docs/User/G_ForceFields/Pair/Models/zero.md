# **Zero**

## **Description**

The `zero_compute_force` operator defines a pair interaction with zero energy and zero force:

$$
E(r) = 0
$$

It has no parameter. It is used to declare a cutoff for a pair of species without any interaction, for instance to make sure the neighbor lists are built up to a given distance, or as a placeholder in a multi-species setup.

<div class="center-table" markdown>

| Parameter | Units    | Description                         |
| :-------- | :------: | :---------------------------------- |
| `rcut`    | distance | Cutoff radius of the pair potential |

</div>

## **YAML syntax**

```yaml
zero_compute_force:
  rcut: VALUE UNITS
  parameters: {}
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    zero_compute_force:
      rcut: 7.0 ang
      parameters: {}

    # Symetric variant
    zero_compute_force_symetric:
      rcut: 7.0 ang
      parameters: {}
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    compute_force_pair_multimat:
      potentials:
        - { type_a: Si , type_b: Si , potential: zero , rcut: 8.47 ang , parameters: {} }
        - { type_a: Si , type_b: O  , potential: zero , rcut: 5.00 ang , parameters: {} }
    ```

!!! note

    In `compute_force_pair_multimat`, species pairs that are not listed automatically get a zero potential.
