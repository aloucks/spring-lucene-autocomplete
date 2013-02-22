package com.test.autocomplete.model;

public class SearchDTO {
	private String query;
	private Integer max;
	public String getQuery() {
		return query;
	}
	public void setQuery(String query) {
		this.query = query;
	}
	public Integer getMax() {
		return max;
	}
	public void setMax(Integer maxResults) {
		this.max = maxResults;
	}
}
