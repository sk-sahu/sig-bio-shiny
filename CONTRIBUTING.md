## Contribution 

First of all thank you for your interest in contributing to this project :) 

If you want to fix/report any bugs or add an extra module then please follow developer notes bellow. This will help us to maintain a specific structure to the project.

### Developers Notes

Try to keep `app.R` file minimal, only with essential lines of code. For each module, Server and UI functions should specify in a single R script (Example: `module_modulename.R`) and additional required functions for that modules should be in another file (Example: `module_modulename_utils.R`)
