NB. Package to interpret bytes as packed binary data

Note 'What is a Struct?'
A Struct Definition is a 2-item list of boxed:
    0 {:: format string describing the types and lengths of the fields it contains
    1 {:: list of boxed field names
The name of the noun is the name of the struct

In it's simplest form only the format string is required to read the struct. But to
do anything more complicated, for example read only some fields, then other info is
needed too. Potentially could represent different structs as classes, but for now will 
just use an optionally boxed structure to define one.
Inputs to verbs will need: 
   * Struct definition,
   * data (binary string or filename),
   * optional flags (change Endianness, subset of Fields to read, statement to 
filter records)
In addition a mapping of C types to J types is required.
)

cocurrent 'struct'
