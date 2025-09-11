# Parameters 

This page focuses on the [`Parameter`](#param) and [`Parameter`](@params) objects specially designed for `SLOTH`.

`SLOTH` provides a variety of parameter types, enabling flexible and dynamic configuration of simulation inputs.
These parameters can then be passed as arguments to `SLOTH` problems (see [Problems](../MultiPhysicsCouplingScheme/Problems/index.md) for more details).

## __Parameter__ {#param}

Each parameter is managed by the C++ class `Parameter`. 
A Parameter is defined by its name (type `std::string`), its value, and optionally a description (type `std::string`). 

```c++
Parameter(name, value, description)

Parameter(name, value)
```

The type of the `Parameter`is deduced from the value. 
The basic types `double`, `int`, `std::string` and `bool` can be used 

!!! example "Example of definitions of Parameter with basic types"

    === "double"
        ```c++
        Parameter("p1", 1.0, "Scalar Parameter of type double")
        ```
    === "int"
        ```c++
        Parameter("p1", 1, "Scalar Parameter of type int")
        ```
    === "std::string"
        ```c++
        Parameter("p1", "1.0", "Scalar Parameter of type std::string")
        ```
    === "bool"
        ```c++
        Parameter("p1", true, "Scalar Parameter of type bool")
        ```

but also custom-defined containers:

!!! example "Example of definitions of Parameter with custom-defined  types"

    Custom-defined types can be defined either by their standard definition or by using a C++ alias.

    === "MapStringDouble"
        `MapStringDouble`is a C++ alias for `std::map<std::string,double>`.

        ```c++
        MapStringDouble param_value;
        param_value.emplace("value", 1.0);
        Parameter("p1", param_value, "Scalar Parameter of type MapStringDouble")
        ```

    === "Map2String2Double"
        `Map2String2Double`is a C++ alias for `std::map<std::tuple<std::string, std::string>, std::tuple<double, double>>`.

        ```c++
        Map2String2Double param_value;
        param_value.emplace(std::make_tuple("value_1", "value_2"), std::make_tuple(1.0,2.));
        Parameter("p1", param_value, "Scalar Parameter of type Map2String2Double")
        ```

    === "vString"
        `vString`is a C++ alias for `std::vector<std::string>`.

        ```c++
        vString param_value;
        param_value.emplace_back("value_1");
        param_value.emplace_back("value_2");
        Parameter("p1", param_value, "Scalar Parameter of type vString")
        ```
    === "vInt"
        `vInt`is a C++ alias for `std::vector<int>`.

        ```c++
        vInt param_value;
        param_value.emplace_back(0);
        param_value.emplace_back(1);
        Parameter("p1", param_value, "Scalar Parameter of type vInt")
        ```
        
    === "vDouble"
        `vDouble`is a C++ alias for `std::vector<double>`.

        ```c++
        vDouble param_value;
        param_value.emplace_back(0.0);
        param_value.emplace_back(0.1);
        Parameter("p1", param_value, "Scalar Parameter of type vDouble")
        ```

    === "vTupleStringInt"
        `vString`is a C++ alias for `std::vector<std::tuple<std::string,int>>`.

        ```c++
        vTupleStringInt param_value;
        param_value.emplace_back(std::make_tuple("value_1",1));
        param_value.emplace_back(std::make_tuple("value_2",2));
        Parameter("p1", param_value, "Scalar Parameter of type vTupleStringInt")
        ```

    === "vTupleStringString"
        `vTupleStringString`is a C++ alias for `std::vector<std::tuple<std::string,std::string>>`.

        ```c++
        vTupleStringString param_value;
        param_value.emplace_back(std::make_tuple("key_1","value_1"));
        param_value.emplace_back(std::make_tuple("key_2","value_2"));
        Parameter("p1", param_value, "Scalar Parameter of type vTupleStringString")
        ```

    === "vTuple2StringDouble"
        `vTuple2StringDouble`is a C++ alias for `std::vector<std::tuple<std::string,std::string, double>>`.

        ```c++
        vTuple2StringDouble param_value;
        param_value.emplace_back(std::make_tuple("key_1","value_1",0.0));
        param_value.emplace_back(std::make_tuple("key_2","value_2",1.0));
        Parameter("p1", param_value, "Scalar Parameter of type vTuple2StringDouble")
        ```
 

This list of parameter types can be easly extended.

!!! note "Access to `Parameter` informations"
    As for deep inside the code, C++ public methods allow you to get the name, description and value of a `parameter'. 

    Please see the Doxygen for more details.

## __Parameters__ {#params}

The C++ class `Parameters` allows to define a collection of `Parameter` objects of different types. 

!!! example "Example of definitions of Parameters"

    ```c++ hl_lines="9"
    auto p1 = Parameter("p1", 1.0, "Scalar Parameter of type double")
    auto p2 = Parameter("p2", true, "Scalar Parameter of type bool")
    vTupleStringString param_value;
    param_value.emplace_back(std::make_tuple("key_1","value_1"));
    param_value.emplace_back(std::make_tuple("key_2","value_2"));
    auto p3 = Parameter("p3", param_value, "Scalar Parameter of type vTupleStringString")

    auto params = Parameters(p1, p2, p3);
    ```

    In this example, `params` gathers three `Parameter` of type `double`, `bool` and `vTupleStringString`.

`Parameters` class allows to add or substract `Parameter`.

### __Addition of parameters__

Two `Parameters' objects can be merged.

!!! example "Example of merge of two Parameters"

    ```c++ hl_lines="8"
    auto p1 = Parameter("p1", 1.0, "Scalar Parameter of type double")
    auto p2 = Parameter("p2", true, "Scalar Parameter of type bool")
    vTupleStringString param_value;
    param_value.emplace_back(std::make_tuple("key_1","value_1"));
    param_value.emplace_back(std::make_tuple("key_2","value_2"));
    auto p3 = Parameter("p3", param_value, "Scalar Parameter of type vTupleStringString")

    auto merge_parameter = Parameters(p1) + Parameters(p2, p3);
    ```
    

!!! warning "Priority when merging"
     
    When merging two `Parameters' objects, any `Parameter' contained in the second `Parameter' will overwrite any `Parameter' contained in the first `Parameter' if they have the same name.

    
A `Parameters' can be also be merged with a `Parameter' object. 

!!! example "Example of merge of a Parameters with a Parameter"

    ```c++ hl_lines="8"
    auto p1 = Parameter("p1", 1.0, "Scalar Parameter of type double")
    auto p2 = Parameter("p2", true, "Scalar Parameter of type bool")
    vTupleStringString param_value;
    param_value.emplace_back(std::make_tuple("key_1","value_1"));
    param_value.emplace_back(std::make_tuple("key_2","value_2"));
    auto p3 = Parameter("p3", param_value, "Scalar Parameter of type vTupleStringString")

    auto merge_parameter = Parameters(p2, p3) + p1 ;
    ```

!!! warning "Priority when merging"
     
    If the `Parameter' object already contains a `Parameter' with the same name as the `Parameter' to be merged, the latter will overwrite the existing one.


### __Removing a parameter__ 

A `Parameter' can be removed from a `Parameters' object by name.
 
!!! example "Example of `Parameter` removal"

    ```c++ hl_lines="9-10"
    auto p1 = Parameter("p1", 1.0, "Scalar Parameter of type double")
    auto p2 = Parameter("p2", true, "Scalar Parameter of type bool")
    vTupleStringString param_value;
    param_value.emplace_back(std::make_tuple("key_1","value_1"));
    param_value.emplace_back(std::make_tuple("key_2","value_2"));
    auto p3 = Parameter("p3", param_value, "Scalar Parameter of type vTupleStringString")

    auto merge_parameter = Parameters(p1, p2, p3);
    auto reduced_parameter = merge_parameter - p1;
    ```

