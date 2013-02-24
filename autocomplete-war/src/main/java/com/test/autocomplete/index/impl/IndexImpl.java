package com.test.autocomplete.index.impl;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.index.IndexableField;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.RAMDirectory;
import org.apache.lucene.util.Version;

import com.test.autocomplete.index.DocumentFeeder;
import com.test.autocomplete.index.Index;
import com.test.autocomplete.model.SearchResultsDTO;

public class IndexImpl implements Index {
	private IndexSearcher searcher;
	private Analyzer analyzer;
	private Version version = Version.LUCENE_41;
	
	public IndexImpl(DocumentFeeder feeder) throws IOException {
		this(feeder, new RAMDirectory());
	}
	
	public IndexImpl(DocumentFeeder feeder, Directory store) throws IOException {
		analyzer = new StandardAnalyzer(version);
		IndexWriterConfig config = new IndexWriterConfig(version, analyzer);
		IndexWriter indexWriter = new IndexWriter(store, config);
		Document doc = null;
		while ( (doc = feeder.nextDocument()) != null ) {
			indexWriter.addDocument(doc);
		}
		indexWriter.close();
		searcher = new IndexSearcher(DirectoryReader.open(store));
	}
	
	public SearchResultsDTO search(String queryString, int max) {
		List<Map<String,String>> list = new ArrayList<Map<String,String>>();
		SearchResultsDTO results = new SearchResultsDTO();
		try {
			if ( queryString != null ) {
				QueryParser parser = new QueryParser(version, TestDocumentFeederImpl.ALL, analyzer);
				Query query = parser.parse(queryString);
				TopDocs topDocs = searcher.search(query, max);
				results.setTotalHits(topDocs.totalHits);
				for ( ScoreDoc scoreDoc : topDocs.scoreDocs ) {
					Document doc = searcher.doc(scoreDoc.doc);
					Map<String,String> result = new HashMap<String,String>();
					result.put("score", Float.toString(scoreDoc.score));
					for ( IndexableField f : doc.getFields() ) {
						result.put(f.name(), f.stringValue());
					}
					list.add(result);
				}
			}
		} catch ( ParseException e ) {
			results.setErrorCode(Index.ERROR_PARSE);
			results.setErrorText(e.getMessage());
		} catch ( IOException e ) {
			results.setErrorCode(Index.ERROR_IO);
			results.setErrorText(e.getMessage());
		}
		results.setErrorCode(Index.ERROR_OK);
		results.setErrorText("");
		results.setResults(list);
		return results;
	}
}
