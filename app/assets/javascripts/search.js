(function() {
  "use strict";

  window.GOVUK = window.GOVUK || {};
  window.ga = window.ga || function() {};

  window.ga("require", "ec");

  var $ = window.jQuery;

  var search = {
    init: function () {
      var $searchResults = $('#results .results-list');

      search.enableLiveSearchCheckbox($searchResults);
      search.trackSearchClicks($searchResults);
      search.trackSearchResultsAndSuggestions($searchResults);
      search.trackSearchResultsAndSuggestionsOnPageTrack($searchResults);
    },
    buildSearchResultsData: function ($searchResults) {
      var searchResultData = {'urls': []},
          searchURLs = search.extractSearchURLs($searchResults),
          searchSuggestion = search.extractSearchSuggestion();

      if (searchURLs.length) {
        searchResultData['urls'] = searchURLs.toArray();
      }

      if (searchSuggestion !== null) {
        searchResultData['suggestion'] = searchSuggestion;
      }

      return searchResultData;
    },
    buildEcommerceData: function ($searchResults) {
      return $searchResults.children('li').map(function(index, result) {
        var resultLink = $(result).find('h3 a');
        return {
          url: resultLink.attr('href'),
          title: resultLink.text(),
          position: index + 1
        }
      });
    },
    enableLiveSearchCheckbox: function ($searchResults) {
      if($('.js-openable-filter input[type=checkbox]').length) {
        $('.js-openable-filter').each(function(){
          new GOVUK.CheckboxFilter({el:$(this)});
        });
      }
      GOVUK.liveSearch.init();
    },
    extractSearchSuggestion: function () {
      var $suggestion = $('.spelling-suggestion a');

      if ($suggestion.length) {
        return $suggestion.text();
      } else {
        return null;
      }
    },
    extractSearchURLs: function ($searchResults) {
      if ($searchResults.length <= 0) {
        return [];
      }

      function extractSearchURL(index, element) {
        var foundURL = $(element).find('h3 a');

        if (foundURL.parents('.descoped-results').length) {
          return $.makeArray(foundURL.map(function(index, item) {
            return {
              href: $(item).attr('href'),
              descoped: true
            };
          }));
        } else {
          return {
            href: foundURL.attr('href')
          };
        }
      }

      return $searchResults.children().map(extractSearchURL);
    },
    trackSearchClicks: function ($searchResults) {
      if($searchResults.length === 0 || !GOVUK.cookie){
        return;
      }

      $searchResults.on('click', 'a', function(e){
        var $link = $(e.target),
            sublink = '',
            position, href, startAt;

        var getStartAtValue = function() {
          var queryString = window.location.search,
              startAtRegex = /(&|\?)start=([0-9]+)(&|$)/,
              startAt = 0,
              matches;

          matches = queryString.match(startAtRegex);

          if (matches !== null) {
            startAt = parseInt(matches[2], 10);
          }

          return startAt;
        };

        if ($link.closest('ul').hasClass('sections')) {
          href = $link.attr('href');

          if (href.indexOf('#') > -1) {
            sublink = '&sublink='+href.split('#')[1];
          }

          $link = $link.closest('ul');
        }

        startAt = getStartAtValue();
        position = $link.closest('li').index() + startAt + 1; // +1 so it isn't zero offset
        GOVUK.analytics.setOptionsForNextPageview({
          dimension21: 'position=' + position + sublink
        });
      });
    },
    trackSearchResultsAndSuggestions: function ($searchResults) {
      var searchResultData = search.buildSearchResultsData($searchResults);
      var ecommerceData = search.buildEcommerceData($searchResults);

      if (GOVUK.analytics !== undefined &&
          GOVUK.analytics.trackEvent !== undefined &&
          (searchResultData.urls.length || searchResultData.suggestion)) {

        for (var i = 0; i < ecommerceData.length; i++) {
          var searchResult = ecommerceData[i];
          window.ga('ec:addImpression', {
            id: searchResult.url,
            name: searchResult.title,
            list: 'GOVUK_SITE_SEARCH_PROTOTYPE'
          });
        }

        GOVUK.analytics.trackEvent('searchResults', 'resultsShown', {
          label: JSON.stringify(searchResultData),
          nonInteraction: true,
          page: window.location.pathname + window.location.search
        });
      }
    },
    trackSearchResultsAndSuggestionsOnPageTrack: function ($searchResults) {
      if ($searchResults.length) {
        $(document).on('liveSearch.pageTrack', function () {
          var $searchResults = $('#results .results-list');
          search.trackSearchResultsAndSuggestions($searchResults);
        });
      }
    }
  };

  GOVUK.search = search;
  GOVUK.search.init();
}).call(this);
