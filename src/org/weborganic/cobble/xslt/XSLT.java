/*
 * Copyright (c) 1999-2012 weborganic systems pty. ltd.
 */
package org.weborganic.cobble.xslt;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import javax.xml.transform.Source;
import javax.xml.transform.Templates;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamSource;

/**
 * @author Christophe Lauret
 * @version 22 November 2013
 */
public final class XSLT {

  /**
   * Maps XSLT templates to their URL as a string for easy retrieval.
   */
  private static final Map<String, Templates> CACHE = new HashMap<String, Templates>();

  /** Utility class. */
  private XSLT() {
  }

  /**
   * Return the XSLT templates from the given style.
   *
   * @param url A URL to a template.
   *
   * @return the corresponding XSLT templates object or <code>null</code> if the URL was <code>null</code>.
   *
   * @throws TransformerConfigurationException If XSLT templates could not be loaded from the specified URL.
   * @throws IOException If an IO error occur while reading the template
   */
  public static Templates getTemplates(URL url) throws TransformerConfigurationException, IOException {
    if (url == null) return null;
    // load the templates from the source file
    InputStream in = null;
    Templates templates = null;
    try {
      in = url.openStream();
      Source source = new StreamSource(in);
      source.setSystemId(url.toString());
      TransformerFactory factory = TransformerFactory.newInstance();
      templates = factory.newTemplates(source);
    } finally {
      closeQuietly(in);
    }
    return templates;
  }

  /**
   * Return the XSLT templates from the given style.
   *
   * @param file A file to a template.
   *
   * @return the corresponding XSLT templates object or <code>null</code> if the URL was <code>null</code>.
   *
   * @throws TransformerConfigurationException If XSLT templates could not be loaded from the specified URL.
   * @throws IOException If an IO error occur while reading the template
   */
  public static Templates getTemplates(File file) throws TransformerConfigurationException, IOException {
    URI uri = file.toURI();
    Templates templates = CACHE.get(uri.toString());
    if (templates == null) {
      templates = getTemplates(uri.toURL());
      CACHE.put(uri.toString(), templates);
    }
    return templates;
  }

  /**
   * Return the XSLT templates from the given style.
   *
   * <p>This method will firt try to load the resource using the class loader used for this class.
   *
   * <p>Use this class to load XSLT from the system.
   *
   * @param resource The path to a resource.
   *
   * @return the corresponding XSLT templates object;
   *         or <code>null</code> if the resource could not be found.
   *
   * @throws TransformerConfigurationException If XSLT templates could not be loaded from the specified resource.
   * @throws IOException If an IO error occur while reading the template
   */
  public static Templates getTemplatesFromResource(String resource)
      throws TransformerConfigurationException, IOException {
    ClassLoader loader = XSLT.class.getClassLoader();
    URL url = loader.getResource(resource);
    Templates templates = CACHE.get(url.toString());
    if (templates == null) {
      templates = getTemplates(url);
      CACHE.put(url.toString(), templates);
    }
    return templates;
  }

  /**
   * Clears the internal XSLT cache.
   */
  public void clearCache() {
    CACHE.clear();
  }

  /**
   * Attempt to close the stream and ignore any error.
   * @param in the stream to close.
   */
  private static void closeQuietly(final InputStream in){
    if (in != null){
      try {
        in.close();
      } catch (final IOException ex) {
        // ignored
      }
    }
  }

}
