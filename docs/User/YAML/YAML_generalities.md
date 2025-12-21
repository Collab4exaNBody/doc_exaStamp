## **Generalities about YAML**
    
**YAML** is a human-readable data serialization often used for writing configuration files and in applications where data is being stored or transmitted by/between operators. Recursive definition of `YAML` document is pretty simple and a `YAML` document usually contains three types of elements:

- **A scalar**: text, number, boolean
- **A list**: an ensemble of ordered elements
- **A dictionary**: an ensemble, ordered or not, of tuples each with a key and an associated value

For more information, please visit the following links:

- [**YAML Tutorials**](https://gettaurus.org/docs/YAMLTutorial/)
  
- [**YAML Online Parser**](http://yaml-online-parser.appspot.com/)
  
- [**YAML Wiki**](https://en.wikipedia.org/wiki/YAML/)


Below are some examples of scalar, list or dictionary definitions in `YAML` format.
      
```yaml
# Scalar definition examples
val: "text only"
val: 3.5
val: true

# List definition examples
list: ["list", "with", 5, true, "elements"]
list:
  - "list"
  - "with"
  - 5
  - true
  - elements

# Dictionary definition examples
dict: {A: "value", B: 3, C: false}
dict:
  - A: "value"
  - B: 3
  - C: false
```

In addition, you can combine multiple types (scalar, list, dictionary):

```yaml
# Multiple types combination in a list
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

Here, `key1` is bind to a value of type dictionary, `key2` is bind to a value of type list, `key3` is bind to a value of type scalar, key3 is bind to a value of type dictionary.

<hr style="height:4px;border:none;background: rgb(180, 180, 180) ;margin:50px 0;">
