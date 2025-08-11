To make the directory scaffold structure with rich metadata and the ability ro validate the contents of the directory, use `generator.py`:
```
cd top_level_dir/
python3 generator.py --spec DIRSPEC.yml --root .
```
This generates the same structure as `make_dir_structure.sh`, but with logged information on the directory specification, metadata, and the ability to verify files.

To set up the directory structure for this project for a single sample / biological entity, navigate to the top-level directory for your analysis and use `make_dir_structure.sh` with no arguments:
```
cd top_level_dir/
./make_dir_structure.sh
```
The structure is visualized in `dir_tree.txt` along with descriptions of the purpose of each (sub)directory.
