# OpenLink Faceted Browser (FCT)

*Copyright © 2008-2022 OpenLink Software <support@openlinksw.com>*

## License

This software is licensed under the GNU General Public License.
See [COPYING](COPYING.md) and [LICENSE](LICENSE.md) for details.

## What are the system requirements for this package?

To build, you will need a recent Linux or macOS system with Python.

To install and run the package, you will need a recent version of one
of the following:

* Virtuoso Commercial Edition 7.x or 8.x
* Virtuoso Open Source Edition (VOS 7.x

## How do I set up my local version of this repository? 

1. Ensure `git` is set up and functional on your computer.
2. Choose a folder (a/k/a directory) into which you want to copy this repository.
3. Navigate to the desired folder using the `cd {folder-name}` command.
4. Execute this command:
   ```shell
   git clone https://github.com/OpenLinkSoftware/fct
   ```

## How do I build the package?

Simply execute the following command:
```shell
./build.sh
```
The build will deliver something like the following:

```shell
-rw-r--r--  1 openlink openlink  5131160 23 Apr 10:44 fct_dav.vad
```

## See Also
* [Virtuoso Web Site](https://virtuoso.openlinksw.com/)
* [Virtuoso Open Source Edition (VOS) `git` tree](https://github.com/openlink/virtuoso-opensource/)
* [Virtuoso Facets Web Service](http://vos.openlinksw.com/owiki/wiki/VOS/VirtuosoFacetsWebService) —
  FCT shares common underpinnings with the Virtuoso Facets Web Service
* [FacetJsClient](https://github.com/OpenLinkSoftware/FacetJsClient) — A JavaScript
  client for the Virtuoso Faceted Browsing Service
* [FacetJsClient documentation](https://www.openlinksw.com/DAV/Public/FacetJsClient/doc/index.html) —
  Useful for developers wanting to understand the FCT internals, this documentation includes a description
  of the Facet Service XML data structure which underpins FCT; how to interpret it;
  and examples showing the resulting generated SPARQL query and the significance
  of the position of the view element in setting the implicit focus (subject node) for
  applying FCT filters.
  