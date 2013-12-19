/*
 * Copyright (c) 1999-2012 weborganic systems pty. ltd.
 */
package org.weborganic.cobble;

/**
 * @author Christophe Lauret
 * @version 20 December 2013
 */
public final class CobbleException extends Exception {

  /** As required by Serializable. */
  private static final long serialVersionUID = 2444957350957181038L;

  /**
   * @param message
   */
  public CobbleException(String message) {
    super(message);
  }

  /**
   * @param cause
   */
  public CobbleException(Throwable cause) {
    super(cause);
  }

  /**
   * @param message
   * @param cause
   */
  public CobbleException(String message, Throwable cause) {
    super(message, cause);
  }

}
