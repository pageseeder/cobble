[ ![Download](https://api.bintray.com/packages/pageseeder/maven/cobble/images/download.svg) ](https://bintray.com/pageseeder/maven/cobble/_latestVersion)

# Cobble

Cobble is a simple Java tool to generate documentation for XML-based languages such as
XSLT or Schematron.

```
java -cp pso-cobble-0.3.1.jar;Saxon-HE-9.6.0-6.jar org.pageseeder.cobble.Main [source] > [output]
```

Implementation note: the built-in templates require an XSLT processor which can support 
simple XQuery expressions such as Saxon9.
