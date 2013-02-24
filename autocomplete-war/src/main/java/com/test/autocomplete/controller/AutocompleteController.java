package com.test.autocomplete.controller;

import java.io.IOException;
import java.text.MessageFormat;

import javax.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.test.autocomplete.index.Index;
import com.test.autocomplete.index.impl.IndexImpl;
import com.test.autocomplete.index.impl.TestDocumentFeederImpl;
import com.test.autocomplete.model.SearchDTO;
import com.test.autocomplete.model.SearchResultsDTO;

@Controller
@RequestMapping("/autocomplete")
public class AutocompleteController {
	
	private final static Logger log = LoggerFactory.getLogger(AutocompleteController.class);
	private final static String QUERY_TEMPLATE = "trim-code:{0}^2.0 OR trim-code:{0}*^1.5 OR raw-code:{0}*^1.5 OR description:\"{0}\"^10 OR {0}";
	
	private final static int MAX_RESULTS = 100;
	
	private IndexImpl index;
	
	@PostConstruct
	public void postConstruct() {
		try {
			index = new IndexImpl(new TestDocumentFeederImpl());
		} catch (IOException e) {
			log.error("Index failed to initialize", e);
		}
	}
	
	@ModelAttribute("searchDTO")
	public SearchDTO newSearchDTO() {
		return new SearchDTO();
	}
	
	@RequestMapping(produces={MediaType.APPLICATION_JSON_VALUE})
	public @ResponseBody SearchResultsDTO autocomplete(@ModelAttribute("searchDTO") SearchDTO searchDTO) {
		SearchResultsDTO results;
		if ( index != null ) {
			Integer maxResults = searchDTO.getMax();
			if ( maxResults == null || maxResults < 0  || maxResults > MAX_RESULTS ) {
				maxResults = MAX_RESULTS;
			}
			String str = searchDTO.getQuery() == null ? "" : searchDTO.getQuery().trim();
			String queryString = MessageFormat.format(QUERY_TEMPLATE, str);
			results = index.search(queryString, maxResults);
		}
		else {
			results = new SearchResultsDTO();
			results.setErrorCode(Index.ERROR_UNKNOWN);
			results.setErrorText("The index is unavailalbe");
		}
		return results;
	}
}
