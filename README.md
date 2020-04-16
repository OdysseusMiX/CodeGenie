# CodeGenie
Refactoring tool for Matlab

This tool is based on the set of refactorings laid out in Martin Fowler's book, "Refactoring, Improving the Design of Existing Code", 2nd Edition.

## Getting Started
1. To install, copy the files to your computer and add the directory to your Matlab path.
2. To refactor a file, insert the appropriate comment(s) and run `Refactor.file(yourFile)`. The tool will automatically perform the desired refactoring on the file.

### Supporting Refactorings
- *Extract Function.* Extracts code to local function at end of file. Insert `%<extract>newFunctionName` before the code to extract and `%</extract>` after the code to extract.
- *Nest Function.* Extracts code to a nested function of the current function. Insert `%<nest>newFunctionName` before the code to extract and `%</nest>` after the code to extract.
- *Inline Function.* Replaces function call with statements from function. Insert `%<inline>functionToInline` at the end of line where the function call occurs.

## Status
Currently working on Inline Function.
Extract function does not handle all possible cases.
