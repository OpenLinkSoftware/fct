# OpenLink Faceted Browser (FCT)

*Copyright (C) 2008-2021 OpenLink Software <support@openlinksw.com>*

# License
This software is licensed under the GNU General Public License.
See [COPYING](COPYING.md)) and [LICENSE](LICENSE.md) for
details.


# What are the system requirement for this package?
To build you need a recent linux or Mac OS system with python. 

To install and run the package, you need a recent version of:

   * Virtuoso Commercial Edition 7.x
   * Virtuoso Commercial Edition 8.x
   * Virtuoso Open Source Edition 7.x

# How do I create my local edition of this repository? 
* ensure git is setup functional on your computer
* choose a folder (directory) into which you want to copy this repository
* situate yourself in the designated folder using the `cd {folder-name}` command
* execute ```git clone https://github.com/OpenLinkSoftware/fct```

# How do i build the package?
```shell
./build.sh
-rw-r--r--  1 openlink openlink  5131160 23 Apr 10:44 fct_dav.vad
```



# See Also
  * [Virtuoso Web Site](https://virtuoso.openlinksw.com/)
  * [Virtuoso Open Source Edition GIT tree](https://github.com/openlink/virtuoso-opensource/)
  * [Virtuoso Facets Web Service](http://vos.openlinksw.com/owiki/wiki/VOS/VirtuosoFacetsWebService)
    * Fct shares common underpinnings with the Virtuoso Facets Web Service
  * [FacetJsClient](https://github.com/OpenLinkSoftware/FacetJsClient)
    * A Javascript client for the Virtuoso Faceted Browsing Service.
  * [FacetJsClient documentation](https://www.openlinksw.com/DAV/Public/FacetJsClient/doc/index.html)
    * Includes a description of the Facet Service XML data structure which underpins Fct, how to interpret it, examples showing the resulting generated SPARQL query and the significance of the position of the view element in setting the implicit focus (subject node) for applying Fct filters. Useful for developers wanting to understand the Fct internals.
