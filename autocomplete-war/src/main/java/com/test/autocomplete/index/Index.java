package com.test.autocomplete.index;

import com.test.autocomplete.model.SearchResultsDTO;

public interface Index {
	
	public final static int ERROR_UNKNOWN = -1;
	public final static int ERROR_OK = 0;
	public final static int ERROR_PARSE = 1;
	public final static int ERROR_IO = 2;
	
	public SearchResultsDTO search(String queryString, int max);
}
