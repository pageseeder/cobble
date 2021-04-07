[![Maven Central](https://img.shields.io/maven-central/v/org.pageseeder.cobble/pso-cobble.svg?label=Maven%20Central)](https://search.maven.org/search?q=g:%22org.pageseeder.cobble%22%20AND%20a:%22pso-cobble%22)
# Cobble

Cobble is a simple Java tool to generate documentation for XML-based languages such as
XSLT or Schematron.

```
java -cp pso-cobble-0.3.1.jar;Saxon-HE-9.6.0-6.jar org.pageseeder.cobble.Main [source] > [output]
```

Implementation note: the built-in templates require an XSLT processor which can support 
simple XQuery expressions such as Saxon9.
