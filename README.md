# CalculatorBrain
Stanford University Winter 2015, Assignment 2 (iOS)

This assignment CalculatorBrain is a continuation of [Assignment 1 Calculator](https://github.com/sanjibahmad/Calculator)

In addition to the features listed in Calculator, this assignment provides:

- A separate model for all calculations
- Additional scientific functions
- Memory functions
- An Undo button (which previously functioned as the Backspace button)
- Replaces the previous History function with a better implementation
- Provides error messages

The ViewController code is now more lean and better organized since all 
calculation related logic has been moved to the model.

The project covers all the required tasks and most extra credit tasks. 

Two items were not implemented as described in the Extra Credit 
Hints section in the project specifications document:

- The error messages come from the model with full error text
  instead of error codes for the ViewController to translate
- Error handling is not implemented by associating any value 
  (a function) with UnaryOperations and BinaryOperations

Video Demo: https://youtu.be/4oavo9ETa38
