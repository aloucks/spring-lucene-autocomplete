package com.test.autocomplete;

import java.io.IOException;
import java.text.MessageFormat;
import java.util.Map;
import java.util.Scanner;

import org.apache.lucene.queryparser.classic.ParseException;

import com.test.autocomplete.index.Index;
import com.test.autocomplete.index.impl.IndexImpl;
import com.test.autocomplete.index.impl.TestDocumentFeederImpl;
import com.test.autocomplete.model.SearchResultsDTO;

public class Main {

	/**
	 * @param args
	 * @throws IOException 
	 * @throws ParseException 
	 */
	public static void main(String[] args) throws IOException, ParseException {
		IndexImpl index = new IndexImpl(new TestDocumentFeederImpl());
		
		int max = 15;
		//String s = "23";

		Scanner scanner = new Scanner(System.in);
		while ( scanner.hasNextLine() ) {
			String s = scanner.nextLine().trim();

			long start = System.currentTimeMillis();
			SearchResultsDTO results = index.search(
				MessageFormat.format("trim-code:{0}^2.0 OR trim-code:{0}*^1.5 OR raw-code:{0}*^1.5 OR description:\"{0}\" OR description:{0}*", s), max); //OR raw-code:0*{0}*
			long stop = System.currentTimeMillis();
			System.out.println("Query: " + (stop - start) + " ms");
			if ( results.getErrorCode() != Index.ERROR_OK ) {
				System.out.println("Error: " + results.getErrorText());
			}
			for ( Map<String,String> result : results.getResults() ) {
				System.out.println(result);
			}

		}

	}

}
