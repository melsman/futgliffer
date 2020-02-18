# Futgliffer

This program is a standalone terminal program that transforms
json-versions of [UFO](http://unifiedfontobject.org/) Glif files
(transformed from XML-format to Json using `xml-to-json-fast`) into
data objects that can be embedded in a
[Futhark](http://futhark-lang.org) program. The Futhark data objects
contain information about the font including the definitions of line
and cubic bezier segments for the font glyphs.

Examples of generating Futhark font specifications for entire fonts
are available in the `test/` folder.

As mentioned, the program works in concert with `xml-to-json-fast`, a
terminal program that transform XML data into Json format.

# The futgliffer Program

The `futgliffer` program takes as input the path to a json-file
(transformed from XML using `xml-to-json-fast`). The output is a
Futhark snippet to be included in a larger Futhark source file.

# Compilation

To generated the `futgliffer` executable, execute the following command:

```
$ make clean futgliffer -C src
```

To generate a Futhark `font.fut` file to include in your program,
execute the following command:

```
$ make clean all -C test
```

This command will generate the file `test/font.fut`.

# Requirements

You need a Standard ML compiler such as
[MLKit](http://github.com/melsman/mlkit) or MLton.

You need to install `xml-to-json-fast`; see
https://github.com/sinelaw/xml-to-json-fast

# LICENSE

This software is distributed under the
[MIT-License](LICENSE). Licenses for the included test fonts are
available in the respective `fontinfo.plist` files located in the
respective font subfolders in the test folder.
