#GNU Make Workshop

A two-day training on GNU make that will teach all basics. It is devided into
four lessons:

1. Basics: 
 - What is make?
 - How to write a rule.
 - Dependencies
2. Rules and Variables
 - rules: explicit rules, empty rules, phony rules
 - shel syntax
 - variables: naming, assignment, expansion, origin
 - target-specific variables, automatic variables
 - vPATH and vpath
3. Pattern Ruls, Implicit Rules and Functions
 - pattern rules
 - implicit rules and their usage
 - built-in functions
4. Macros and Conditionals
 - multi-line variables and user-defined functions
 - the command-line modifier "@"
 - conditionals

Each lesson ends with an exercise that requires to utilize what was learned in the previous lessen. During the exercises a make file, that converts FLAC files to ogg or mp3, adds replay gain and downloads a cover file, is developed. Starting with a very minimalistic make file, it is continuously upgraded with each exercise. The final result can be used to automatically convert a large flac collection to mp3 or ogg.
