## 0.4.0
Features:
    - Command line parsing is now done internally, i.e. removed optparse (#6).
    - Added a text builder interface.
    - Added a table builder interface.
    - Shell interact with text builder interface
    - Shell#say, Shell#indent, Shell#password
    
Bug fix:
    - OptParse was hijacking the -v --version.
    
## 0.3.0
Features:
    - Added a shell class for any user interaction.
    - Added `priority` to test commands in specific order and not the order they where loaded.(#4)
    - Added `auto_option` to define specific options cleaner.(#5)
    
## 0.2.0
Features:
    - Allow unknown options to be ignored and not raise Error(#1)
    - Added list options. For options that can be multiple times in the same command(#2)
    - Added default value for options.(#3)

## 0.1.0
Inital release.
