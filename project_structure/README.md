To make the directory scaffold structure with rich metadata and the ability ro validate the contents of the directory, use `generator.py`:
```
cd top_level_dir/
python3 generator.py --spec DIRSPEC.yml --root .
```
This generates the same structure as `make_dir_structure.sh`, but with logged information on the directory specification, metadata, and the ability to verify files.
* `make_dir_structure.sh` can be run by itself with no arguments in the desired directory to generate the same setup, without any metadata or logging.
