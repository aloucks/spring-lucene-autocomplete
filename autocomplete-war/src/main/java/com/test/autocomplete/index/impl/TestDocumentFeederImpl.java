package com.test.autocomplete.index.impl;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.inject.Named;

import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field.Store;
import org.apache.lucene.document.StringField;
import org.apache.lucene.document.TextField;

import com.test.autocomplete.index.DocumentFeeder;

@Named
public class TestDocumentFeederImpl implements DocumentFeeder {
	public final static String ALL = "all";
	public final static String RAW_CODE = "raw-code";
	public final static String TRIM_CODE = "trim-code";
	public final static String DESCRIPTION = "description";
	
	private Iterator<Document> documents;
	
	public TestDocumentFeederImpl() {
		List<Document> list = new ArrayList<Document>();
		Document doc;
		for ( int i=0; i<15000; i++ ) {
			doc = new Document();
			String description = tokens(i);
			String rawCode = String.format("%05d", i);
			String trimCode = String.format("%d", i);
			doc.add(new StringField(RAW_CODE, rawCode, Store.YES));
			doc.add(new StringField(TRIM_CODE, trimCode, Store.YES));
			doc.add(new TextField(DESCRIPTION, description, Store.YES));
			doc.add(new TextField(ALL, rawCode + " " + trimCode + " " + description, Store.NO));
			list.add(doc);
		}
		
		documents = list.iterator();
	}
	
	public Document nextDocument() {
		if ( documents.hasNext() ) {
			return documents.next();
		}
		else {
			return null;
		}
	}

	private String tokens(int i) {
		String number = Integer.toString(i);
		StringBuffer sb = new StringBuffer();
		for ( int c=0; c<number.length(); c++ ) {
			switch ( number.charAt(c) ) {
			case '0' : sb.append("Zero "); break;
			case '1' : sb.append("One "); break;
			case '2' : sb.append("Two "); break;
			case '3' : sb.append("Three "); break;
			case '4' : sb.append("Four "); break;
			case '5' : sb.append("Five "); break;
			case '6' : sb.append("Six "); break;
			case '7' : sb.append("Seven "); break;
			case '8' : sb.append("Eight "); break;
			case '9' : sb.append("Nine "); break;
			}
		}
		//System.out.println(sb);
		return sb.toString().trim();
	}
}
