/*
 * Copyright 2010-2015 Allette Systems (Australia)
 * http://www.allette.com.au
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.pageseeder.cobble.resource;

import java.io.BufferedOutputStream;
import java.io.Closeable;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * @author Christophe Lauret
 * @version 22 November 2013
 */
public final class Resources {

  /**
   * Computes the path for resources in this package.
   */
  private static String path = Resources.class.getPackage().getName().replace('.', '/')+"/";

  /** Utility class. */
  private Resources() {
  }

  /**
   * Copy the resource in this package to the target directory
   *
   * @param name The name of the resource to copy
   * @param dir  The directory it should be copied to.
   *
   * @throws IOException If an error occurs while copying the resource.
   */
  public static void copyTo(String name, File dir) throws IOException {
    ClassLoader loader = Resources.class.getClassLoader();
    final int DEFAULT_BUFFER_SIZE = 1024 * 4;
    InputStream in = null;
    OutputStream out = null;
    File f = new File(dir, name);
    byte[] buffer = new byte[DEFAULT_BUFFER_SIZE];
    try {
      in = loader.getResourceAsStream(path+name);
      out = new BufferedOutputStream(new FileOutputStream(f));
      int n = 0;
      while (-1 != (n = in.read(buffer))) {
        out.write(buffer, 0, n);
      }
    } finally {
      closeQuietly(in);
      closeQuietly(out);
    }
  }

  /**
   * Attempt to close the stream and ignore any error.
   * @param in the stream to close.
   */
  private static void closeQuietly(final Closeable in){
    if (in != null){
      try {
        in.close();
      } catch (final IOException ex) {
        // ignored
      }
    }
  }

}
