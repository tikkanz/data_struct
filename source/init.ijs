NB. Package to read/unpack C structures

Note 'What is a Struct?'
A struct is described by:
     a) a format string describing the types and lengths of the fields it contains
     b) a list of boxed field names
     c) a Name

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
