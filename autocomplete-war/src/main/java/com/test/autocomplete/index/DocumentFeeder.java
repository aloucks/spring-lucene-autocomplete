package com.test.autocomplete.index;

import org.apache.lucene.document.Document;

public interface DocumentFeeder {
	/**
	 * Returns a document or <code>null</code> when no more documents are available.
	 * @return
	 */
	public Document nextDocument();
}
