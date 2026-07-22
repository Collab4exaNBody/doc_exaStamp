---
icon: simple/yaml
---

# YAML basics

The `YAML` format is the only input format supported by `exaStamp`. This page recalls the basics of plain `YAML`. `exaStamp` and the underlying `onika`/`exaNBody` platform add a few extensions on top of it (reserved keys, file inclusion, component overriding, etc.), which are described in [YAML extensions](yaml_extensions.md).

## **Basic types**

`YAML` is a human-readable data serialization often used for writing configuration files and in applications where data is being stored or transmitted by/between operators. Recursive definition of `YAML` document is pretty simple and a `YAML` document usually contains three types of elements:

- **scalars**: text, number, boolean
- **lists**: an ensemble of ordered elements
- **dictionaries**: an ensemble, ordered or not, of tuples each with a key and an associated value

For more information about the `YAML` framework, please visit the following links:

- [**YAML Tutorials**](https://gettaurus.org/docs/YAMLTutorial/)
- [**YAML Online Parser**](http://yaml-online-parser.appspot.com/)
- [**YAML Wiki**](https://en.wikipedia.org/wiki/YAML/)

Below are some examples of scalar, list or dictionary definitions in `YAML` format.

=== "`Scalars`"
    
    ```yaml linenums="1"
    # Scalar definition examples
    val: "text only"
    val: 3.5
    val: true
    ```

=== "`Lists`"
    
    ```yaml linenums="1"
    # List definition examples
    list: ["list", "with", 5, true, "elements"]
    list:
      - "list"
      - "with"
      - 5
      - true
      - elements
    ```

=== "`Dictionaries`"
    
    ```yaml linenums="1"
    # Dictionary definition examples
    dict: {A: "value", B: 3, C: false}
    dict:
      A: "value"
      B: 3
      C: false
    ```

    Note: a list of single-key dictionaries, e.g. `[ { A: "value" }, { B: 3 }, { C: false } ]` or its block form with dashes, is a **list**, not a dictionary — `exaStamp` uses that pattern for ordered, possibly repeated entries (e.g. the `species` block).

## **Combining types**

In addition, you can combine multiple types (scalar, list, dictionary):

```yaml linenums="1"
# Multiple types combination in a dictionary
dictA:   
  key1: { A: "value", B: 3 }
  key2: [ "aaa", "bbb" ]
  key3: 4.67
  key4:
    A: [ 5, 6 ]
    B: { X: 1, Y: 2 }

# Alternative format  
dictA: { key1: { A: "value", B: 3 }, key2: [ "aaa", "bbb" ], key3: 4.67, key4: { A: [ 5, 6 ], B: { X: 1, Y: 2 } } }
  
```

Here, `key1` is bound to a value of type dictionary, `key2` is bound to a value of type list, `key3` is bound to a value of type scalar, `key4` is bound to a value of type dictionary.
