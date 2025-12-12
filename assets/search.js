if (!window.searchNamespace) window.searchNamespace = {};

class SearchEngine {
  constructor() {
    this.documents = [];
    this.tokenMap = new Map();
    this.isLoaded = false;
    this.loadError = false;
    this.useWebWorker = typeof Worker !== 'undefined' && searchWorker !== null;
    this.fullDocuments = null; // for lazy loading
    this.rootPath = window.searchNamespace?.rootPath || '';
  }

  // Load search data from JSON
  async loadData() {
    if (this.isLoaded && !this.loadError) return;

    // Clear previous error state on retry
    this.loadError = false;

    try {
      // Load JSON data, try multiple possible paths
      // FIXME: There is only one possible path for now, and this search data is guaranteed
      // to generate at this location, but we'll want to extend this in the future.
      const possiblePaths = ["/assets/search-data.json"];

      let response = null;
      let usedPath = "";

      for (const path of possiblePaths) {
        try {
          const testResponse = await fetch(path);
          if (testResponse.ok) {
            response = testResponse;
            usedPath = path;
            break;
          }
        } catch (e) {
          // Continue to next path
        }
      }

      if (!response) {
        throw new Error("Search data file not found at any expected location");
      }

      console.log(`Loading search data from: ${usedPath}`);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      // Use optimized JSON parsing for large files
      const documents = await this.parseLargeJSON(response);
      if (!Array.isArray(documents)) {
        throw new Error("Invalid search data format");
      }

      this.initializeFromDocuments(documents);
      this.isLoaded = true;
      console.log(`Loaded ${documents.length} documents for search`);
    } catch (error) {
      console.error("Error loading search data:", error);
      this.documents = [];
      this.tokenMap.clear();
      this.loadError = true;
    }
  }

  // Initialize from documents array
  async initializeFromDocuments(documents) {
    if (!Array.isArray(documents)) {
      console.error("Invalid documents format:", typeof documents);
      this.documents = [];
    } else {
      this.documents = documents;
      console.log(`Initialized with ${documents.length} documents`);
    }
    try {
      await this.buildTokenMap();
    } catch (error) {
      console.error("Error building token map:", error);
    }
  }

  // Initialize from search index structure
  initializeIndex(indexData) {
    this.documents = indexData.documents || [];
    this.tokenMap = new Map(Object.entries(indexData.tokenMap || {}));
  }

  // Build token map
  // This is helpful for faster searching with progressive loading
  buildTokenMap() {
    return new Promise((resolve, reject) => {
      this.tokenMap.clear();

      if (!Array.isArray(this.documents)) {
        console.error("No documents to build token map");
        resolve();
        return;
      }

      const totalDocs = this.documents.length;
      let processedDocs = 0;

      try {
        // Process in chunks to avoid blocking UI
        const processChunk = (startIndex, chunkSize) => {
          try {
            const endIndex = Math.min(startIndex + chunkSize, totalDocs);

            for (let i = startIndex; i < endIndex; i++) {
              const doc = this.documents[i];
              if (!doc || typeof doc.title !== 'string' || typeof doc.content !== 'string') {
                console.warn(`Invalid document at index ${i}:`, doc);
                continue;
              }

              const tokens = this.tokenize(doc.title + " " + doc.content);
              tokens.forEach(token => {
                if (!this.tokenMap.has(token)) {
                  this.tokenMap.set(token, []);
                }
                this.tokenMap.get(token).push(i);
              });

              processedDocs++;
            }

            // Update progress and yield control
            if (endIndex < totalDocs) {
              setTimeout(() => processChunk(endIndex, chunkSize), 0);
            } else {
              console.log(`Built token map with ${this.tokenMap.size} unique tokens from ${processedDocs} documents`);
              resolve();
            }
          } catch (error) {
            reject(error);
          }
        };

        // Start processing with small chunks
        processChunk(0, 100);
      } catch (error) {
        reject(error);
      }
    });
  }

  // Tokenize text into searchable terms
  tokenize(text) {
    const tokens = new Set();
    const words = text.toLowerCase().match(/\b[a-zA-Z0-9_-]+\b/g) || [];

    words.forEach(word => {
      if (word.length > 2) {
        tokens.add(word);
      }
    });

    return Array.from(tokens);
  }

  // Advanced search with ranking
  async search(query, limit = 10) {
    if (!query.trim()) return [];

    // Wait for data to be loaded
    if (!this.isLoaded) {
      await this.loadData();
    }

    if (!this.isLoaded || this.documents.length === 0) {
      console.log("Search data not available");
      return [];
    }

    const searchTerms = this.tokenize(query);
    if (searchTerms.length === 0) return [];

    // Fallback to basic search if token map is empty
    if (this.tokenMap.size === 0) {
      return this.fallbackSearch(query, limit);
    }

    // Use Web Worker for large datasets to avoid blocking UI
    if (this.useWebWorker && this.documents.length > 1000) {
      return await this.searchWithWorker(query, limit);
    }

    // For very large datasets, implement lazy loading with candidate docIds
    if (this.documents.length > 10000) {
      const candidateDocIds = new Set();
      searchTerms.forEach(term => {
        const docIds = this.tokenMap.get(term) || [];
        docIds.forEach(id => candidateDocIds.add(id));
      });
      const docIds = Array.from(candidateDocIds);
      return await this.lazyLoadDocuments(docIds, limit);
    }

    const docScores = new Map();

    searchTerms.forEach(term => {
      const docIds = this.tokenMap.get(term) || [];
      docIds.forEach(docId => {
        const doc = this.documents[docId];
        if (!doc) return;

        const currentScore = docScores.get(docId) || 0;

        // Calculate score based on term position and importance
        let score = 1;

        // Title matches get higher score
        if (doc.title.toLowerCase().includes(term)) {
          score += 10;
          // Exact title match gets even higher score
          if (doc.title.toLowerCase() === term) {
            score += 20;
          }
        }

        // Content matches
        if (doc.content.toLowerCase().includes(term)) {
          score += 2;
        }

        // Boost for multiple term matches
        docScores.set(docId, currentScore + score);
      });
    });

    // Sort by score and return top results
    const scoredResults = Array.from(docScores.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, limit);

    return scoredResults
      .map(([docId, score]) => ({
        ...this.documents[docId],
        score
      }));
  }

  // Generate search preview with highlighting
  generatePreview(content, query, maxLength = 150) {
    const lowerContent = content.toLowerCase();

    let bestIndex = -1;
    let bestScore = 0;
    let bestMatch = "";

    // Find the best match position
    const queryWords = this.tokenize(query);
    queryWords.forEach(word => {
      const index = lowerContent.indexOf(word);
      if (index !== -1) {
        const score = word.length; // longer words get higher priority
        if (score > bestScore) {
          bestScore = score;
          bestIndex = index;
          bestMatch = word;
        }
      }
    });

    if (bestIndex === -1) {
      return this.escapeHtml(content.slice(0, maxLength)) + "...";
    }

    const start = Math.max(0, bestIndex - 50);
    const end = Math.min(content.length, bestIndex + bestMatch.length + 50);
    let preview = content.slice(start, end);

    if (start > 0) preview = "..." + preview;
    if (end < content.length) preview += "...";

    // Escape HTML first, then highlight
    preview = this.escapeHtml(preview);
    preview = this.highlightTerms(preview, queryWords);

    return preview;
  }

  // Escape HTML to prevent XSS
  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  // Highlight search terms in text
  highlightTerms(text, terms) {
    let highlighted = text;

    // Sort terms by length (longer first) to avoid overlapping highlights
    const sortedTerms = [...terms].sort((a, b) => b.length - a.length);

    sortedTerms.forEach(term => {
      const regex = new RegExp(`(${this.escapeRegex(term)})`, 'gi');
      highlighted = highlighted.replace(regex, '<mark>$1</mark>');
    });

    return highlighted;
  }

  // Web Worker search for large datasets
  async searchWithWorker(query, limit) {
    return new Promise((resolve, reject) => {
      const messageId = `search_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      const timeout = setTimeout(() => {
        cleanup();
        reject(new Error('Web Worker search timeout'));
      }, 5000); // 5 second timeout

      const handleMessage = (e) => {
        if (e.data.messageId !== messageId) return;

        clearTimeout(timeout);
        cleanup();

        if (e.data.type === 'results') {
          resolve(e.data.data);
        } else if (e.data.type === 'error') {
          reject(new Error(e.data.error || 'Unknown worker error'));
        }
      };

      const handleError = (error) => {
        clearTimeout(timeout);
        cleanup();
        reject(error);
      };

      const cleanup = () => {
        searchWorker.removeEventListener('message', handleMessage);
        searchWorker.removeEventListener('error', handleError);
      };

      searchWorker.addEventListener('message', handleMessage);
      searchWorker.addEventListener('error', handleError);

      searchWorker.postMessage({
        messageId,
        type: 'search',
        data: { documents: this.documents, query, limit }
      });
    });
  }

  // Escape regex special characters
  escapeRegex(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }

  // Resolve path relative to current page location
  resolvePath(path) {
    // If path already starts with '/', it's absolute from domain root
    if (path.startsWith('/')) {
      return path;
    }
    
    // If path starts with '#', it's a fragment on current page
    if (path.startsWith('#')) {
      return path;
    }
    
    // Prepend root path for relative navigation
    return this.rootPath + path;
  }

  // Optimized JSON parser for large files
  async parseLargeJSON(response) {
    const contentLength = response.headers.get('content-length');

    // For small files, use regular JSON parsing
    if (!contentLength || parseInt(contentLength) < 1024 * 1024) { // < 1MB
      return await response.json();
    }

    // For large files, use streaming approach
    console.log(`Large search file detected (${contentLength} bytes), using streaming parser`);

    const reader = response.body.getReader();
    const decoder = new TextDecoder("utf-8");
    let buffer = "";

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });

      // Process in chunks to avoid blocking main thread
      if (buffer.length > 100 * 1024) { // 100KB chunks
        await new Promise(resolve => setTimeout(resolve, 0));
      }
    }

    return JSON.parse(buffer);
  }

  // Lazy loading for search results
  async lazyLoadDocuments(docIds, limit = 10) {
    if (!this.fullDocuments) {
      // Store full documents separately for memory efficiency
      this.fullDocuments = this.documents;
      // Create lightweight index documents
      this.documents = this.documents.map(doc => ({
        id: doc.id,
        title: doc.title,
        path: doc.path
      }));
    }

    return docIds.slice(0, limit).map(id => this.fullDocuments[id]);
  }

  // Fallback search method (simple string matching)
  fallbackSearch(query, limit = 10) {
    const lowerQuery = query.toLowerCase();
    const results = this.documents
      .map(doc => {
        const titleMatch = doc.title.toLowerCase().indexOf(lowerQuery);
        const contentMatch = doc.content.toLowerCase().indexOf(lowerQuery);
        let score = 0;

        if (titleMatch !== -1) {
          score += 10;
          if (doc.title.toLowerCase() === lowerQuery) {
            score += 20;
          }
        }
        if (contentMatch !== -1) {
          score += 2;
        }

        return { doc, score, titleMatch, contentMatch };
      })
      .filter(item => item.score > 0)
      .sort((a, b) => {
        if (a.score !== b.score) return b.score - a.score;
        if (a.titleMatch !== b.titleMatch) return a.titleMatch - b.titleMatch;
        return a.contentMatch - b.contentMatch;
      })
      .slice(0, limit)
      .map(item => ({ ...item.doc, score: item.score }));

    return results;
  }
}

// Web Worker for background search processing
// This is CLEARLY the best way to do it lmao.
// Create Web Worker if supported
let searchWorker = null;
if (typeof Worker !== 'undefined') {
  try {
    searchWorker = new Worker('/assets/search-worker.js');
    console.log('Web Worker initialized for background search');
  } catch (error) {
    console.warn('Web Worker creation failed, using main thread:', error);
  }
}

// Global search engine instance
window.searchNamespace.engine = new SearchEngine();

// Mobile search timeout for debouncing
let mobileSearchTimeout = null;

// Legacy search for backward compatibility
// This could be removed, but I'm emotionally attached to it
// and it could be used as a fallback.
function filterSearchResults(data, searchTerm, limit = 10) {
  return data
    .filter(
      (doc) =>
        doc.title.toLowerCase().includes(searchTerm) ||
        doc.content.toLowerCase().includes(searchTerm),
    )
    .slice(0, limit);
}

document.addEventListener("DOMContentLoaded", function() {
  // Initialize search engine immediately
  window.searchNamespace.engine.loadData().then(() => {
    console.log("Search data loaded successfully");
  }).catch(error => {
    console.error("Failed to initialize search:", error);
  });

  // Search page specific functionality
  const searchPageInput = document.getElementById("search-page-input");
  if (searchPageInput) {
    // Set up event listener
    searchPageInput.addEventListener("input", function() {
      performSearch(this.value);
    });

    // Perform search if URL has query
    const params = new URLSearchParams(window.location.search);
    const query = params.get("q");
    if (query) {
      searchPageInput.value = query;
      performSearch(query);
    }
  }

  // Desktop Sidebar Toggle
  const searchInput = document.getElementById("search-input");
  if (searchInput) {
    const searchResults = document.getElementById("search-results");

    searchInput.addEventListener("input", async function() {
      const searchTerm = this.value.trim();

      if (searchTerm.length < 2) {
        searchResults.innerHTML = "";
        searchResults.style.display = "none";
        return;
      }

      // Show loading state
      searchResults.innerHTML = '<div class="search-result-item">Loading...</div>';
      searchResults.style.display = "block";

      try {
        const results = await window.searchNamespace.engine.search(searchTerm, 8);

        if (results.length > 0) {
          searchResults.innerHTML = results
            .map(
              (doc) => {
                const highlightedTitle = window.searchNamespace.engine.highlightTerms(
                  doc.title,
                  window.searchNamespace.engine.tokenize(searchTerm)
                );
                const resolvedPath = window.searchNamespace.engine.resolvePath(doc.path);
                return `
                          <div class="search-result-item">
                              <a href="${resolvedPath}">${highlightedTitle}</a>
                          </div>
                      `;
              },
            )
            .join("");
          searchResults.style.display = "block";
        } else {
          searchResults.innerHTML =
            '<div class="search-result-item">No results found</div>';
          searchResults.style.display = "block";
        }
      } catch (error) {
        console.error("Search error:", error);
        searchResults.innerHTML =
          '<div class="search-result-item">Search unavailable</div>';
        searchResults.style.display = "block";
      }
    });

    // Hide results when clicking outside
    document.addEventListener("click", function(event) {
      if (
        !searchInput.contains(event.target) &&
        !searchResults.contains(event.target)
      ) {
        searchResults.style.display = "none";
      }
    });

    // Focus search when pressing slash key
    document.addEventListener("keydown", function(event) {
      if (event.key === "/" && document.activeElement !== searchInput) {
        event.preventDefault();
        searchInput.focus();
      }
    });
  }

  // Mobile search functionality
  // This detects mobile viewport and adds click behavior
  function isMobile() {
    return window.innerWidth <= 800;
  }

  if (searchInput) {
    // Add mobile search behavior
    searchInput.addEventListener("click", function(e) {
      if (isMobile()) {
        e.preventDefault();
        e.stopPropagation();
        openMobileSearch();
      }
      // On desktop, let the normal click behavior work (focus the input)
    });

    // Prevent typing on mobile (input should only open popup)
    searchInput.addEventListener("keydown", function(e) {
      if (isMobile()) {
        e.preventDefault();
        openMobileSearch();
      }
    });
  }

  // Mobile search popup functionality
  let mobileSearchPopup = document.getElementById("mobile-search-popup");
  let mobileSearchInput = document.getElementById("mobile-search-input");
  let mobileSearchResults = document.getElementById("mobile-search-results");
  const closeMobileSearchBtn = document.getElementById("close-mobile-search");

  function openMobileSearch() {
    if (mobileSearchPopup) {
      mobileSearchPopup.classList.add("active");
      // Focus the input after a small delay to ensure the popup is visible
      setTimeout(() => {
        if (mobileSearchInput) {
          mobileSearchInput.focus();
        }
      }, 100);
    }
  }

  function closeMobileSearch() {
    if (mobileSearchPopup) {
      mobileSearchPopup.classList.remove("active");
      if (mobileSearchInput) {
        mobileSearchInput.value = "";
      }
      if (mobileSearchResults) {
        mobileSearchResults.innerHTML = "";
        mobileSearchResults.style.display = "none";
      }
    }
  }

  if (closeMobileSearchBtn) {
    closeMobileSearchBtn.addEventListener("click", closeMobileSearch);
  }

  // Close mobile search when clicking outside
  document.addEventListener("click", function(event) {
    if (
      mobileSearchPopup &&
      mobileSearchPopup.classList.contains("active") &&
      !mobileSearchPopup.contains(event.target) &&
      !searchInput.contains(event.target)
    ) {
      closeMobileSearch();
    }
  });

  // Close mobile search on escape key
  document.addEventListener("keydown", function(event) {
    if (
      event.key === "Escape" &&
      mobileSearchPopup &&
      mobileSearchPopup.classList.contains("active")
    ) {
      closeMobileSearch();
    }
  });

  // Mobile search input
  if (mobileSearchInput && mobileSearchResults) {
    function handleMobileSearchInput() {
      clearTimeout(mobileSearchTimeout);
      const searchTerm = mobileSearchInput.value.trim();
      if (searchTerm.length < 2) {
        mobileSearchResults.innerHTML = "";
        mobileSearchResults.style.display = "none";
        return;
      }

      mobileSearchTimeout = setTimeout(async () => {
        // Verify the input still matches before proceeding
        if (mobileSearchInput.value.trim() !== searchTerm) return;

        // Show loading state
        mobileSearchResults.innerHTML = '<div class="search-result-item">Loading...</div>';
        mobileSearchResults.style.display = "block";

        try {
          const results = await window.searchNamespace.engine.search(searchTerm, 8);
          // Verify again after async operation
          if (mobileSearchInput.value.trim() !== searchTerm) return;

          if (results.length > 0) {
            mobileSearchResults.innerHTML = results
              .map(
                (doc) => {
                  const highlightedTitle = window.searchNamespace.engine.highlightTerms(
                    doc.title,
                    window.searchNamespace.engine.tokenize(searchTerm)
                  );
                  const resolvedPath = window.searchNamespace.engine.resolvePath(doc.path);
                  return `
                    <div class="search-result-item">
                        <a href="${resolvedPath}">${highlightedTitle}</a>
                    </div>
                `;
                },
              )
              .join("");
            mobileSearchResults.style.display = "block";
          } else {
            mobileSearchResults.innerHTML =
              '<div class="search-result-item">No results found</div>';
            mobileSearchResults.style.display = "block";
          }
        } catch (error) {
          console.error("Mobile search error:", error);
          // Verify once more
          if (mobileSearchInput.value.trim() !== searchTerm) return;
          mobileSearchResults.innerHTML =
            '<div class="search-result-item">Search unavailable</div>';
          mobileSearchResults.style.display = "block";
        }
      }, 300);
    }

    mobileSearchInput.addEventListener("input", handleMobileSearchInput);
  }

  // Handle window resize to update mobile behavior
  window.addEventListener("resize", function() {
    // Close mobile search if window is resized to desktop size
    if (
      !isMobile() &&
      mobileSearchPopup &&
      mobileSearchPopup.classList.contains("active")
    ) {
      closeMobileSearch();
    }
  });
});

async function performSearch(query) {
  query = query.trim();
  const resultsContainer = document.getElementById("search-page-results");

  if (query.length < 2) {
    resultsContainer.innerHTML =
      "<p>Please enter at least 2 characters to search</p>";
    return;
  }

  // Show loading state
  resultsContainer.innerHTML = "<p>Searching...</p>";

  try {
    const results = await window.searchNamespace.engine.search(query, 50);

    // Display results
    if (results.length > 0) {
      let html = '<ul class="search-results-list">';
      const queryTerms = window.searchNamespace.engine.tokenize(query);

      for (const result of results) {
        const highlightedTitle = window.searchNamespace.engine.highlightTerms(result.title, queryTerms);
        const preview = window.searchNamespace.engine.generatePreview(result.content, query);
        const resolvedPath = window.searchNamespace.engine.resolvePath(result.path);
        html += `<li class="search-result-item">
          <a href="${resolvedPath}">
            <div class="search-result-title">${highlightedTitle}</div>
            <div class="search-result-preview">${preview}</div>
          </a>
        </li>`;
      }
      html += "</ul>";
      resultsContainer.innerHTML = html;
    } else {
      resultsContainer.innerHTML = "<p>No results found</p>";
    }

    // Update URL with query
    const url = new URL(window.location.href);
    url.searchParams.set("q", query);
    window.history.replaceState({}, "", url.toString());
  } catch (error) {
    console.error("Search error:", error);
    resultsContainer.innerHTML = "<p>Search temporarily unavailable</p>";
  }
}
