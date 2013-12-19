/*
 * Copyright (c) 1999-2012 weborganic systems pty. ltd.
 */
package org.weborganic.cobble;

import java.io.File;

/**
 * To invoke the library on the command line.
 *
 * @author Christophe Lauret
 * @version 22 November 2013
 */
public final class Main {

  /**
   * Utility class
   */
  private Main() {
  }

  public static void main(String[] args) throws CobbleException {
    if (args.length == 0) {
      System.err.println("Usage");
      System.err.println("  java -jar wo-cobble.jar [file]");
      System.exit(0);
    }

    // Get the source and check that it exists
    String path = args[0];
    File source = new File(path);
    if (!source.exists()) {
      System.err.println("Unable to find source code at '"+source.getAbsolutePath()+"'");
      System.exit(-1);
    }

    // Check output type
    boolean html = false;
    for (String arg : args) {
      if (arg.equals("-html")) html = true;
    }

    // Check of output file is specified
    boolean outputSpecified = false;
    File output = null;
    for (String arg : args) {
      if (arg.equals("-o")) outputSpecified = true;
      else if (outputSpecified) {
        output = new File(arg);
        outputSpecified = false;
      }
    }

    // Generate the documentation
    if (html) {
      HTMLGenerator generator = new HTMLGenerator(source);
      generator.setIncludeResources(true);
      generator.generate(output != null? output : new File("."));
    } else {
      XMLGenerator generator = new XMLGenerator(source);
      if (output != null)
        generator.generate(output);
      else
        generator.generate(System.out);
    }
  }
}
